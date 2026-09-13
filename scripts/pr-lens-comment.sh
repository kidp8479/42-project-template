#!/bin/sh
# Generate a pr-lens comment locally and post it, via the GitHub
# attachment-upload endpoint instead of the removed CI Action - see
# docs/pr-lens-setup.md for why: the Action links raw.githubusercontent.com
# URLs, which 404 on a private repo. This endpoint is access-controlled
# instead (same mechanism as dragging an image into a comment box) -
# undocumented by GitHub, but confirmed working on Hypertube PR #40.
#
# Uses `pr-lens comment` itself for the title, description, stats and
# per-diagram write-up (it composes all of that from the analysis) -
# this script only replaces its placeholder image URLs with real
# uploaded ones, it does not reimplement any of the text.
#
# Usage: scripts/pr-lens-comment.sh <pr-number> [base] [head]
#   pr-number  required, e.g. 40
#   base       default: main
#   head       default: current branch
#
# Run from inside the repo. Needs: GEMINI_API_KEY exported, gh
# authenticated with repo access, jq, npx.

set -eu

pr_number="${1:?usage: scripts/pr-lens-comment.sh <pr-number> [base] [head]}"
base="${2:-main}"
head="${3:-$(git branch --show-current)}"

[ -n "${GEMINI_API_KEY:-}" ] || {
	echo "GEMINI_API_KEY is not set - export it first (see docs/pr-lens-setup.md)." >&2
	exit 1
}

repo_slug=$(gh repo view --json nameWithOwner -q .nameWithOwner)
repo_id=$(gh api "repos/$repo_slug" --jq .id)
token=$(gh auth token)

echo "analyzing $base..$head (PR #$pr_number)..." >&2
npx --yes @coldtea/pr-lens-cli analyze --base "$base" --head "$head" --pr "$pr_number" --model gemini-3.6-flash
npx --yes @coldtea/pr-lens-cli render .pr-lens/graph.json

manifest=.pr-lens/manifest.json
drawn_graph=.pr-lens/drawn.graph.json
[ -f "$manifest" ] && [ -f "$drawn_graph" ] || {
	echo "render did not produce a manifest, nothing to post" >&2
	exit 1
}

placeholder="PRLENS_PLACEHOLDER"
md=$(npx --yes @coldtea/pr-lens-cli comment --graph "$drawn_graph" --manifest "$manifest" --asset-base-url "$placeholder")

# Upload every asset the manifest lists, then swap its placeholder URL for
# the real one. Read from a file, not a pipe: piping into `while` runs it
# in a subshell in POSIX sh, and $md updates inside would be lost.
assets_file=$(mktemp)
jq -c '.assets[]' "$manifest" >"$assets_file"
while IFS= read -r asset; do
	path=$(echo "$asset" | jq -r .path)
	real_url=$(curl -s "https://uploads.github.com/user-attachments/assets?name=$(echo "$path" | jq -Rr @uri)&content_type=image%2Fsvg%2Bxml&repository_id=$repo_id" \
		-X POST -H "Authorization: Bearer $token" -H "Accept: application/json" \
		--data-binary "@.pr-lens/$path" | jq -r .url)
	placeholder_url="$placeholder/$path"
	md=$(printf '%s' "$md" | sed "s#$placeholder_url#$real_url#g")
done <"$assets_file"
rm -f "$assets_file"

printf '%s\n' "$md" >.pr-lens/comment.md
gh pr comment "$pr_number" --body-file .pr-lens/comment.md
