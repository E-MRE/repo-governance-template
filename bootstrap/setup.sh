#!/usr/bin/env bash
# Applies the repo-SETTINGS half of the GuKi Chat governance campaign to another
# GitHub repo via `gh api` (branch ruleset, security alerts, CodeQL, merge behavior,
# labels). Does NOT touch files — issue templates, CODEOWNERS, dependabot.yml,
# workflows etc. are the other half; copy those from a template repo instead.
#
# Every feature can be forced on/off with a flag, or left to an interactive
# yes/no prompt. Nothing is applied without a flag, --yes, or an explicit "y"
# at the prompt.
set -euo pipefail

FEATURES=(merge_settings security_alerts codeql labels ruleset)
REPO=""
DRY_RUN=0
ASSUME_YES=0
REQUIRED_CHECKS=()
# bash 3.2 (macOS default) has no associative arrays; use dynamic variable
# names instead: WANT_<feature> = "" (unset) | "yes" | "no"

usage() {
  cat <<'EOF'
Usage: setup.sh --repo OWNER/NAME [options]

Options:
  --repo OWNER/NAME       Target repository (required).
  --with-FEATURE          Enable FEATURE without asking.
  --without-FEATURE       Skip FEATURE without asking.
  --required-check NAME   Required status check for the branch ruleset
                           (repeatable; needed for --with-ruleset).
  --yes                   Default every un-flagged feature to "yes" (no prompts).
  --dry-run               Print what would happen; make no API calls.
  -h, --help              Show this help and the feature list.

Features:
  merge_settings   squash-only merge, empty default squash body, delete branch on merge
  security_alerts  Dependabot vulnerability alerts + automated security fixes
  codeql           GitHub code scanning default setup (CodeQL)
  labels           add a small "security" / "dependencies" label pair if missing
  ruleset          branch ruleset on main: required checks, PR required,
                   conversation resolution required, repo-admin bypass
                   (needs at least one --required-check)

With no --with-*/--without-* flags at all, every feature is asked interactively.
EOF
}

[ $# -eq 0 ] && { usage; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --required-check) REQUIRED_CHECKS+=("$2"); shift 2 ;;
    --yes) ASSUME_YES=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --with-*) printf -v "WANT_${1#--with-}" '%s' "yes"; shift ;;
    --without-*) printf -v "WANT_${1#--without-}" '%s' "no"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

[ -z "$REPO" ] && { echo "error: --repo OWNER/NAME is required" >&2; exit 1; }
command -v gh >/dev/null || { echo "error: gh CLI not found" >&2; exit 1; }

ask() {
  local feature="$1" prompt="$2"
  local var="WANT_$feature"
  local preset="${!var:-}"
  if [ -n "$preset" ]; then
    [ "$preset" = "yes" ]
    return
  fi
  if [ "$ASSUME_YES" = 1 ]; then
    return 0
  fi
  read -r -p "$prompt [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]]
}

run() {
  if [ "$DRY_RUN" = 1 ]; then
    echo "DRY-RUN: $*"
  else
    echo "+ $*"
    "$@"
  fi
}

apply_merge_settings() {
  run gh api "repos/$REPO" -X PATCH \
    -f allow_squash_merge=true \
    -f allow_merge_commit=false \
    -f allow_rebase_merge=false \
    -f delete_branch_on_merge=true \
    -f squash_merge_commit_title=PR_TITLE \
    -f squash_merge_commit_message=BLANK
}

apply_security_alerts() {
  run gh api "repos/$REPO/vulnerability-alerts" -X PUT
  run gh api "repos/$REPO/automated-security-fixes" -X PUT
}

apply_codeql() {
  run gh api "repos/$REPO/code-scanning/default-setup" -X PATCH \
    -f state=configured -f query_suite=default
}

apply_labels() {
  run gh api "repos/$REPO/labels" -X POST -f name="security" -f color="d73a4a" \
    -f description="Security-relevant issue or fix" || true
  run gh api "repos/$REPO/labels" -X POST -f name="dependencies" -f color="0366d6" \
    -f description="Dependency version bump" || true
}

apply_ruleset() {
  if [ "${#REQUIRED_CHECKS[@]}" -eq 0 ]; then
    echo "skip ruleset: no --required-check given (repo's real GitHub Actions job names, e.g. 'Quality')" >&2
    return 0
  fi
  local checks_json
  checks_json=$(printf '{"context":"%s"},' "${REQUIRED_CHECKS[@]}")
  checks_json="[${checks_json%,}]"
  local payload
  payload=$(cat <<JSON
{
  "name": "main-protection",
  "target": "branch",
  "enforcement": "active",
  "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}},
  "bypass_actors": [{"actor_type": "RepositoryRole", "actor_id": 5, "bypass_mode": "pull_request"}],
  "rules": [
    {"type": "pull_request", "parameters": {
      "required_approving_review_count": 1,
      "dismiss_stale_reviews_on_push": true,
      "require_code_owner_review": false,
      "require_last_push_approval": false,
      "required_review_thread_resolution": true
    }},
    {"type": "required_status_checks", "parameters": {
      "strict_required_status_checks_policy": true,
      "required_status_checks": ${checks_json}
    }}
  ]
}
JSON
)
  if [ "$DRY_RUN" = 1 ]; then
    echo "DRY-RUN: gh api repos/$REPO/rulesets -X POST --input <payload above>"
    echo "$payload"
  else
    echo "$payload" | gh api "repos/$REPO/rulesets" -X POST --input -
  fi
}

for feature in "${FEATURES[@]}"; do
  if ask "$feature" "Apply '$feature' to $REPO?"; then
    "apply_$feature"
  else
    echo "skipped: $feature"
  fi
done
