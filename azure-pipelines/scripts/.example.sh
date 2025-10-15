#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ────────────────────────────────────────────────────────────────────────────────
# This script does something.
# Usage: .example.sh --action <install|uninstall> --version <x.y.z> 
# ────────────────────────────────────────────────────────────────────────────────

# ────────────────────────────────────────────────────────────────────────────────
# Helpers
# ────────────────────────────────────────────────────────────────────────────────

color() {
  # prints in bold magenta
  printf "\e[1;35m%b\e[0m" "$1"
}

italic() {
  printf "\e[3m%b\e[0m" "$1"
}

die() {
  echo >&2 "❌ ${1}"
  exit "${2:-1}"
}

# ────────────────────────────────────────────────────────────────────────────────
# Defaults
# ────────────────────────────────────────────────────────────────────────────────

ACTION=""
VERSION=""

# ────────────────────────────────────────────────────────────────────────────────
# Parse args
# ────────────────────────────────────────────────────────────────────────────────

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --action|-a)
        ACTION="${2:-}"; shift 2 
        ;;
      --version|-v)
        VERSION="${2:-}"; shift 2
        ;;
      -h|--help)
        echo "$(color "Usage:") $(italic "$0 --action <install|uninstall> --version <x.y.z>")"
        exit 0 
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
  done

  # validate required args
  if [[ -z "$ACTION" ]]; then
    die "$(color "Missing required argument: --action")"
  fi
}

# ────────────────────────────────────────────────────────────────────────────────
# Functions
# ────────────────────────────────────────────────────────────────────────────────



# ────────────────────────────────────────────────────────────────────────────────
# Main logic
# ────────────────────────────────────────────────────────────────────────────────

parse_args "$@"

echo "$(color "Performing $ACTION...")"

case "$ACTION" in
  install)
    ;;
  
  uninstall)
    ;;
  
  *)
    die "$(color Unknown action: $ACTION)"
    ;;
esac
