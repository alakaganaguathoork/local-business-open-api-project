#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ────────────────────────────────────────────────────────────────────────────────
# This script automates Kubectl installation/uninstallation based on provided argument and kube version.
# Usage: kubectl.sh --action <install|uninstall> --version <x.y.z> 
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
# Parse args
# ────────────────────────────────────────────────────────────────────────────────

ACTION=""
VERSION="1.34.0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --action)
      ACTION="$2"; shift 2 ;;
    # --version)
    #   VERSION="$2"; shift 2 ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

if [ "$#" -ne 4 ]; then
  echo "$(color "Usage:") $(italic "kubectl.sh --action <install|uninstall> --version <x.y.z>")"
  exit 1
fi

# ────────────────────────────────────────────────────────────────────────────────
# Functions
# ────────────────────────────────────────────────────────────────────────────────

get_acrh() {
    ARCH=$(uname -m)
    case $ARCH in
      x86_64) export KUBECTL_ARCH="amd64" ;;
      aarch64) export KUBECTL_ARCH="arm64" ;;
      *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
}

# ────────────────────────────────────────────────────────────────────────────────
# Main logic
# ────────────────────────────────────────────────────────────────────────────────

echo "$(color "Performing $ACTION...")"

case "$ACTION" in
  install)
    get_arch
    echo "Detected architecture: $KUBECTL_ARCH"

    if [[ -z "$VERSION" ]]; then
      KUBE_VER="$(curl -Ls https://dl.k8s.io/release/stable.txt)"
    else
      [[ $VERSION != v* ]] && VERSION="v$VERSION"
      KUBE_VER="$VERSION"
    fi

    echo "Installing kubectl version $KUBE_VER"
    curl -LO "https://dl.k8s.io/release/${KUBE_VER}/bin/linux/${KUBECTL_ARCH}/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl
    echo "$(color "✅ kubectl installed successfully.")"
    ;;
  
  uninstall)
    if command -v kubectl >/dev/null 2>&1; then
      echo "Removing kubectl..."
      sudo rm -f "$(command -v kubectl)"
      echo "$(color "✅ kubectl removed.")"
    else
      echo "kubectl not installed."
    fi
    ;;
  
  *)
    die "Unknown action: $ACTION"
    ;;
esac
