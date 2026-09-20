# Contributing to [TODO: PROJECT NAME]

Thank you for helping improve this project. The project values small, reviewable changes, clear
problem statements, and a release process that keeps ordinary contributions separate from
publishing a version.

## Before you start

For a substantial change, please find an existing issue or open one first. Wait for the issue to
be accepted and scoped by a maintainer before investing in implementation. Ask to claim accepted
work so that two contributors do not solve the same problem. Small documentation and focused bug
fixes can go straight to a pull request when the intent is clear.

Please do not disclose a security vulnerability in a public issue. Follow [the security policy](SECURITY.md).

## Local development

[TODO: describe how to install dependencies and run the project locally — this is entirely
stack-specific (`npm ci`, `flutter pub get`, `./gradlew build`, `pip install -r requirements.txt`, ...).]

Useful checks are:

```sh
[TODO: lint command]
[TODO: test command]
[TODO: build command]
```

Please run the relevant checks before opening a pull request and include any limitation in the PR
description.

## Branches and pull requests

Use a short-lived branch based on `main`, for example `feat/issue-42-command`,
`fix/issue-42-permission-prompt`, or `docs/contributing-guide`. There is no permanent
`development` branch — reviewed pull requests land directly on `main`.

Pull request titles must follow [Conventional Commits](https://www.conventionalcommits.org/)
(`feat: ...`, `fix: ...`, `docs: ...`, `chore: ...`, etc.) — the title is what becomes the
changelog entry and drives the version bump on release, and a required check rejects any title
that does not match.

## Release process

Releases are automated with [Release Please](https://github.com/googleapis/release-please) from
Conventional Commit history on `main`. Merging a normal pull request never publishes a release by
itself; a maintainer reviews and merges the accumulated Release Please pull request when ready to
publish.
