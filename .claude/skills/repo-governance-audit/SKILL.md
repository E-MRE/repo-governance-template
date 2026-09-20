---
name: repo-governance-audit
description: Audit the current repo against the repo-governance-template baseline (issue/PR templates, CODEOWNERS, dependabot, CI quality gates, branch ruleset, security settings, attribution-safe merge wrapper) and apply only operator-approved fixes. Use when asked to "set up governance", "audit repo governance", "apply the governance template", or when working in a repo created from repo-governance-template that still has TEMPLATE_CHECKLIST.md.
---

# Repo governance audit

Applies a reusable GitHub governance baseline to *this* repo, whatever its stack (Node,
Flutter/Dart, Kotlin, Python, ...). Never apply anything silently — every finding becomes one
approval-gated item. This mirrors the vault's own task-observer/sparkos-review skills: analyze,
propose, wait for an explicit yes, then act.

Full origin and reasoning: [repo-governance-template](https://github.com/E-MRE/repo-governance-template),
extracted from the GuKi Chat repository governance campaign.

## Step 1 — Establish context

1. `gh repo view --json nameWithOwner,visibility,defaultBranchRef --jq .` — repo identity,
   `public`/`private`, default branch name.
2. Detect the stack by presence of a manifest file in the repo root: `package.json` → npm,
   `pubspec.yaml` → pub (Dart/Flutter), `build.gradle` or `build.gradle.kts` → gradle
   (Kotlin/Android), `requirements.txt`/`pyproject.toml` → pip, `Cargo.toml` → cargo,
   `go.mod` → gomod. More than one present → ask which is the primary CI target, don't guess.
3. Check whether `TEMPLATE_CHECKLIST.md` exists at the repo root. Its presence means this repo
   was created from repo-governance-template and still has unresolved TODOs — treat Step 2's
   file-diff as "finish the checklist," not "start from scratch." Its absence just means: audit
   from scratch, same file list, no checklist file to clean up at the end.

## Step 2 — Diff against the baseline

For each row below, check the *current repo* (not the template) and classify as
`present` / `missing` / `present-but-placeholder` (file exists but still contains an unfilled
`TODO`/`[TODO: ...]` marker copied from the template).

**Files:**
- `AGENTS.md`, `.github/CODEOWNERS`, `.github/pull_request_template.md`, `.github/ISSUE_TEMPLATE/*`,
  `.github/dependabot.yml`, `.github/workflows/{ci,pr-title,merge-attribution-audit,release-please,release}.yml`,
  `release-please-config.json`, `.release-please-manifest.json`, `.github/CODE_OF_CONDUCT.md`,
  `.github/CONTRIBUTING.md`, `.github/SECURITY.md`, `LICENSE`, `.gitignore`, `scripts/merge-pr.mjs`.

**Settings** (`gh api`, not files — see `bootstrap/setup.sh`'s five features):
- `merge_settings`, `security_alerts`, `codeql`, `labels`, `ruleset`. Read current state before
  proposing a change: `gh api repos/OWNER/NAME --jq '{allow_squash_merge,delete_branch_on_merge}'`,
  `gh api repos/OWNER/NAME/code-scanning/default-setup --jq .state`,
  `gh api repos/OWNER/NAME/rulesets --jq '.[].name'`.

**Visibility branching — apply before proposing, not after:**
- Always propose regardless of visibility: `merge_settings`, `security_alerts`, `ruleset`,
  CODEOWNERS, dependabot.yml, CI workflows, LICENSE, .gitignore.
- Public only: `.github/CODE_OF_CONDUCT.md`, issue/PR templates, `codeql`/`labels` (these exist to serve
  outside contributors; a private solo repo doesn't need them — offer once, don't insist).
- Private + no GitHub Advanced Security confirmed: do **not** propose `codeql` or secret
  scanning as a plain checklist item. State explicitly that it needs a paid add-on
  (GitHub Team + Advanced Security, billed per active committer) and ask whether the org has it
  before offering to enable it.

## Step 3 — Propose, don't apply

Present findings as a numbered list, one item per file or setting, in this shape:

```
1. [missing] .github/CODEOWNERS — add with @<detected-or-asked-owner>
2. [placeholder] .github/SECURITY.md — still has [TODO: OWNER]/[TODO: REPO], will fill from repo identity
3. [setting, public repo] codeql — not configured, propose enabling (free on public repos)
4. [setting, private repo] codeql — not configured; requires GitHub Advanced Security on this org's plan — confirm before enabling
5. [stack-specific] .github/workflows/ci.yml — currently a Node example; this repo is Flutter (pubspec.yaml found) — propose replacing install/lint/test/build with flutter pub get / flutter analyze / flutter test
```

Ask for approval per item or in one batch (whichever the operator prefers) — never assume
silence means yes. Group related items (e.g., all of CODEOWNERS/dependabot/CI/ruleset as
"baseline setup") if that makes review faster, but still list each concrete action.

## Step 4 — Apply only what was approved

- File changes: copy from this template repo's tracked files, substitute detected values
  (owner, repo name, package manager, primary language) for `TODO`/placeholder markers. Do not
  invent contact emails, license holders, or CODEOWNERS usernames — ask if not derivable from
  `gh repo view` / git remote.
- Settings changes: run `bootstrap/setup.sh --repo OWNER/NAME --with-<feature> ...` per approved
  feature (or `--without-<feature>` for explicitly declined ones) — never `--yes` blindly, the
  approval already happened in Step 3. For `ruleset`, pass `--required-check` with this repo's
  *real* CI job names (`Quality`, `Conventional Commits`, unless Step 2's ci.yml customization
  renamed them — if renamed, `scripts/merge-pr.mjs`'s `REQUIRED_CHECKS` constant needs the same
  rename, flag this dependency explicitly).

## Step 5 — Cleanup, only if the checklist is fully resolved

If `TEMPLATE_CHECKLIST.md` exists and every row was either applied or explicitly declined in
Step 3, propose (don't auto-run):
- Delete `TEMPLATE_CHECKLIST.md`.
- Remove the "Two halves" / "Using this template" sections from `README.md`, if that boilerplate
  is still present.

Never remove `bootstrap/setup.sh`, `bootstrap/README.md`, or `scripts/merge-pr.mjs` — these are
ongoing tools, not setup scaffolding. `setup.sh` is idempotent and safe to re-run later (a new
required check, a settings drift, a policy change); `merge-pr.mjs` is used on every merge for
the life of the repo.

## Re-running later

This skill is not one-shot. Run it again on the same repo any time to catch drift (a ruleset
edited by hand, a new dependency-ecosystem file added, ci.yml renamed a job) — Step 2's diff
naturally reports "present" for everything already correct and proposes nothing for it.
