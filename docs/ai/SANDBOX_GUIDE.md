# Neovim-AIDE AI Context

> This document is part of the **Neovim-AIDE AI Context Pack**.
>
> It defines the sandbox architecture, lifecycle, operating rules, safety
> constraints and validation practices for AI assistants and contributors.
>
> The implementation remains authoritative.

---

# Sandbox Guide

## Purpose

The Neovim-AIDE sandbox provides an isolated Neovim configuration and runtime
for validation.

This is the canonical reference for sandbox architecture, lifecycle, operating
rules, safety constraints and validation.

The canonical development order is:

```text
inspect → edit → local checks → sandbox validation → commit → push
```

Never assume that the sandbox contains the current project state. Before every
validation session, identify the intended release branch, synchronise its
committed baseline and transfer any approved uncommitted changes explicitly.

The sandbox is disposable. Controlled incidental mutation inside it is
acceptable when the main repository remains protected and only the approved
patch remains after validation.

When the process becomes more complex than the change being validated, prefer
a simple procedural safeguard over expanding sandbox or bootstrap
infrastructure. Do not expand that infrastructure without a concrete,
demonstrated need.

---

# Layout and Environment

`tools/sandbox.sh` uses:

```text
/tmp/neovim-aide-sandbox
├── config/
│   └── nvim/    sandbox Git repository
├── data/
├── state/
└── cache/
```

Enter the sandbox with:

```bash
export XDG_CONFIG_HOME=/tmp/neovim-aide-sandbox/config
export XDG_DATA_HOME=/tmp/neovim-aide-sandbox/data
export XDG_STATE_HOME=/tmp/neovim-aide-sandbox/state
export XDG_CACHE_HOME=/tmp/neovim-aide-sandbox/cache

cd /tmp/neovim-aide-sandbox/config/nvim
```

The script prints these commands but cannot export variables into the calling
shell. Apply them before running Neovim or the bootstrap script.

These variables isolate Neovim's XDG configuration and runtime directories.
They do not provide total process isolation. The shell, `HOME`, executables,
Git configuration, authentication and other inherited environment variables
remain shared.

---

# Fresh Sandbox Creation

Check whether the sandbox exists:

```bash
tools/sandbox.sh status
```

If it does not exist:

```bash
tools/sandbox.sh up
```

`up` creates the XDG directories and clones the local source repository into:

```text
/tmp/neovim-aide-sandbox/config/nvim
```

A fresh clone contains committed Git state only. Uncommitted changes in the
source repository are not copied.

If the sandbox repository already exists, `up` reuses it. It does not fetch,
switch branches, fast-forward or otherwise update the clone.

---

# Synchronising an Existing Sandbox

Set the intended branch explicitly:

```bash
SANDBOX_REPO=/tmp/neovim-aide-sandbox/config/nvim
RELEASE_BRANCH=release/rX.Y
```

Replace `release/rX.Y` with the intended release branch.

Inspect the sandbox before synchronising:

```bash
git -C "$SANDBOX_REPO" status --short --branch
git -C "$SANDBOX_REPO" remote -v
git -C "$SANDBOX_REPO" branch --show-current
```

Stop if the sandbox working tree is dirty. Do not reset, clean, force-checkout
or overwrite it.

Synchronise the committed baseline:

```bash
git -C "$SANDBOX_REPO" fetch origin
git -C "$SANDBOX_REPO" switch "$RELEASE_BRANCH"
git -C "$SANDBOX_REPO" merge --ff-only "origin/$RELEASE_BRANCH"
```

If the branch does not yet exist locally, create it from the fetched remote
branch instead:

```bash
git -C "$SANDBOX_REPO" switch --track "origin/$RELEASE_BRANCH"
```

Stop if the expected branch is unavailable, the branch does not match, or the
fast-forward fails.

The sandbox clone is created from the local source repository, so its `origin`
normally points to that local repository rather than GitHub. Verify the remote
instead of assuming.

---

# Validating Committed State

After synchronisation, confirm the sandbox is clean and record its baseline:

```bash
git -C "$SANDBOX_REPO" status --short --branch
git -C "$SANDBOX_REPO" rev-parse HEAD
```

For a clean runtime cycle:

```bash
tools/sandbox.sh reset
```

`reset` deletes and recreates the sandbox `data`, `state` and `cache`
directories. It preserves the sandbox Git repository.

Apply the sandbox XDG exports, enter the sandbox repository and run the
validation commands below.

---

# Validating Approved Uncommitted Changes

Use a scoped patch to transfer approved tracked changes. Do not copy or
synchronise the whole source working tree.

First confirm that the source and sandbox have the same committed baseline:

```bash
SOURCE_HEAD=$(git rev-parse HEAD)
SANDBOX_HEAD=$(git -C "$SANDBOX_REPO" rev-parse HEAD)
test "$SOURCE_HEAD" = "$SANDBOX_HEAD"
```

Stop if the commits differ.

Create a patch containing only approved files:

```bash
PATCH_FILE=/tmp/neovim-aide-approved.patch
git diff --binary HEAD -- <approved-files> > "$PATCH_FILE"
SOURCE_PATCH_SHA=$(shasum -a 256 "$PATCH_FILE" | awk '{print $1}')
```

Replace `<approved-files>` with an explicit file list. Inspect the patch before
continuing.

Check and apply it to the sandbox:

```bash
git -C "$SANDBOX_REPO" apply --check "$PATCH_FILE"
git -C "$SANDBOX_REPO" apply "$PATCH_FILE"
git -C "$SANDBOX_REPO" diff --check
git -C "$SANDBOX_REPO" diff
SANDBOX_PATCH_SHA=$(
  git -C "$SANDBOX_REPO" diff --binary HEAD -- <approved-files> \
    | shasum -a 256 \
    | awk '{print $1}'
)
test "$SANDBOX_PATCH_SHA" = "$SOURCE_PATCH_SHA"
```

Stop if the patch is empty unexpectedly, includes unapproved changes, fails
`apply --check`, produces an unexpected sandbox diff or does not match the
source patch hash.

`git diff --binary HEAD` includes approved tracked staged and unstaged changes.
It does not include untracked files automatically. Untracked files require
separate, explicit review and transfer.

Run `tools/sandbox.sh reset` after the patch is applied when a clean runtime
cycle is required. Runtime reset preserves the patched repository.

---

# Validation Order

For approved uncommitted changes, use this order:

1. Synchronise the sandbox repository to the latest committed release-branch
   baseline.
2. Confirm the sandbox branch, `HEAD` and working tree are correct and clean.
3. Create and inspect a patch containing only the approved files.
4. Apply the patch and verify its SHA-256 against the source patch.
5. Reset only the sandbox runtime state with `tools/sandbox.sh reset`.
6. Apply the sandbox XDG environment.
7. Back up and hash the sandbox `lazy-lock.json`.
8. Install the lockfile restoration trap.
9. Run bootstrap and the relevant startup and health validation.
10. Explicitly restore `lazy-lock.json` and verify its original SHA-256.
11. Verify that only the approved patch remains in the sandbox.
12. Disable the restoration trap.
13. Reverse only the transferred patch.
14. Verify that the sandbox is clean and remains at the expected `HEAD`.
15. Reconfirm that the main repository is unchanged.

---

# Lockfile Safety During Plugin Synchronisation

`./scripts/bootstrap.sh --sync` may update the sandbox copy of
`lazy-lock.json`. This incidental sandbox mutation is acceptable when it is
controlled and reversed before patch removal.

Before running `--sync`, identify the sandbox lockfile, create a temporary
backup, record its SHA-256 and install a cleanup trap:

```bash
LOCKFILE="$SANDBOX_REPO/lazy-lock.json"
LOCK_BACKUP=$(mktemp "${TMPDIR:-/tmp}/neovim-aide-lazy-lock.XXXXXX")

cp "$LOCKFILE" "$LOCK_BACKUP"
ORIGINAL_LOCK_SHA=$(shasum -a 256 "$LOCK_BACKUP" | awk '{print $1}')

cleanup_sandbox_validation() {
  if [ -n "${LOCK_BACKUP:-}" ] &&
     [ -f "${LOCK_BACKUP:-}" ] &&
     [ -n "${LOCKFILE:-}" ]
  then
    cp "$LOCK_BACKUP" "$LOCKFILE"
  fi
}
trap cleanup_sandbox_validation EXIT INT TERM
```

The trap must be active before bootstrap or Neovim validation begins. It must
remain active until the lockfile has been explicitly restored and its hash has
been verified.

After bootstrap, startup and health validation, restore and verify the
lockfile:

```bash
cp "$LOCK_BACKUP" "$LOCKFILE"
RESTORED_LOCK_SHA=$(shasum -a 256 "$LOCKFILE" | awk '{print $1}')
test "$RESTORED_LOCK_SHA" = "$ORIGINAL_LOCK_SHA"

git -C "$SANDBOX_REPO" status --short
```

The status output must name only the approved patch files. Verify their patch
hash again, then disable the trap:

```bash
SANDBOX_PATCH_SHA=$(
  git -C "$SANDBOX_REPO" diff --binary HEAD -- <approved-files> \
    | shasum -a 256 \
    | awk '{print $1}'
)
test "$SANDBOX_PATCH_SHA" = "$SOURCE_PATCH_SHA"

trap - EXIT INT TERM
```

Do not disable the trap before the explicit restoration and SHA-256 check have
succeeded.

If bootstrap or a network operation fails and the validation shell exits, the
trap restores the sandbox lockfile without altering the main repository.
Runtime state may then be reset with `tools/sandbox.sh reset`, and validation
may be retried in the disposable sandbox. Recreate the backup and trap before
the retry.

---

# Supported Validation Commands

## Startup

With the sandbox XDG variables exported:

```bash
cd /tmp/neovim-aide-sandbox/config/nvim
nvim
```

Confirm the active configuration inside Neovim:

```vim
:lua print(vim.fn.stdpath("config"))
```

Expected:

```text
/tmp/neovim-aide-sandbox/config/nvim
```

## Bootstrap

From the sandbox repository:

```bash
./scripts/bootstrap.sh --check
./scripts/bootstrap.sh --sync
./scripts/bootstrap.sh --test-health-gate
```

`--sync` runs plugin synchronisation and the Codex health report. `--check`
skips plugin synchronisation and runs the health report.

The underlying supported headless commands are:

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+checkhealth codex" +qa
```

## Health and State

Inside Neovim:

```vim
:CodexHealth
:CodexHealthCheck
:CodexState
:CodexStateHistory
```

## Logging

Inside Neovim:

```vim
:CodexLog
```

Bootstrap logs are written under the sandbox state directory:

```text
/tmp/neovim-aide-sandbox/state/nvim/bootstrap-sync.log
/tmp/neovim-aide-sandbox/state/nvim/bootstrap-health.log
```

## clangd

Neovim-AIDE configures clangd and includes
`test/cpp/navigation_sample.cpp`, but the repository does not yet define an
exact repeatable clangd attachment check.

That check remains unresolved pending verification. Do not invent or present a
new command as established project behaviour.

---

# Safe Patch Removal

After the lockfile has been restored and verified and the trap has been
disabled, remove only the transferred patch:

```bash
git -C "$SANDBOX_REPO" apply --reverse --check "$PATCH_FILE"
git -C "$SANDBOX_REPO" apply --reverse "$PATCH_FILE"
git -C "$SANDBOX_REPO" status --short --branch
git -C "$SANDBOX_REPO" rev-parse HEAD
```

Stop if the reverse check fails. Do not substitute a hard reset or clean
operation. Validation may have produced additional evidence or changes that
must be reviewed separately.

Finally, reconfirm that the main repository still has its expected branch,
`HEAD` and approved working-tree state.

---

# Stop Conditions

Stop and report rather than attempting automatic recovery when:

- the source or sandbox is on an unexpected branch
- either relevant working tree contains unexpected changes
- the sandbox cannot fetch or fast-forward
- the committed baselines differ before patch transfer
- the patch is unexpected or `git apply --check` fails
- the applied sandbox diff does not match the approved scope
- startup, bootstrap, health or other required validation fails
- safe reverse patch checking fails

Never use `git reset --hard`, `git clean`, forced checkout, broad copying or
destructive synchronisation to recover automatically.

`tools/sandbox.sh down` deletes the complete sandbox, including its Git
repository. `tools/sandbox.sh reset` deletes runtime data, state and cache.
Use either only when the affected contents are known to be disposable.
