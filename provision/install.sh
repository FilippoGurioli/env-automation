#!/bin/bash

########### Some useful functions ##############
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "[${GREEN}INF${NC}] $*"; }
warning() { echo -e "[${YELLOW}WARN${NC}] $*"; }
error() { echo -e "[${RED}ERR${NC}] $*"; }

########### Some useful functions ##############

set -euo pipefail # fail fast strategy

info "ARCH PROVISIONING SCRIPT"

info "ARCH PROVISIONING DONE"