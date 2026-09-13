# pr-lens setup (local, on demand)

Evaluated 2026-09-13, first as a GitHub Action (CI, auto-post on every
PR). Reverted to local/on-demand after discovering a real limitation:
the Action publishes rendered SVGs to a `pr-lens` branch and links them
via bare `raw.githubusercontent.com` URLs, which 404 on a **private**
repo (no token, no inline render) - not documented anywhere in the
tool, confirmed by testing on two real PRs. Fixing it properly means
self-hosting the SVGs somewhere public (a dedicated assets repo, a
cross-repo write token, a hand-rolled multi-step workflow replacing the
one-line Action) - real infra for a nice-to-have. Not worth it: this
runs locally instead, like `slopo`.

## What it does

Draws a pull request's diff as an architecture / data-flow diagram
(animated SVG). Useful before a line-by-line review, to judge the shape
of a change rather than read it cold - same job as the "Schema review"
step in `pr-review`.

## One-time install

No install beyond `npx` (Node 20.11+) and a model key. No `uv`, no
Ollama, no local model - unlike `slopo`, this always calls a hosted
model (Gemini or OpenAI).

```sh
# Gemini API key, from aistudio.google.com -> Get API key.
# Store in the shell profile, never in a repo or a chat message.
echo 'export GEMINI_API_KEY="..."' >> ~/.zshrc
source ~/.zshrc
```

## Running it (per PR, on demand)

```sh
cd <repo>
npx @coldtea/pr-lens-cli analyze --base main --head <branch> --pr <n> --model gemini-3.6-flash
npx @coldtea/pr-lens-cli render .pr-lens/graph.json
```

`gemini-3.7-flash` (the CLI default) 503'd repeatedly (high demand) and
`gemini-2.5-flash` 404'd (retired) when this was tried as a GitHub
Action - pin `--model gemini-3.6-flash` explicitly rather than trusting
the default.

Output: SVGs (light + dark) under `.pr-lens/` - open directly in a
browser or an editor, no hosting needed. Nothing is posted anywhere;
`.pr-lens/` should be gitignored, this is a local viewing aid, not a
repo artifact.

## Where this fits

- `pr-review` step 3 ("Schema review - judge the approach before the
  lines"): generate the diagram before judging the approach, when the
  change is architecturally non-trivial (multiple services, a new data
  flow) - not for every PR, this calls a paid API and takes real time.
- Not wired into CI or a hook: the private-repo asset problem makes the
  always-on version worse than useless (broken images on every PR),
  and a hosted model call on every push is wasteful for something that
  is only useful before a manual review anyway.

## If a public repo ever exists

The GitHub Action (`coldteadotai/pr-lens/packages/action@v0`, `on:
pull_request`, `api-key: secrets.GEMINI_API_KEY`, pin `model:
gemini-3.6-flash`) works fine there - the asset-hosting problem is
specific to private repos. Revisit then rather than building the
self-hosted-assets workaround for a repo that is private today.
