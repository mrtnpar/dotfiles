#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PINNED=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pinned)
      PINNED=true
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

install_from_source() {
  local source="$1"
  shift
  local args=(npx -y skills add "$source" -g -a codex -a opencode -a cline -y)
  while [[ $# -gt 0 ]]; do
    args+=(--skill "$1")
    shift
  done
  "${args[@]}"
}

install_explicit_skills() {
  echo "-- Installing explicit third-party skills"
  install_from_source "addyosmani/web-quality-skills" \
    accessibility best-practices core-web-vitals performance seo web-quality-audit

  install_from_source "vercel-labs/skills" \
    find-skills

  install_from_source "vercel-labs/agent-skills" \
    vercel-composition-patterns vercel-react-best-practices vercel-react-native-skills web-design-guidelines

  install_from_source "coleam00/excalidraw-diagram-skill" \
    excalidraw-diagram

  install_from_source "https://github.com/carmahhawwari/ui-design-brain" \
    ui-design-brain

  install_from_source "millionco/react-doctor" \
    react-doctor

  install_from_source "spillwavesolutions/automating-mac-apps-plugin" \
    automating-mac-apps
}

try_pinned_restore() {
  local lock_file="$ROOT_DIR/agents/skills-lock.json"

  if [[ ! -f "$lock_file" ]]; then
    echo "Pinned lock file missing: $lock_file"
    return 1
  fi

  echo "-- Attempting pinned skills restore from lock"
  local tmpdir
  tmpdir="$(mktemp -d)"
  cp "$lock_file" "$tmpdir/skills-lock.json"

  local install_output sync_output
  if ! install_output="$(
    cd "$tmpdir"
    npx -y skills experimental_install 2>&1
  )"; then
    echo "$install_output"
    rm -rf "$tmpdir"
    return 1
  fi
  echo "$install_output"

  if ! sync_output="$(
    cd "$tmpdir"
    npx -y skills experimental_sync -a codex -a opencode -a cline -y 2>&1
  )"; then
    echo "$sync_output"
    rm -rf "$tmpdir"
    return 1
  fi
  echo "$sync_output"

  if grep -qi "No skills found" <<<"$sync_output"; then
    rm -rf "$tmpdir"
    return 1
  fi

  rm -rf "$tmpdir"
  return 0
}

if [[ "$PINNED" == "true" ]]; then
  if ! try_pinned_restore; then
    echo "Pinned restore failed, falling back to explicit source install"
    install_explicit_skills
  fi
else
  install_explicit_skills
fi

echo "-- Skills installation complete"
npx -y skills list -g -a codex
npx -y skills list -g -a opencode
