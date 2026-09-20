# Customization checklist

This file is the machine- and human-readable list of everything in this template that is
generic on purpose and needs a project-specific decision before (or shortly after) first use.
The `.claude/skills/repo-governance-audit/` skill reads this file, checks the target repo, and
turns each row into an approval-gated item rather than silently applying it — invoke it with
"audit repo governance" or similar in a Claude Code session inside the target repo.

| File | What to change | Applies to |
|---|---|---|
| `.github/CODEOWNERS` | Replace `@YOUR-GITHUB-USERNAME`; add this project's real manifest/lockfile paths | always |
| `.github/ISSUE_TEMPLATE/config.yml` | Replace `OWNER/REPO` in the three URLs | always |
| `.github/ISSUE_TEMPLATE/bug.yml` | Adapt the "Environment" field's description/placeholder to the real platform | always |
| `.github/dependabot.yml` | Set the real `package-ecosystem` (npm/pub/gradle/pip/...) | always |
| `.github/workflows/ci.yml` | Replace the Node install/lint/test/build block with the real stack; keep the job named `Quality` | always |
| `.github/workflows/release.yml` | Replace the build step and the release-asset path list with the real artifacts; keep the tag-validation and publish steps | only if this repo ships built release artifacts |
| `.github/workflows/release-please.yml` | Add a version-file-sync step only if the project duplicates its version number in a second file | only if applicable — most projects don't need this |
| `release-please-config.json` | Set `package-name`; change `release-type` from `"simple"` if a more specific release-please type fits (`node`, `python`, `java`, `dart`, ...) | always |
| `.release-please-manifest.json` | Set the starting version to match the project's actual current version | always |
| `CODE_OF_CONDUCT.md` | Replace `[TODO: contact email]` | only on public repos with outside contributors |
| `CONTRIBUTING.md` | Replace `[TODO: PROJECT NAME]` and the local-development section | always |
| `SECURITY.md` | Replace `[TODO: OWNER]`/`[TODO: REPO]` | always |
| `scripts/merge-pr.mjs` | Nothing, if `ci.yml`/`pr-title.yml` job names are kept as `Quality`/`Conventional Commits` | always |
| `LICENSE` | Replace the copyright holder/year if forked by someone else; swap the license text entirely if MIT isn't the right choice | always |
| `.gitignore` | Add the real stack's build/dependency ignores (see the TODO comment inside) | always |

## Visibility-dependent items (not files — repository/organization settings)

These are applied via `gh api`, not by copying a file (see the companion `setup.sh` bootstrap
script). A setup skill must check the repo's actual visibility first
(`gh api repos/OWNER/NAME --jq .visibility`) and branch on it:

- **Always sensible regardless of visibility:** branch ruleset (PR required, checks required,
  conversation resolution required), squash-only merge settings, Dependabot vulnerability
  alerts + automated security fixes.
- **Only meaningful on public repos:** `CODE_OF_CONDUCT.md`, issue/PR templates aimed at outside
  contributors, Discussions. A private repo with no outside contributors doesn't need a code of
  conduct; offer it, don't force it.
- **Requires a paid GitHub add-on on private repos — confirm before suggesting:** GitHub code
  scanning (CodeQL) and secret scanning both require GitHub Advanced Security (billed per active
  committer) once the repo is private. Both are free with no extra step on public repos.
