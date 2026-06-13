# Chunk Workflow — The Door Remembers

This document defines how contributors claim, implement, review, and close development **chunks** for the one-week jam. Chunks are tracked on GitHub as labeled issues in [Forgewalker-Studios/ProjectClanker](https://github.com/Forgewalker-Studios/ProjectClanker).

Design intent and acceptance criteria live in [GDD.md](GDD.md) §17–18.

## Principles

1. **One chunk, one owner** — Only one person works an in-progress chunk at a time.
2. **Dependencies are gates** — Do not claim a chunk until its dependencies are done.
3. **Yes/no acceptance** — A chunk is complete only when every checklist item in the issue can be answered yes in-game or in the project.
4. **Small PRs** — Prefer one PR per chunk (or a tightly related sub-part).
5. **Gameplay before polish** — Chunks 1–8 and 12 come before art/audio/UI polish unless you are explicitly claiming a polish chunk.

## Chunk status lifecycle

| Status label | Meaning |
|--------------|---------|
| `chunk` | Identifies work as part of the gated chunk plan |
| `status:available` | Ready to claim; dependencies satisfied |
| `status:claimed` | Someone has reserved the chunk but not started the branch |
| `status:in-progress` | Active implementation |
| `status:review` | PR open; acceptance checklist under review |
| `status:done` | Merged and verified |
| `status:blocked` | Waiting on dependency or decision |

Replace status labels when moving between stages. Remove the old status label when adding the new one.

## How to claim a chunk

1. Open the [Chunk board issues filter](https://github.com/Forgewalker-Studios/ProjectClanker/issues?q=is%3Aissue+label%3Achunk+label%3Astatus%3Aavailable) or the project board (see below).
2. Pick an issue whose **Depends on** chunks are all `status:done`.
3. Comment on the issue:

   ```text
   Claiming this chunk.
   ```

4. Assign yourself to the issue.
5. Change labels: remove `status:available`, add `status:claimed`.
6. Create a branch:

   ```text
   chunk/NN-short-name
   ```

   Example: `chunk/02-player-controller`

7. Change labels to `status:in-progress` when you push your first commit.

If two people claim the same chunk, **first comment + assignee wins**. The second person should pick another available chunk.

## How to implement a chunk

1. Read the issue acceptance checklist and the matching GDD section.
2. Work only within the chunk scope. If you discover required work outside scope, open a separate issue or discuss in the chunk issue first.
3. Follow project conventions (typed GDScript, snake_case functions, no ternaries, engine-first configuration).
4. Run the test runner (`Tests/Scenes/TestRunner.tscn`) when touching logic.
5. Keep the Godot project warning-free on startup.
6. Document collision layers, controls, or inspector setup in code comments or existing docs when the chunk requires it.

## How to submit for review

1. Open a PR targeting `main`.
2. PR title format:

   ```text
   chunk: NN — Short Name
   ```

3. In the PR description, paste the issue acceptance checklist and mark each item yes/no with a brief note.
4. Link the issue: `Closes #N` (or `Relates to #N` if the chunk spans multiple PRs).
5. Change issue labels to `status:review`.
6. Request review from the other team member (or leave a comment if solo).

## How to close a chunk

A reviewer (or the claimer, if solo) verifies every acceptance item in-game or in project files.

When all items pass:

1. Merge the PR.
2. Remove `status:review` or `status:in-progress`.
3. Add `status:done`.
4. Comment which checklist items were verified and how.
5. Check downstream chunk issues — if their dependencies are now all done, add `status:available` to those issues.

If any item fails, leave detailed feedback and return the issue to `status:in-progress`.

## Dependency order

```text
Chunk 1  →  everything
Chunk 2  →  3, 5, 6, 7, 12
Chunk 3  →  5, 6, 7, 12
Chunk 4  →  5, 8, 12
Chunk 5  →  6
Chunk 6  →  7
Chunk 7  →  8
Chunk 8  →  12
Chunk 9  →  polish after gameplay path exists
Chunk 10 →  polish after gameplay path exists
Chunk 11 →  polish after gameplay path exists
Chunk 12 →  submission (requires gameplay chunks)
```

**Suggested claim order for jam week:**

| Day | Priority chunks |
|-----|-----------------|
| 1 | 1, 2, 4 |
| 2 | 3, 5 |
| 3 | 6 |
| 4 | 7 |
| 5 | 8 |
| 6 | 9, 10, 11 |
| 7 | 12 |

Chunks 9–11 can start once Chunk 1 is done, but should not block gameplay chunks.

## GitHub project board

Issues are created for Chunks 1–12. To use a visual board:

### Option A — Manual setup (no extra CLI scopes)

1. Go to [Forgewalker-Studios projects](https://github.com/orgs/Forgewalker-Studios/projects).
2. Create a project named **The Door Remembers — Chunks**.
3. Add the repository **ProjectClanker**.
4. Create columns or single-select field **Status** with values: `Available`, `Claimed`, `In Progress`, `Review`, `Done`, `Blocked`.
5. Add all issues labeled `chunk`.
6. Optionally add fields: **Assignee**, **Depends on**, **Blocks**.

### Option B — GitHub CLI (requires `project` scope)

```powershell
gh auth refresh -h github.com -s read:project,project
gh project create --owner Forgewalker-Studios --title "The Door Remembers — Chunks"
```

Then link the repo and add chunk issues with `gh project item-add`.

## Issue index

| Chunk | GitHub issue | Depends on |
|-------|--------------|------------|
| 1 | [#1 Project Foundation](https://github.com/Forgewalker-Studios/ProjectClanker/issues/1) | — |
| 2 | [#2 Player Controller](https://github.com/Forgewalker-Studios/ProjectClanker/issues/2) | 1 |
| 3 | [#3 Combat and Health](https://github.com/Forgewalker-Studios/ProjectClanker/issues/3) | 2 |
| 4 | [#4 Door Hub and Dialogue](https://github.com/Forgewalker-Studios/ProjectClanker/issues/4) | 1, 2 |
| 5 | [#5 Area 1 and Boss 1](https://github.com/Forgewalker-Studios/ProjectClanker/issues/5) | 2, 3, 4 |
| 6 | [#6 Area 2 and Boss 2](https://github.com/Forgewalker-Studios/ProjectClanker/issues/6) | 5 |
| 7 | [#7 Area 3 and Boss 3](https://github.com/Forgewalker-Studios/ProjectClanker/issues/7) | 6 |
| 8 | [#8 Password and Ending System](https://github.com/Forgewalker-Studios/ProjectClanker/issues/8) | 4, 7 |
| 9 | [#9 Silhouette Art Pass](https://github.com/Forgewalker-Studios/ProjectClanker/issues/9) | 1 |
| 10 | [#10 Audio and Music System](https://github.com/Forgewalker-Studios/ProjectClanker/issues/10) | 1 |
| 11 | [#11 Menu, UI, and Settings](https://github.com/Forgewalker-Studios/ProjectClanker/issues/11) | 1 |
| 12 | [#12 Full Playthrough and Build](https://github.com/Forgewalker-Studios/ProjectClanker/issues/12) | 1–8 (11 recommended) |

## Branch and commit conventions

- Branch: `chunk/NN-short-name`
- Commit type: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
- Example: `feat: add player jump and coyote-time buffer`

Do not commit secrets, `.env` files, or local editor state.

## Escalation

- **Scope creep** — Split a new chunk issue rather than expanding the current one.
- **Blocked dependency** — Label `status:blocked` and comment what is missing.
- **Acceptance disagreement** — Resolve in the issue thread; GDD checklist is the source of truth.
- **Softlock or progression bug** — Treat as `fix` against the owning gameplay chunk or open a `bug` issue if post-merge.

## Quick links

- [GDD](GDD.md)
- [Repository](https://github.com/Forgewalker-Studios/ProjectClanker)
- [Available chunks](https://github.com/Forgewalker-Studios/ProjectClanker/issues?q=is%3Aissue+label%3Achunk+label%3Astatus%3Aavailable)
- [In-progress chunks](https://github.com/Forgewalker-Studios/ProjectClanker/issues?q=is%3Aissue+label%3Achunk+label%3Astatus%3Ain-progress)
