#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# This script automates common Terraform commands, managing environments and projects.
# Usage: terraform.sh <command> <environment> <cloud> <project>

# ttps://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GIT_ROOT_DIR=$(git rev-parse --show-toplevel)
COMMAND=${1:-}
ENV=${2:-}
CLOUD=${3:-}
PROJECT=${4:-}
ENV_FILE="environments/${ENV}.tfvars"

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

update_build_context_variable() {
    sed -ri "s|^[[:space:]]*build_context[[:space:]]*=.*|build_context = \"${GIT_ROOT_DIR}\"|" "$ENV_FILE"
}

die() {
  echo >&2 "❌ ${1}"
  exit "${2:-1}"
}

# ────────────────────────────────────────────────────────────────────────────────
# cd into the project
# ────────────────────────────────────────────────────────────────────────────────

cd_to_project() {
  local target="$SCRIPT_DIR/../${CLOUD}/projects/${PROJECT}"
  target=$(realpath "$target")

  if ! cd "$target"; then
    die "Failed to cd into project directory: $target"
  fi
  echo "✅ Operating in: $target"
}

# ────────────────────────────────────────────────────────────────────────────────
# Entry point
# ────────────────────────────────────────────────────────────────────────────────

# 1) Validate args
if [ "$#" -ne 4 ]; then
  echo "$(color "Usage:") $(italic "terraform.sh <command> <environment> <cloud> <project>")"
  exit 1
fi

# 2) Move into project dir
cd_to_project

# 3) Sanity-check tfvars file
if [ ! -f "$ENV_FILE" ]; then
  die "Variable file not found: $ENV_FILE"
fi

# 4) Show what we’re about to do
cat <<EOF
$(color "Terraform command:") $(italic "$COMMAND")
$(color "Environment:")      $(italic "$ENV")
$(color "Cloud:")            $(italic "$CLOUD")
$(color "Project path:")     $(italic "$(pwd)")
$(color "Vars file:")        $(italic "$(pwd)/$ENV_FILE")

EOF

# 5) Run Terraform
case "$COMMAND" in
  init)
    # update build_context in tfvars
    update_build_context_variable

    terraform init
    ;;

  plan)
    if [[ $(terraform workspace show) != "sandbox" ]]; then
      terraform init -backend-config="key=${ENV}"    # optional: re-init with env-specific backend 
    fi
    
    terraform plan -var-file="$ENV_FILE"
    ;;

  apply|destroy|refresh|import)
    if [[ $(terraform workspace show) != "sandbox" ]]; then
      # ensure workspace exists
      terraform workspace select "$ENV" 2>/dev/null \
        || terraform workspace new "$ENV"
    fi
    
    # run the command
    terraform "$COMMAND" -var-file="$ENV_FILE" --auto-approve
    ;;

  *)
    die "Unknown Terraform command: $COMMAND"
    ;;
esac
