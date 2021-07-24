#!/usr/bin/env bash
ranOrSourced=$([[ $_ != $0 ]] && echo "source" || echo -n "exec") # has to be first line of script
TRACING+=("run/test3.sh")
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPTDIR}/0BootstrapFuncs.sh"
source "${SCRIPTDIR}/$(backToRepoDir "${TRACING[-1]}")/lib/00_init.sh" "$@"
TRACE "${ranOrSourced} ${TRACING[-1]} $* ..."
## ===========================================================================


INFOHIGHLIGHT "in $(basename ${BASH_SOURCE[0]})"
for arg in "${ARGS[@]}" ; do INFO "'${arg}'"; done
INFO "echo --file ${OPT_FILE}"

function aNewFunc() {
    DEBUG "from within a func ${aGlobalVar}"
}

aNewFunc

## ===========================================================================
TRACE "run/test3.sh done."