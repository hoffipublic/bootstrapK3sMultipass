# shellcheck shell=bash

# variables to check if already sourced have to be UNIQUE WITHIN THE WHOLE PROJECT!
if [[ ${HAS_ALREADY_BEEN_SOURCED__10_globalVars:=1} = 0 ]]; then return ; fi
HAS_ALREADY_BEEN_SOURCED__10_globalVars=0 # indicate that this file has been sourced
TRACE "sourcing lib/10_globalVars.sh"

NEED_TO_RESTART_DNSMASQ=false

# multipass cloud-config does not support packages module yet
aptPackages=( \
    "net-tools" \
    "fzf" \
    "silversearcher-ag" \
    "fd-find" \
    "git" \
    "jq" \

)
snapPackages=( \
    "yq" \
)
packagesCmdVersion=( \
    '"ifconfig --version"' \
    '"fzf --version"' \
    '"ag --version"' \
    '"fdfind --version"' \
    '"git --version"' \
    '"jq --version"' \
    '"yq --version"' \
)

TRACE "sourced lib/10_globalVars.sh done."
