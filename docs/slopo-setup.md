# slopo setup

Evaluated 2026-09-13 (see `known-limitations.md`'s sibling doc `atlas.md`
for how tool evaluations fit the workflow). Adopted: real finding on
first real run (`ravito/backend/src`), see the session that evaluated it.
Not a per-PR check - the embedding pass takes minutes on CPU. Run it
periodically, or as part of `standards-audit` lot 6 ("slop").

## What it does

Semantic near-duplicate detection across a codebase: finds logic
reimplemented differently (different names, different files), which
plain diff review or grep cannot catch. Local, no API key needed with the
setup below.

## One-time install

```sh
# uv (Python package manager, if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# slopo itself
uv tool install slopo
```

## One-time: local embedding model (no API key)

The documented path (`ollama pull ...`) assumes Ollama installs cleanly.
On a machine without passwordless sudo, the install script fails (it
needs root for the systemd service). Workaround: download the release
tarball directly instead of running the installer.

```sh
mkdir -p ~/.local/ollama && cd ~/.local/ollama
curl -LO https://github.com/ollama/ollama/releases/latest/download/ollama-linux-amd64.tar.zst
```

The asset is `.tar.zst` - if the system has no `zstd` binary (also
usually a sudo install) and you don't want to ask for one, decompress
with Python's `zstandard` package instead of system `tar --zstd`:

```sh
uvx --from zstandard python -c "
import zstandard as zstd
with open('ollama-linux-amd64.tar.zst', 'rb') as f, open('ollama.tar', 'wb') as out:
    zstd.ZstdDecompressor().copy_stream(f, out)
"
tar -xf ollama.tar   # extracts to ./bin/ollama
rm ollama-linux-amd64.tar.zst ollama.tar
```

Run the server (foreground or background, no systemd needed) and pull
the model:

```sh
~/.local/ollama/bin/ollama serve &
~/.local/ollama/bin/ollama pull unclemusclez/jina-embeddings-v2-base-code
```

Small model, runs on CPU. Slower than an API embedding model but no cost,
no key, no data leaving the machine.

## Per-project config

```sh
mkdir -p ~/slopo-eval && cd ~/slopo-eval   # or wherever, doesn't need to be in the repo
slopo init
```

Edit `slopo.conf.yaml`:

```yaml
source_dir: /absolute/path/to/the/repo/src

embedding_model: ollama/unclemusclez/jina-embeddings-v2-base-code
embedding_dimensions: 768
```

## Running it

```sh
slopo index    # fast, parses the source tree
slopo embed    # the slow part - minutes on CPU for a few hundred units
slopo analyze  # whole codebase, writes slopo-report/ (one .md per cluster + index.md)
slopo review   # git-diff scoped instead - what changed vs a base ref
```

Read `slopo-report/index.md` first (cluster list, similarity score, file
count), then open the clusters with 2+ **unique files** and a high score -
those are cross-file semantic duplicates, the actionable kind. A cluster
confined to one file (e.g. several similar test cases in one spec) is
usually not worth acting on; anti-slop's guardrails already cover
legitimate test repetition.

## Where this fits

- `standards-audit` lot 6 ("slop"): run `slopo analyze` once per full
  audit pass, review clusters with 2+ files before the delete-oriented
  triage.
- `anti-slop` point 1 ("Reuse before you write") is the manual, in-context
  version of what slopo automates after the fact - they are not a
  replacement for each other.
- Not wired into `pr-review` or a hook: too slow for per-PR, and a fresh
  embedding index per PR would defeat the purpose.
