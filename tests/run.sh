#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -P "$(dirname "$0")/.." >/dev/null 2>&1 && pwd)
agentlink="${repo_dir}/bin/agentlink"
install_script="${repo_dir}/install.sh"
tests_run=0

pass() {
  tests_run=$((tests_run + 1))
  printf 'ok %s - %s\n' "$tests_run" "$1"
}

fail() {
  printf 'not ok %s - %s\n' "$((tests_run + 1))" "$1" >&2
  exit 1
}

assert_file() {
  [[ -f "$1" ]] || fail "expected file $1"
}

assert_dir() {
  [[ -d "$1" ]] || fail "expected directory $1"
}

assert_link() {
  [[ -L "$1" ]] || fail "expected symlink $1"
}

bash -n "$agentlink"
bash -n "$install_script"
pass "syntax"

"$agentlink" --help >/tmp/agentlink-help.out 2>&1
grep -q "Usage:" /tmp/agentlink-help.out
"$agentlink" --version | grep -q "^agentlink "
"$agentlink" version | grep -q "^agentlink "
pass "help and version"

tmp_list_hermes=$(mktemp -d /private/tmp/agentlink-list-hermes.XXXXXX)
mkdir -p "$tmp_list_hermes/profiles/alpha" "$tmp_list_hermes/profiles/beta"
HERMES_ROOT="$tmp_list_hermes" "$agentlink" list >/tmp/agentlink-list.out
grep -q "^alpha$" /tmp/agentlink-list.out
grep -q "^beta$" /tmp/agentlink-list.out
pass "list profiles"

tmp_repo=$(mktemp -d /private/tmp/agentlink-repo.XXXXXX)
tmp_hermes=$(mktemp -d /private/tmp/agentlink-hermes.XXXXXX)
mkdir -p "$tmp_hermes/profiles/demo"
printf 'live config\n' >"$tmp_hermes/profiles/demo/config.yaml"
HERMES_ROOT="$tmp_hermes" "$agentlink" sync demo "$tmp_repo" >/tmp/agentlink-sync.out
assert_file "$tmp_repo/config.yaml"
assert_file "$tmp_repo/SOUL.md"
assert_file "$tmp_repo/mcp.json"
assert_dir "$tmp_repo/skills"
assert_dir "$tmp_repo/cron"
[[ ! -e "$tmp_repo/workspace" ]] || fail "runtime workspace was scaffolded"
assert_file "$tmp_repo/README.md"
assert_file "$tmp_repo/.gitignore"
assert_file "$tmp_repo/distribution.yaml"
assert_file "$tmp_repo/profile.md"
assert_link "$tmp_hermes/profiles/demo/config.yaml"
tail -1 /tmp/agentlink-sync.out | grep -q "Synced Hermes profile demo to $tmp_repo"
pass "sync explicit destination"

HERMES_ROOT="$tmp_hermes" "$agentlink" check demo "$tmp_repo" >/tmp/agentlink-check.out
grep -q "Check OK" /tmp/agentlink-check.out
HERMES_ROOT="$tmp_hermes" "$agentlink" doctor demo "$tmp_repo" >/tmp/agentlink-doctor.out
grep -q "Check OK" /tmp/agentlink-doctor.out
pass "check and doctor alias ok"

HERMES_ROOT="$tmp_hermes" "$agentlink" status demo "$tmp_repo" >/tmp/agentlink-status.out
grep -q "Status Hermes profile demo" /tmp/agentlink-status.out
grep -q "linked=" /tmp/agentlink-status.out
pass "status"

tmp_dry_repo=$(mktemp -d /private/tmp/agentlink-dry.XXXXXX)
tmp_dry_hermes=$(mktemp -d /private/tmp/agentlink-dry-hermes.XXXXXX)
mkdir -p "$tmp_dry_hermes/profiles/dry"
printf 'dry config\n' >"$tmp_dry_hermes/profiles/dry/config.yaml"
HERMES_ROOT="$tmp_dry_hermes" "$agentlink" --dry-run dry "$tmp_dry_repo" >/tmp/agentlink-dry.out 2>/tmp/agentlink-dry.err
[[ ! -e "$tmp_dry_repo/config.yaml" ]] || fail "dry-run wrote config.yaml"
[[ ! -L "$tmp_dry_hermes/profiles/dry/config.yaml" ]] || fail "dry-run changed live config.yaml"
grep -q "Dry run complete" /tmp/agentlink-dry.out
pass "dry run"

tmp_seed_repo=$(mktemp -d /private/tmp/agentlink-seed.XXXXXX)
tmp_seed_hermes=$(mktemp -d /private/tmp/agentlink-seed-hermes.XXXXXX)
mkdir -p "$tmp_seed_hermes/profiles/new-agent" "$tmp_seed_hermes/profiles/base-agent/skills" "$tmp_seed_hermes/profiles/base-agent/cron"
printf 'model: seeded\n' >"$tmp_seed_hermes/profiles/base-agent/config.yaml"
printf '# Seed soul\n' >"$tmp_seed_hermes/profiles/base-agent/SOUL.md"
printf '{"mcpServers": {"seed": {}}}\n' >"$tmp_seed_hermes/profiles/base-agent/mcp.json"
printf 'skill\n' >"$tmp_seed_hermes/profiles/base-agent/skills/seed.txt"
HERMES_ROOT="$tmp_seed_hermes" "$agentlink" sync new-agent "$tmp_seed_repo" --from-profile base-agent >/tmp/agentlink-seed.out
grep -q "model: seeded" "$tmp_seed_repo/config.yaml"
grep -q "Seed soul" "$tmp_seed_repo/SOUL.md"
grep -q "seed" "$tmp_seed_repo/mcp.json"
assert_file "$tmp_seed_repo/skills/seed.txt"
pass "seed from profile"

tmp_select_repo=$(mktemp -d /private/tmp/agentlink-select.XXXXXX)
tmp_select_hermes=$(mktemp -d /private/tmp/agentlink-select-hermes.XXXXXX)
mkdir -p "$tmp_select_hermes/profiles/alpha" "$tmp_select_hermes/profiles/beta"
printf '2\n%s\n' "$tmp_select_repo" | HERMES_ROOT="$tmp_select_hermes" "$agentlink" >/tmp/agentlink-select.out
assert_file "$tmp_select_repo/distribution.yaml"
assert_file "$tmp_select_repo/SOUL.md"
assert_file "$tmp_select_repo/config.yaml"
assert_file "$tmp_select_repo/mcp.json"
assert_dir "$tmp_select_repo/skills"
assert_dir "$tmp_select_repo/cron"
grep -q "Synced Hermes profile beta" /tmp/agentlink-select.out
pass "interactive profile and destination selection"

tmp_missing_repo=$(mktemp -d /private/tmp/agentlink-missing.XXXXXX)
tmp_missing_hermes=$(mktemp -d /private/tmp/agentlink-missing-hermes.XXXXXX)
mkdir -p "$tmp_missing_hermes/profiles/alpha"
if HERMES_ROOT="$tmp_missing_hermes" "$agentlink" --yes missing "$tmp_missing_repo" >/tmp/agentlink-missing.out 2>/tmp/agentlink-missing.err; then
  fail "missing profile succeeded"
fi
[[ ! -d "$tmp_missing_hermes/profiles/missing" ]] || fail "missing profile was created"
grep -q "Hermes profile not found" /tmp/agentlink-missing.err
pass "missing profile does not create live profile"

tmp_bin=$(mktemp -d /private/tmp/agentlink-bin.XXXXXX)
tmp_home=$(mktemp -d /private/tmp/agentlink-home.XXXXXX)
AGENT_LINK_BIN_DIR="$tmp_bin" AGENTLINK_HOME="$tmp_home" "$install_script" >/tmp/agentlink-install.out 2>/tmp/agentlink-install.err
assert_link "$tmp_bin/agentlink"
test "$tmp_bin/agentlink" -ef "$tmp_home/bin/agentlink"
test -x "$tmp_home/install.sh"
AGENT_LINK_BIN_DIR="$tmp_bin" AGENTLINK_HOME="$tmp_home" "$tmp_bin/agentlink" upgrade >/tmp/agentlink-upgrade.out 2>/tmp/agentlink-upgrade.err
assert_link "$tmp_bin/agentlink"
test "$tmp_bin/agentlink" -ef "$tmp_home/bin/agentlink"
AGENT_LINK_BIN_DIR="$tmp_bin" AGENTLINK_HOME="$tmp_home" "$tmp_bin/agentlink" uninstall >/tmp/agentlink-uninstall.out
[[ ! -e "$tmp_bin/agentlink" ]] || fail "uninstall left agentlink symlink"
[[ ! -e "$tmp_home" ]] || fail "uninstall left install home"
pass "install upgrade and uninstall"

printf '%s tests passed\n' "$tests_run"
