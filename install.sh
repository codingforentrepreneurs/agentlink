#!/usr/bin/env bash
set -euo pipefail

repo_raw_url="${AGENTLINK_RAW_URL:-https://raw.githubusercontent.com/codingforentrepreneurs/agentlink/main}"
install_dir="${AGENTLINK_HOME:-$HOME/.local/share/agentlink}"
bin_dir="${AGENT_LINK_BIN_DIR:-$HOME/.local/bin}"
target="${bin_dir}/agentlink"

script_dir() {
  local source_path=$0
  local dir

  while [[ -L "$source_path" ]]; do
    dir=$(cd -P "$(dirname "$source_path")" >/dev/null 2>&1 && pwd)
    source_path=$(readlink "$source_path")
    [[ "$source_path" == /* ]] || source_path="${dir}/${source_path}"
  done

  cd -P "$(dirname "$source_path")" >/dev/null 2>&1 && pwd
}

path_exists() {
  local path=$1

  [[ -e "$path" || -L "$path" ]]
}

timestamp() {
  date '+%Y%m%d%H%M%S'
}

copy_if_different() {
  local source=$1
  local destination=$2

  if [[ -e "$destination" && "$source" -ef "$destination" ]]; then
    return
  fi

  cp "$source" "$destination"
}

download() {
  local url=$1
  local destination=$2

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$destination"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$destination" "$url"
  else
    printf 'ERROR install requires curl or wget when not run from a clone\n' >&2
    exit 1
  fi
}

source_dir=$(script_dir)
mkdir -p "${install_dir}/bin" "$bin_dir"

if [[ -f "${source_dir}/bin/agentlink" ]]; then
  copy_if_different "${source_dir}/bin/agentlink" "${install_dir}/bin/agentlink"
  copy_if_different "${source_dir}/install.sh" "${install_dir}/install.sh"
else
  download "${repo_raw_url}/bin/agentlink" "${install_dir}/bin/agentlink"
  download "${repo_raw_url}/install.sh" "${install_dir}/install.sh"
fi

chmod +x "${install_dir}/bin/agentlink" "${install_dir}/install.sh"

if [[ -L "$target" && "$(readlink "$target")" == "${install_dir}/bin/agentlink" ]]; then
  printf 'OK %s already links to %s\n' "$target" "${install_dir}/bin/agentlink"
elif path_exists "$target"; then
  backup_path="${target}.backup.$(timestamp)"

  while path_exists "$backup_path"; do
    backup_path="${target}.backup.$(timestamp).${RANDOM}"
  done

  mv "$target" "$backup_path"
  printf 'BACKUP existing %s -> %s\n' "$target" "$backup_path"
  ln -s "${install_dir}/bin/agentlink" "$target"
  printf 'LINK %s -> %s\n' "$target" "${install_dir}/bin/agentlink"
else
  ln -s "${install_dir}/bin/agentlink" "$target"
  printf 'LINK %s -> %s\n' "$target" "${install_dir}/bin/agentlink"
fi

case ":$PATH:" in
  *":$bin_dir:"*)
    ;;
  *)
    printf '\nWARNING %s is not currently on PATH.\n' "$bin_dir" >&2
    printf 'Add this to your shell profile if needed:\n' >&2
    printf '  export PATH="%s:$PATH"\n' "$bin_dir" >&2
    ;;
esac

cat <<EOF

Installed:

$("${install_dir}/bin/agentlink" version)

agentlink <profile-name>
agentlink upgrade
agentlink uninstall
EOF
