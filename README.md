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

1. Fill in `CLAUDE.md` (project context, stack, subject constraints -
   read the subject PDF **and** the marking sheet in full first, they can
   diverge)
2. Replace `<PREFIX>` in `CONTRIBUTING.md` with the project's Linear team
   prefix
3. Fill in the `Makefile` TODOs once the actual backend/frontend
   structure exists
4. Fill in `.github/workflows/ci.yml` and `.github/dependabot.yml` TODOs
5. Add an `AUTHORS` file at the repo root (required by 42 marking sheets,
   often not mentioned in the subject itself)
6. Follow `~/42/veille-42-projets/TOOLCHAIN-SETUP.md` for the
   Linear/GitHub/Slack setup

## What's in here

- `.gitignore` - consolidated, single root file
- `Makefile` - `install`/`up`/`down`/`ps`/`logs`/`format`/`lint`/`test`/`build`,
  with Docker/Podman compose auto-detection
- `.githooks/pre-commit` - blocks commits that aren't formatted/linted
  (enable with `git config core.hooksPath .githooks`, done by `make install`)
- `.github/workflows/ci.yml` - lint/format/test/build skeleton (Node/npm,
  adjust per project)
- `.github/workflows/gitleaks.yml` - secret scanning, no changes needed
- `.github/dependabot.yml` - weekly dependency updates
- `.vscode/settings.json` + `extensions.json` - shared editor config
- `CONTRIBUTING.md` - commit/branch conventions, security baseline
- `CLAUDE.md` - skeleton for project-specific context
