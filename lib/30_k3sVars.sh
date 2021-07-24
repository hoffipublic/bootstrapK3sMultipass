# shellcheck shell=bash

# variables to check if already sourced have to be UNIQUE WITHIN THE WHOLE PROJECT!
if [[ ${HAS_ALREADY_BEEN_SOURCED__30_k3sVars:=1} = 0 ]]; then return ; fi
HAS_ALREADY_BEEN_SOURCED__30_k3sVars=0 # indicate that this file has been sourced
TRACE "sourcing lib/30_k3sVars.sh"

K3S_BINDIR=/usr/local/bin
K3S_CONFDIR=/etc/rancher/k3s/
K3S_CLUSTER_ROOTCA="${TMPDIR}/certs/K3S_root.ca"

TRACE "sourced lib/30_k3sVars.sh done."
