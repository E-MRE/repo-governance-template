# bootstrap/setup.sh

Applies the repo **settings** half of this governance baseline (not files — see the rest of
this template repo for those) to a real GitHub repository.

## Usage

```bash
./setup.sh --repo OWNER/NAME                     # asks about every feature, one by one
./setup.sh --repo OWNER/NAME --dry-run           # previews everything, applies nothing
./setup.sh --repo OWNER/NAME --yes               # applies every feature without asking
./setup.sh --repo OWNER/NAME \
  --with-codeql --without-labels \
  --required-check "Quality" --required-check "Conventional Commits"
```

Any feature not given a `--with-X` / `--without-X` flag is asked interactively, unless `--yes`
is passed. The `ruleset` feature needs at least one `--required-check` — use the repo's real
GitHub Actions job name (e.g. `Quality`), not a guess.

## Features

- `merge_settings` — squash-only merge, empty default squash body, delete branch on merge
- `security_alerts` — Dependabot vulnerability alerts + automated security fixes
- `codeql` — GitHub code scanning default setup (CodeQL). **Not free on private repos**
  (requires GitHub Advanced Security).
- `labels` — adds `security` / `dependencies` labels if missing
- `ruleset` — branch ruleset on `main`: PR required, conversation resolution required, the
  given checks required, repo-admin bypass for the impossible self-approval case

## Out of scope (on purpose)

- Issue templates, CODEOWNERS, CODE_OF_CONDUCT, dependabot.yml, workflows — these are files;
  they came from the template already, or copy them by hand.
- `scripts/merge-pr.mjs`, `merge-attribution-audit.yml` — project-specific (Node/npm script),
  move by hand.
- Code/secret scanning on an organization's private repos needs GitHub Team + the Advanced
  Security add-on; this script only makes the API call, it does not check whether the plan
  allows it.
