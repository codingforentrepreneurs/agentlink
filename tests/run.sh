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

tmp_fake_bin=$(mktemp -d /private/tmp/agentlink-fake-bin.XXXXXX)
tmp_install_profiles=$(mktemp -d /private/tmp/agentlink-install-profiles.XXXXXX)
mkdir -p "$tmp_install_profiles/ceo" "$tmp_install_profiles/cmo"
cat >"$tmp_fake_bin/hermes" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" >>"$tmp_fake_bin/hermes.log"
EOF
chmod +x "$tmp_fake_bin/hermes"
PATH="$tmp_fake_bin:$PATH" "$agentlink" install "$tmp_install_profiles/ceo" --alias >/tmp/agentlink-hermes-install.out
grep -q "^+ hermes profile install .*ceo --alias$" /tmp/agentlink-hermes-install.out
grep -q "^profile install .*ceo --alias$" "$tmp_fake_bin/hermes.log"
pass "install profile with alias"

: >"$tmp_fake_bin/hermes.log"
PATH="$tmp_fake_bin:$PATH" "$agentlink" install "$tmp_install_profiles" --all --alias >/tmp/agentlink-hermes-install-all.out
grep -q "^+ hermes profile install .*ceo --alias$" /tmp/agentlink-hermes-install-all.out
grep -q "^+ hermes profile install .*cmo --alias$" /tmp/agentlink-hermes-install-all.out
grep -q "^profile install .*ceo --alias$" "$tmp_fake_bin/hermes.log"
grep -q "^profile install .*cmo --alias$" "$tmp_fake_bin/hermes.log"
pass "install all profiles with alias"

tmp_repo=$(mktemp -d /private/tmp/agentlink-repo.XXXXXX)
tmp_hermes=$(mktemp -d /private/tmp/agentlink-hermes.XXXXXX)
mkdir -p "$tmp_hermes/profiles/demo"
printf 'live config\n' >"$tmp_hermes/profiles/demo/config.yaml"
HERMES_ROOT="$tmp_hermes" "$agentlink" sync demo "$tmp_repo" >/tmp/agentlink-sync.out
assert_file "$tmp_repo/config.yaml"
grep -q "live config" "$tmp_repo/config.yaml"
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
grep -q '\${HERMES_ROOT}/profiles/demo' "$tmp_repo/README.md"
! grep -q "$tmp_hermes" "$tmp_repo/README.md" || fail "README used absolute HERMES_ROOT path"
tail -1 /tmp/agentlink-sync.out | grep -q "Synced Hermes profile demo to $tmp_repo"
pass "sync explicit destination"

tmp_sync_all_repo=$(mktemp -d /private/tmp/agentlink-sync-all.XXXXXX)
tmp_sync_all_hermes=$(mktemp -d /private/tmp/agentlink-sync-all-hermes.XXXXXX)
mkdir -p "$tmp_sync_all_repo/alpha" "$tmp_sync_all_repo/beta"
mkdir -p "$tmp_sync_all_hermes/profiles/alpha" "$tmp_sync_all_hermes/profiles/beta"
printf 'alpha config\n' >"$tmp_sync_all_hermes/profiles/alpha/config.yaml"
printf 'beta config\n' >"$tmp_sync_all_hermes/profiles/beta/config.yaml"
HERMES_ROOT="$tmp_sync_all_hermes" "$agentlink" sync "$tmp_sync_all_repo" --all >/tmp/agentlink-sync-all.out
grep -q "alpha config" "$tmp_sync_all_repo/alpha/config.yaml"
grep -q "beta config" "$tmp_sync_all_repo/beta/config.yaml"
assert_link "$tmp_sync_all_hermes/profiles/alpha/config.yaml"
assert_link "$tmp_sync_all_hermes/profiles/beta/config.yaml"
grep -q "Synced Hermes profile alpha" /tmp/agentlink-sync-all.out
grep -q "Synced Hermes profile beta" /tmp/agentlink-sync-all.out
pass "sync all profile folders"

tmp_default_repo=$(mktemp -d /private/tmp/agentlink-default-readme.XXXXXX)
tmp_default_home=$(mktemp -d /private/tmp/agentlink-default-home.XXXXXX)
mkdir -p "$tmp_default_home/.hermes/profiles/default-readme"
HOME="$tmp_default_home" "$agentlink" sync default-readme "$tmp_default_repo" >/tmp/agentlink-default-readme.out
grep -q '~/.hermes/profiles/default-readme' "$tmp_default_repo/README.md"
! grep -q "$tmp_default_home" "$tmp_default_repo/README.md" || fail "README used absolute HOME path"
pass "readme uses portable Hermes path"

HERMES_ROOT="$tmp_hermes" "$agentlink" check demo "$tmp_repo" >/tmp/agentlink-check.out
grep -q "Check OK" /tmp/agentlink-check.out
HERMES_ROOT="$tmp_hermes" "$agentlink" doctor demo "$tmp_repo" >/tmp/agentlink-doctor.out
grep -q "Check OK" /tmp/agentlink-doctor.out
pass "check and doctor alias ok"

HERMES_ROOT="$tmp_hermes" "$agentlink" status demo "$tmp_repo" >/tmp/agentlink-status.out
grep -q "Status Hermes profile demo" /tmp/agentlink-status.out
grep -q "linked=" /tmp/agentlink-status.out
pass "status"

tmp_recover_repo=$(mktemp -d /private/tmp/agentlink-recover.XXXXXX)
tmp_recover_hermes=$(mktemp -d /private/tmp/agentlink-recover-hermes.XXXXXX)
mkdir -p "$tmp_recover_hermes/profiles/recover"
cat >"$tmp_recover_repo/config.yaml" <<'EOF'
# Hermes profile config.
# Add model, temperature, reasoning, and tool defaults here.
{}
EOF
printf 'model: recovered\n' >"$tmp_recover_hermes/profiles/recover/config.yaml.backup.20260527153635"
ln -s "$tmp_recover_repo/config.yaml" "$tmp_recover_hermes/profiles/recover/config.yaml"
HERMES_ROOT="$tmp_recover_hermes" "$agentlink" sync recover "$tmp_recover_repo" >/tmp/agentlink-recover.out
grep -q "model: recovered" "$tmp_recover_repo/config.yaml"
pass "recover default config from prior conflict backup"

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
