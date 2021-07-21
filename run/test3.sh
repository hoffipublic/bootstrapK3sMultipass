#!/usr/bin/env bash
ranOrSourced_test3=$([[ $_ != $0 ]] && echo "source" || echo -n "exec") # has to be first line of script
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPTDIR}/../lib/00_init.sh"
TRACE "${ranOrSourced_test3} run/test3.sh"
## ===========================================================================

INFOHIGHLIGHT "in $(basename ${BASH_SOURCE[0]})"
for arg in "${ARGS[@]}" ; do INFO "'${arg}'"; done
INFO "echo --file ${OPT_FILE}"

function aNewFunc() {
    DEBUG "from within a func ${aGlobalVar}"
}

aNewFunc

## ===========================================================================
TRACE "${ranOrSourced_test3} run/test3.sh done."