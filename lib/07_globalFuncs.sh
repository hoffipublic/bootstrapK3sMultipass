# shellcheck shell=bash

# variables to check if already sourced have to be UNIQUE WITHIN THE WHOLE PROJECT!
if [[ ${HAS_ALREADY_BEEN_SOURCED__05_globalFuncs:=1} = 0 ]]; then return ; fi
HAS_ALREADY_BEEN_SOURCED__05_globalFuncs=0 # indicate that this file has been sourced
TRACE "sourcing lib/07_globalFuncs.sh"

function quoteArgs() {
    # get quoted arr with: arr=$(quoteArgs one "two three" four)
    echo -n "${@@Q}"
}

function sudoFunc() {
    local funcName=$1 ; shift
    declare -f "$funcName" > "${TMPDIR}/FUNCDEF.sh"
    echo "$funcName $(for arg in "$@"; do echo -n "'$arg' " ; done)" >> "${TMPDIR}/FUNCDEF.sh"
    sudo bash -c "source ${TMPDIR}/FUNCDEF.sh"
}

function call() {
    >&2 CALLINFO "$@"
    eval "${@@Q}"
}
function callYtt() {
    cmd="ytt $(printf -- "-f '%s' " "${YTT_FILES[@]}") ${YTT_OPTS}"
    >&2 CALLINFO "$cmd"
    eval "${cmd}"
}


TRACE "sourced lib/07_globalFuncs.sh done."

