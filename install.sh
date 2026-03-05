#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ONLY="all"
PINNED=false

usage() {
  cat <<USAGE
Usage: ./install.sh [--only tools|links|agents|skills] [--pinned]

Options:
  --only     Run only one phase. Default is all phases.
  --pinned   Use pinned skills lock restore mode when running skills phase.
  -h, --help Show this help message.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)
      [[ $# -ge 2 ]] || { echo "Missing value for --only" >&2; exit 1; }
      ONLY="$2"
      shift 2
      ;;
    --pinned)
      PINNED=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

case "$ONLY" in
  all|tools|links|agents|skills) ;;
  *)
    echo "Invalid --only value: $ONLY" >&2
    usage
    exit 1
    ;;
esac

run_phase() {
  local phase="$1"
  local script="$2"
  if [[ "$ONLY" == "all" || "$ONLY" == "$phase" ]]; then
    echo "==> Running phase: $phase"
    if [[ "$phase" == "skills" && "$PINNED" == "true" ]]; then
      "$script" --pinned
    else
      "$script"
    fi
  fi
}

run_phase "tools" "$ROOT_DIR/scripts/install_tools.sh"
run_phase "links" "$ROOT_DIR/scripts/link_dotfiles.sh"
run_phase "agents" "$ROOT_DIR/scripts/setup_agents.sh"
run_phase "skills" "$ROOT_DIR/scripts/install_skills.sh"

echo "==> Done"
