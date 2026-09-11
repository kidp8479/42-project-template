# 42 Project Template

Reusable starter for 42 post-tronc-commun projects: tooling, CI, git hooks,
and conventions extracted from [Hypertube](https://github.com/kidp8479/42_hypertube).

## Usage

```sh
gh repo create <new-project-name> --private --template kidp8479/42-project-template
git clone git@github.com:kidp8479/<new-project-name>.git
cd <new-project-name>
```

Then, in order:

1. `cp CLAUDE.md.example CLAUDE.md` and fill it in (project context,
   stack, subject constraints - read the subject PDF **and** the marking
   sheet in full first, they can diverge). `CLAUDE.md` is gitignored by
   default; `git add -f CLAUDE.md` once the project needs it to survive
   a fresh clone on another machine (see `.claude/standards/school-42.md`
   "Portability").
2. Replace `<PREFIX>` in `CONTRIBUTING.md` with the project's Linear team
   prefix
3. Fill in the `Makefile` TODOs once the actual backend/frontend
   structure exists
4. Fill in `.github/workflows/ci.yml` and `.github/dependabot.yml` TODOs
5. Add an `AUTHORS` file at the repo root (required by 42 marking sheets,
   often not mentioned in the subject itself)
6. Follow `~/42/veille-42-projets/TOOLCHAIN-SETUP.md` for the
   Linear/GitHub/Slack setup

**Before the final defense**: `.claude/standards/school-42.md` has a
"Defense preparation" step that removes `CLAUDE.md` and `.claude/` from
the submitted branch - they are agent tooling and working notes, not a
deliverable. Put that step on the project's own defense checklist so it
does not depend on remembering it under end-of-project pressure.

## What's in here

- `.gitignore` - consolidated, single root file
- `Makefile` - setup, local dev, container lifecycle (`up`/`down`/`re`),
  logs, in-container helpers (`sh-backend`/`be CMD="..."`/`psql`),
  cleanup (`clean`/`fclean`/`wipe-db`), and code quality
  (`format`/`lint`/`typecheck`/`test`/`build`/`doc`) - Docker/Podman
  compose auto-detected, targets grouped into labeled sections
  (`make help`)
- `.githooks/pre-commit` - blocks commits that aren't formatted/linted
  (enable with `git config core.hooksPath .githooks`, done by `make install`)
- `.github/workflows/ci.yml` - lint/format/test/build skeleton (Node/npm,
  adjust per project)
- `.github/workflows/gitleaks.yml` - secret scanning, no changes needed
- `.github/dependabot.yml` - weekly dependency updates
- `.vscode/settings.json` + `extensions.json` - shared editor config
- `CONTRIBUTING.md` - commit/branch conventions, security baseline
- `CLAUDE.md.example` - skeleton for project-specific context; copy to
  `CLAUDE.md` (gitignored by default)
- `.claude/` - vendored from `lab-agentique`: `standards/engineering.md`
  (project-agnostic practice) and `standards/school-42.md` (the 42
  checklist `CLAUDE.md.example` instantiates), workflow skills
  (`pr-review`, `standards-audit`, `end-session`, `resume-session`,
  `test-audit`, `anti-slop`), subagents (`browser-e2e`, `diff-auditor`),
  and hooks (`settings.json` wires them: `guard-bash` / `guard-files`
  block dangerous commands and edits, `no-french-comments` /
  `lint-feedback` flag issues right after a write). Removed before the
  final defense (see "Before the final defense" above).
