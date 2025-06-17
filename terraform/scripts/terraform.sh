#!/bin/bash

# This script automates common Terraform commands, managing environments and projects.
# It expects 4 arguments: <terraform_command> <environment> <cloud> <project>

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
GIT_ROOT_DIR=$(git rev-parse --show-toplevel)
COMMAND="$1"
ENV="$2"
CLOUD="$3"
PROJECT="$4"
ENV_FILE="./environments/$ENV.tfvars"

color() {
  local MAGENTA="35"
  local BOLDMAGENTA="\e[1;${MAGENTA}m"
  local ENDCOLOR="\e[0m"
  printf "%b" "${BOLDMAGENTA}$1${ENDCOLOR}"
}

italic() {
  local ITALIC="\e[3m"
  local ENDCOLOR="\e[0m"
  printf "%b"  "${ITALIC}$1${ENDCOLOR}"
}

cd_to_project() {
  # Calculate target directory relative to script
  TARGET_DIR="$SCRIPT_DIR/../$CLOUD/projects/$PROJECT"

  # Normalize to absolute path
  TARGET_DIR=$(realpath "$TARGET_DIR")

  # Change to the target project directory
  if ! cd "$TARGET_DIR"; then
    echo "❌ Failed to cd to $TARGET_DIR" >&2
    exit 1
  fi

  echo "✅ Operating in: $TARGET_DIR"
}

# Check arguments count
if [ $# -ne 4 ]; then
  echo "$(color "Usage:") $(italic "terraform.sh <terraform_command> <environment> <cloud> <project>")"
  exit 1
fi

# Change to the a project directory
cd_to_project

cat <<-EOF
$(color "Terraform command:") $(italic "$COMMAND")
$(color "Environment:") $(italic "$ENV")
$(color "Cloud:") $(italic "$CLOUD")
$(color "Project path:") $(italic "${TARGET_DIR}")

EOF

# For init, just run terraform init
if [ "$COMMAND" = "init" ]; then
  terraform init
elif [ "$COMMAND" = "plan" ]; then
  terraform plan -var-file=$ENV_FILE
else
  # Select or create the workspace
  terraform workspace select "$ENV" 2>/dev/null || terraform workspace new "$ENV"

  # Run the terraform command
  terraform "$COMMAND" -var-file=$ENV_FILE --auto-approve
fi