# repo-governance-template

A reusable GitHub repository governance baseline: issue/PR templates, CODEOWNERS, Dependabot
config, CI quality gates, Release Please wiring, and a squash-merge wrapper that prevents
unwanted commit-attribution trailers. Extracted from a real campaign that hardened
[GuKi Chat](https://github.com/E-MRE/guki-obsidian-chat)'s release process.

This repo is **generic on purpose**. Nothing here assumes a specific language or build tool.
Every place that had to be specific in the source project (Node/npm commands, Obsidian plugin
asset names, a manifest-file version sync) is marked `TODO` and listed in
[`TEMPLATE_CHECKLIST.md`](TEMPLATE_CHECKLIST.md).

## Two halves

1. **Files** (this repo's content) — copied automatically when you create a new repository
   "from this template," or copied by hand into an existing repo.
2. **Repository/organization settings** — branch ruleset, merge behavior, security alerts,
   CodeQL. These are **not files**; GitHub does not copy them from a template. Apply them with
   [`bootstrap/setup.sh`](bootstrap/setup.sh) after the repo exists.

## Using this template

1. On GitHub: **Use this template → Create a new repository**.
2. Work through [`TEMPLATE_CHECKLIST.md`](TEMPLATE_CHECKLIST.md) — replace every `TODO` and
   placeholder with the real project's values.
3. Run `bootstrap/setup.sh --repo OWNER/NAME` to apply the settings half (interactive by
   default; see `bootstrap/README.md` for flags).
4. Delete `TEMPLATE_CHECKLIST.md` and this section of the README once done.

## What's deliberately not included

- A working CI build — `ci.yml`/`release.yml` ship a Node/npm *example* to replace, not a
  working pipeline for every stack.
- Code scanning / secret scanning on private repos — these require a paid GitHub Advanced
  Security add-on once a repo is private; `setup.sh` will still offer to enable code scanning,
  but confirm the org's plan supports it first.
- Organization-wide policy — if the org is on GitHub Team or higher, an
  [organization-level ruleset](https://docs.github.com/en/organizations/managing-organization-settings/creating-rulesets-for-repositories-in-your-organization)
  applied once beats copying `bootstrap/setup.sh`'s ruleset into every repo individually.
