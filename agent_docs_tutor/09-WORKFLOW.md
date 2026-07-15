# 09 — Workflow (Git + GitHub)

## Why version control

This project spans v1, v2, and v3 across many months. Git gives you:

- **Phase checkpoints.** A commit at the end of every phase is the "this
  works, ship it" marker. Without Git, you can't roll back when a phase
  breaks (and Drift migrations + Riverpod state can break in subtle ways).
- **Sideload v1 from a known-good commit.** The APK you send to friends
  for testing should be built from a tagged commit, not "whatever was
  on disk Tuesday."
- **v2/v3 branches off v1.** When v2 work starts, you branch off the
  v1.0 tag, not off `main` mid-v1. Textbook pattern; doing it from
  day one trains the muscle.
- **Real-world production practice.** Version control, branches, PRs,
  and a remote host are standard in any team or solo project that
  lasts longer than a week. You're learning it now while the project
  is small.

## Commit format

`phase(N): <short-name>`

- `N` is the phase or sub-phase number (e.g., `3a`, `5`, `6`).
- `<short-name>` is present-tense imperative (e.g., `add media_items
  table`, `lock seed color`).
- Example: `phase(3a): add media_items table`.
- No body or footer unless the change is non-trivial; then a 1–3 line
  body explaining *why*, not *what*.

## Branch format

`<type>/<phase>-short-name`

- `<type>` is one of `feat | fix | chore | refactor | docs | test`.
- `<phase>` mirrors the phase number exactly, lowercase letter (e.g.,
  `3a`, not `3A`).
- Examples: `feat/3a-drift-schema`, `fix/6-theme-padding`,
  `chore/1-folder-layout`.
- One branch per phase or sub-phase. Phase 3a and Phase 3b are
  separate branches.

## Commit cadence

**At the end of every phase (or sub-phase, when a phase contains two
independent concerns — e.g., 3a schema + 3b TMDB client).** The Done
Definition is the commit boundary. Not per sub-step, not per keystroke.

Inside a phase, you can commit locally as often as you like — local
commits are cheap and invisible. The *visible* commit is the one at
the phase boundary, when you push to GitHub.

## PR workflow

- Open a PR from your branch into `main` on GitHub.
- **CI is disabled in v1.** You removed `.github/workflows/ci.yml`
  and `tool/ci/*.sh` per Session 0. PRs are gated by your own
  review alone until v2 brings CI back.
- **Squash-merge enabled.** The squash commit title follows
  `phase(N): <short-name>`.
- **Branch must be up-to-date with `main` before merge.**
- Branch protection on `main` (recommended): require PR + 1 review
  (yourself is fine for a solo project) + linear history. Set this
  up once at repo creation in GitHub Settings → Branches.

## Tag strategy

- Tag `v1.0` at the end of Phase 7 (Wrap-up). The APK you sideload
  to friends is built from this tag.
- Tags are immutable. If you find a v1 bug post-tag, fix on a
  `fix/v1.x-...` branch and tag `v1.0.1`, `v1.0.2`, etc.
- v2 work branches off `v1.0` (or the latest `v1.x` tag), not off
  `main` mid-v1.

## Quick Git concepts for beginners

You don't need to learn all of Git upfront. The tutor can teach
concepts inline when you encounter them. Here's the minimum to start:

- `git init` — start a repo (one-time; the project isn't yet a git
  repo)
- `git status` — see what's staged, modified, untracked
- `git add <file>` — stage a file for the next commit
- `git commit -m "..."` — save a snapshot
- `git log --oneline` — recent commits in one line each
- `git branch` / `git switch -c <name>` — list branches / create +
  switch to a new branch
- `git push origin <branch>` — upload to GitHub
- `git pull` — fetch + merge from the remote
- `git tag v1.0 <commit-sha>` — name a specific commit
- A **PR (pull request)** is a request to merge your branch into
  `main`
- `git switch <branch>` — switch to an existing branch (newer
  alternative to `git checkout`)

A typical first-day flow:

```
cd /path/to/media_tracker
git init
git add -A
git commit -m "phase(0): initial scaffolding from tutor doc setup"
gh repo create media_tracker --private --source=. --remote=origin
git push -u origin main
git switch -c feat/1-static-catalogue-hub
# ... work on Phase 1 ...
git add -A
git commit -m "phase(1): static catalogue hub with hardcoded movies"
git push -u origin feat/1-static-catalogue-hub
# Open PR on GitHub; merge when ready
```

## Common pitfalls

- **Don't force-push to `main`.** `git push --force origin main`
  rewrites history; recovery is painful. Force-pushes on your own
  feature branch are fine (and sometimes necessary after a rebase).
- **Don't commit `*.g.dart` if you've hand-edited it.** Drift
  regenerates it on every `build_runner` run; your edits will be
  lost. It's already conventionally gitignored; leave it that way.
- **Don't commit `lib/secrets.dart`.** TMDB API key. Already in
  `.gitignore`.
- **Use a personal access token (PAT) for HTTPS push**, not your
  GitHub password. GitHub deprecated password auth in 2021. Create
  one at GitHub Settings → Developer settings → Personal access
  tokens. With `gh` CLI installed, `gh auth login` handles this
  automatically.
- **Commit small and often inside a phase; push at the phase
  boundary.** Local commits are cheap and invisible to others. The
  push is the visible one.
- **If `git push` fails because the remote has new commits**, run
  `git pull --rebase` (then push), or `git pull --merge` (creates
  a merge commit). Default to rebase for linear history.
- **`git checkout` is deprecated for branch switching.** Use
  `git switch <branch>` and `git switch -c <branch>` instead. (Old
  tutorials may still show `git checkout`; both work, but `switch`
  is clearer.)

## When to commit vs. when to push

| Action | When | Visible? |
|---|---|---|
| Local commit | After any meaningful change inside a phase | No — local only |
| `git push` | At the phase boundary, when the Done Definition is met | Yes — visible on GitHub |
| Open PR | After first push of a new branch | Yes |
| Merge to `main` | After your review of the PR diff | Yes — main advances |
| Tag | At v1.0 / v1.0.1 / v1.1.0 / v2.0.0 boundaries | Yes |

## When to ask the tutor

- "Walk me through `git rebase`" (Template A — Explain concept)
- "Cross-check my commit messages against the format" (Template B)
- "Quiz me on the 14 invariants + Git workflow" (Template C, depth
  `apply`)
- "I'm stuck on a merge conflict" (Template E — I'm stuck)

## Cross-references

- Session cadence (when to commit): `00-START-HERE.md` §"Session rhythm"
- Tutor role: `07-TUTOR-PROTOCOL.md`
- Phase boundaries (when to push): `04-PHASE-GUIDE.md`
- Project charter: `AGENTS.md` (auto-loaded)