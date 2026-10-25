# sudo-ask: Controlled Privilege Escalation

## Motivation

The goal was to avoid blanket passwordless `sudo` (NOPASSWD) while still providing a controlled, auditable way for an agent to request elevated privileges. 

Issues with previous approaches:
- Being in the `docker` group is effectively root on the host - this is a security concern and should be avoided
- `pkexec` requires a Polkit authentication agent in the local desktop session. When connecting remotely (SSH) without local GUI access, pkexec prompts won't be visible/accessible
- Plain `sudo` in automated contexts doesn't allow password entry interactively

## Solution

`sud`o-ask is a wrapper script that:
1. Explicitly logs and notifies when elevated privileges are requested (audit trail)
2. Defers to actual `sudo` which requires password authentication (no NOPASSWD)
3. Works in interactive sessions (like SSH) where the user can type their password
4. Provides visibility into exactly what command is being requested

## Implementation

**Location:** `~/.local/bin/sudo-ask`

```bash
#!/usr/bin/env bash
if [ $# -eq 0 ]; then
  echo "usage: sudo-ask <command> [args...]" >&2
  exit 1
fi

echo "[SUDO-ASK] Agent is requesting elevated privileges" >&2
echo "[SUDO-ASK] Command: $*" >&2
echo "[SUDO-ASK] User: $USER" >&2
echo "[SUDO-ASK] Time: $(date -Iseconds)" >&2
command -v notify-send >/dev/null 2>&1 && notify-send -u critical "SUDO REQUEST" "Agent wants to run: $*" 2>/dev/null &
echo "$(date -Iseconds) | $USER | $*" >> "$HOME/.local/state/sudo-ask.log"

if [ -t 0 ] || [ -t 1 ]; then
  exec sudo "$@"
else
  exec sudo -p "[sudo] password for %p: " "$@"
fi
```

**Log location:** `~/.local/state/sudo-ask.log`

**PATH:** Added to `~/.bashrc` and `~/.zshrc`

## Usage

Instead of `sudo <command>`, use `sudo-ask <command> [args...]`

Example:
```bash
sudo-ask apt install tor torsocks proxychains4
```

The user will see the request details and be prompted for their sudo password in the terminal session.

## Security Considerations

- No passwordless sudo configured - authentication always required
- Full audit log of all privilege escalation requests
- Desktop notification on supported systems
- Explicit visibility of requested commands
- Better than docker group membership (which is effectively root)
- Prefer removing user from docker group and running agents as non-docker users
