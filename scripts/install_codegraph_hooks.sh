#!/bin/bash
# Thin wrapper (agent-tools pivot) — canonical logic lives in the shared tool
# repo (~/projects/agent-tools); pin: scripts/agent-tools.version. This file
# only resolves the tool repo and delegates — do not add logic here.
set -euo pipefail
AGENT_TOOLS="${AGENT_TOOLS:-$HOME/projects/agent-tools}"
REPO="${REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
TOOL="$AGENT_TOOLS/scripts/install_codegraph_hooks.sh"
if [ ! -f "$TOOL" ]; then
  echo "ERROR: agent-tools missing (expected $AGENT_TOOLS) — clone: git clone https://github.com/rubenkaksh/agent-tools.git \"$AGENT_TOOLS\"" >&2
  exit 1
fi
export REPO AGENT_TOOLS
exec bash "$TOOL" "$@"
