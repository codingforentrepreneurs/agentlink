# agentlink

A tool for linking Hermes Agent profiles to git-managed folders outside `~/.hermes/profiles`.

`agentlink` lets you keep the portable parts of a Hermes profile in a normal git repo while Hermes continues reading them from the live profile directory through symlinks.

## Quick Start: Use a Profile Repo

Clone the profile repo where you want to manage it:

```bash
mkdir -p ~/dev/agents
cd ~/dev/agents
git clone git@github.com:YOUR_ORG/agent-profiles.git
cd agent-profiles
```

Install a profile into Hermes with an alias:

```bash
agentlink install profiles/agent-1 --alias
```

To use a different command/profile name:

```bash
hermes profile install profiles/agent-1 --alias --name <name-arg>
```

Configure the model and start a chat through the alias:

```bash
agent-1 model
agent-1 chat
```

If you install without `--alias`, use Hermes' profile flag:

```bash
agentlink install profiles/agent-1
hermes -p agent-1 model
hermes -p agent-1 chat
```

If you already have the profile installed locally, connect the live Hermes profile to the cloned repo:

```bash
agentlink sync agent-1 profiles/agent-1
```

After that, normal git updates change what Hermes reads:

```bash
git pull
agentlink check agent-1 profiles/agent-1
```

For a repo that contains multiple agent profiles:

```bash
git clone git@github.com:YOUR_ORG/my-agents.git
cd my-agents
agentlink install ./profiles --all --alias
agentlink sync ./profiles --all
agent-1 model
agent-1 chat
```

## Install agentlink

Install from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/codingforentrepreneurs/agentlink/main/install.sh | bash
```

Or clone the repo and run the same installer locally:

```bash
git clone https://github.com/codingforentrepreneurs/agentlink.git
cd agentlink
./install.sh
```

This installs:

```text
~/.local/bin/agentlink -> ~/.local/share/agentlink/bin/agentlink
```

If `~/.local/bin` is not on your `PATH`, add it to your shell profile:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

Run `agentlink` with no arguments to select an existing Hermes profile:

```bash
agentlink
```

Pass a Hermes profile name and the git folder where its files should live:

```bash
cd ~/dev/my-profiles/my-profile
agentlink my-profile .
```

This uses:

```text
~/dev/my-profiles/my-profile/
```

as the git-managed source of truth for portable profile files from:

```text
${HERMES_ROOT:-$HOME/.hermes}/profiles/my-profile/
```

After setup, Hermes reads the linked files directly from your git-managed folder.

If you omit the folder, `agentlink` prompts for it:

```bash
agentlink my-profile
Git folder for profile files:
```

If the profile name does not exist in `${HERMES_ROOT:-$HOME/.hermes}/profiles`, `agentlink` shows the available profiles instead of creating a new live profile.

Useful options:

```bash
agentlink list
agentlink install ./profiles/my-profile --alias
agentlink install ./profiles --all --alias
agentlink sync my-profile .
agentlink sync ./profiles --all
agentlink check my-profile .
agentlink status my-profile .
agentlink sync my-profile . --from-profile default
agentlink --dry-run my-profile .
agentlink --verbose my-profile .
agentlink --yes my-profile .
agentlink version
agentlink upgrade
agentlink --version
agentlink --help
```

Normal successful output is intentionally short:

```text
Synced Hermes profile my-profile to /path/to/my-profile
```

## Managed Files

Portable files and directories are moved or linked:

- `distribution.yaml`
- `SOUL.md`
- `config.yaml`
- `mcp.json`
- `skills/`
- `cron/`
- `plugins/`
- `AGENTS.md`
- `CLAUDE.md`
- `profile.md`

If the core Hermes distribution files are missing, `agentlink` scaffolds them:

```text
distribution.yaml
SOUL.md
config.yaml
mcp.json
skills/
cron/
```

The default scaffold does not guess model settings. If you want a new profile repo to inherit model/tool defaults from another Hermes profile, seed missing files from that profile:

```bash
agentlink sync my-profile . --from-profile default
```

This copies missing portable files such as `config.yaml`, `SOUL.md`, `mcp.json`, `skills/`, and `cron/` from `${HERMES_ROOT:-$HOME/.hermes}/profiles/default` before linking.

Runtime and local-only files are not moved into git. If they appear in the repo folder, or if they are symlinked from the live Hermes profile, `agentlink` prints a warning.

Examples:

- `.env`
- `auth.json`
- `memories/`
- `sessions/`
- `state.db*`
- `logs/`
- `workspace/`
- `plans/`
- `home/`
- `local/`
- `*_cache/`
- `tmp/`

## Git Workflow

After running `agentlink`:

```bash
cd ~/dev/my-profiles/my-profile
git init
git add .
git commit -m "Initial commit"
git remote add origin git@github.com:YOUR_ORG/my-profile-profile.git
git push -u origin main
```

Later, pulling changes into that repo updates what Hermes sees:

```bash
cd ~/dev/my-profiles/my-profile
git pull
```

## Uninstall

Upgrade the installed command:

```bash
agentlink upgrade
```

Remove the installed command:

```bash
agentlink uninstall
```

Uninstall removes the installed `agentlink` files. It does not remove profile repos or Hermes profile files.

## Development

Run the test suite:

```bash
./tests/run.sh
```

## Notes

- The live Hermes profile root is `${HERMES_ROOT:-$HOME/.hermes}/profiles/<profile-name>`.
- `HERMES_HOME` is intentionally not used, because it can point directly at an active profile.
- Existing live files are never deleted. Conflicts are backed up beside the live file with a timestamp.
- Works on Bash with standard Unix tools on Linux, WSL, and macOS.

## License

MIT
