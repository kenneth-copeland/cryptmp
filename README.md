# cryptmp

Encrypted ephemeral temp directory. Creates an encrypted RAM-backed mount,
exports `TMPDIR` to it, runs your command (or an interactive shell), and
destroys the mount on exit.

## Usage

```
cryptmp [-s SIZE] [-n] [COMMAND [ARGS...]]
```

```bash
cryptmp                        # encrypted RAM disk + interactive shell
cryptmp -n make deploy         # plain RAM disk (faster on macOS)
cryptmp --size 1G glumi ./n.ts # 1GB encrypted scratch space
cryptmp -s 256M -n sh          # small, unencrypted
CRYPTMP_ENCRYPT=0 cryptmp sh   # plain via env var
```

### Options

| Short | Long | Env var | Description |
|-------|------|---------|-------------|
| `-s` | `--size SIZE` | `CRYPTMP_SIZE` | Mount size (e.g., `256M`, `1G`). Default: `512M` |
| `-n` | `--no-encrypt` | `CRYPTMP_ENCRYPT=0` | Skip encryption (plain RAM disk) |
| `-h` | `--help` | | Show help |

Flag takes precedence over env var.

## How it works

### Linux

Creates a `tmpfs` mount inside a private mount namespace via `unshare`. The
namespace is invisible to all other processes. When the process dies — for any
reason, including SIGKILL — the kernel tears down the namespace and everything
in it. No cleanup code needed.

If [gocryptfs](https://github.com/rfjakob/gocryptfs) is installed, cryptmp
layers an encrypted FUSE overlay on top of the tmpfs. Files written to TMPDIR
are transparently encrypted before hitting the RAM-backed store. If gocryptfs
is not available, cryptmp falls back to a plain tmpfs with namespace isolation
only and prints a warning. Use `-n` to skip encryption intentionally.

### macOS

Allocates a RAM device via `hdiutil`, formats it as APFS encrypted with a
random one-time passphrase, and mounts it at `/Volumes/cryptmp-<PID>`. Cleanup
is trap-based (`hdiutil detach` on EXIT). If a session is killed hard (SIGKILL),
the orphaned volume is encrypted with a key that no longer exists. A startup
reaper detects and cleans up stale volumes from dead PIDs on next run.

### macOS performance

APFS encryption adds ~2 seconds to startup on macOS due to the multi-step
volume creation process (create RAM device, initialize APFS container, delete
unencrypted volume, add encrypted volume). Use `-n` / `--no-encrypt` to skip
encryption when the data doesn't require it — startup drops to ~1 second.

### macOS note: mktemp

BSD `mktemp` (macOS) ignores `TMPDIR` by default and writes to
`/var/folders/...`. Use `mktemp -p "$TMPDIR"` to ensure temp files land on the
encrypted mount. This works on both macOS and Linux.

## Why

Tools that handle secrets (Pulumi, Terraform, credential helpers) write
plaintext intermediates to temp directories. `cryptmp` ensures those
intermediates live in encrypted volatile memory and are destroyed when the
session ends — not by cleanup code that might fail, but by the mount itself
disappearing.

## Install

```bash
make install                    # /usr/local/bin (may need sudo)
make install PREFIX=~/.local    # ~/.local/bin (no sudo)
```

## Interactive shell

With no arguments, `cryptmp` drops into an interactive session using your
`$SHELL`. Prompt customization is supported for bash, zsh, and fish. Other
POSIX-compatible shells work but get a generic prompt.

## Testing

```bash
make test                       # macOS tests
make docker-test                # all Linux distros (Alpine, Debian, Fedora, Ubuntu)
make docker-test-alpine         # single distro
```

Add a `tests/docker/Dockerfile.<name>` to test additional distros.

## Dependencies

Written in POSIX `sh` — no bash required. Runs on any POSIX-compatible shell.

OS-specific tools:

- **macOS**: `hdiutil`, `diskutil`, `openssl`
- **Linux**: `unshare`, `mount`
- **Linux (encrypted)**: [gocryptfs](https://github.com/rfjakob/gocryptfs) (optional)
