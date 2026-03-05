#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

sync_dir() {
  local src="$1"
  local dst="$2"
  mkdir -p "$dst"
  rsync -a --delete "$src/" "$dst/"
}

render_codex_config() {
  local base="$ROOT_DIR/agents/codex/config.base.toml"
  local local_override="$HOME/.codex/config.local.toml"
  local target="$HOME/.codex/config.toml"

  mkdir -p "$HOME/.codex"
  cp "$base" "$target"

  if [[ -f "$local_override" ]]; then
    printf "\n" >> "$target"
    cat "$local_override" >> "$target"
  fi
}

render_opencode_config() {
  local base="$ROOT_DIR/agents/opencode/opencode.base.json"
  local local_override="$HOME/.config/opencode/opencode.local.json"
  local target="$HOME/.config/opencode/opencode.json"

  mkdir -p "$HOME/.config/opencode"

  if [[ -f "$local_override" ]]; then
    jq -s '.[0] * .[1]' "$base" "$local_override" > "$target"
  else
    cp "$base" "$target"
  fi
}

sync_repo_skills() {
  local skills_dir="$ROOT_DIR/agents/skills"
  mkdir -p "$HOME/.agents/skills"

  if [[ -d "$skills_dir" ]]; then
    for skill_dir in "$skills_dir"/*; do
      [[ -d "$skill_dir" ]] || continue
      local skill_name
      skill_name="$(basename "$skill_dir")"
      sync_dir "$skill_dir" "$HOME/.agents/skills/$skill_name"
      echo "Synced repo skill: $skill_name"
    done
  fi
}

remove_legacy_codex_skill_copies() {
  # Canonical skill home is ~/.agents/skills. Remove migrated duplicates from ~/.codex/skills.
  local legacy_skills=("git-town-merge-stack" "moodmarks-ios-ops")
  for skill_name in "${legacy_skills[@]}"; do
    if [[ -d "$HOME/.codex/skills/$skill_name" ]]; then
      rm -rf "$HOME/.codex/skills/$skill_name"
      echo "Removed legacy codex skill copy: $skill_name"
    fi
  done
}

echo "-- Syncing Codex prompts/rules"
sync_dir "$ROOT_DIR/agents/codex/prompts" "$HOME/.codex/prompts"
sync_dir "$ROOT_DIR/agents/codex/rules" "$HOME/.codex/rules"

echo "-- Rendering Codex config"
render_codex_config

echo "-- Rendering OpenCode config"
render_opencode_config

echo "-- Syncing repo-managed skills"
sync_repo_skills
remove_legacy_codex_skill_copies
