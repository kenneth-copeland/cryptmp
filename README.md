# cryptmp

Encrypted ephemeral temp directory. Creates an encrypted RAM-backed mount,
exports `TMPDIR` to it, runs your command (or an interactive shell), and
destroys the mount on exit.

## Usage

```
cryptmp [-s SIZE] [COMMAND [ARGS...]]
```

```bash
cryptmp                        # interactive shell
cryptmp glumi ./network.ts     # run a command
cryptmp -s 1G make deploy      # 1GB scratch space
CRYPTMP_SIZE=2G cryptmp bash   # via env var
```

Size precedence: `-s` flag > `CRYPTMP_SIZE` env var > `512M` default.

## How it works

### Linux

Creates a `tmpfs` mount inside a private mount namespace via `unshare`. The
namespace is invisible to all other processes. When the process dies — for any
reason, including SIGKILL — the kernel tears down the namespace and everything
in it. No cleanup code needed.

### macOS

Allocates a RAM device via `hdiutil`, formats it as APFS encrypted with a
random one-time passphrase, and mounts it at `/Volumes/cryptmp-<PID>`. Cleanup
is trap-based (`hdiutil detach` on EXIT). If a session is killed hard (SIGKILL),
the orphaned volume is encrypted with a key that no longer exists. A startup
reaper detects and cleans up stale volumes from dead PIDs on next run.

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
