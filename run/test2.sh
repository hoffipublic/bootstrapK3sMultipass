#!/usr/bin/env bash
ranOrSourced=$([[ $_ != $0 ]] && echo "source" || echo -n "exec") # has to be first line of script
TRACING+=("run/test2.sh")
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPTDIR}/0BootstrapFuncs.sh"
source "${SCRIPTDIR}/$(backToRepoDir "${TRACING[-1]}")/lib/00_init.sh" "$@"
TRACE "${ranOrSourced} ${TRACING[-1]} $* ..."
## ===========================================================================


INFOHIGHLIGHT "in $(basename ${BASH_SOURCE[0]})"
for arg in "${ARGS[@]}" ; do INFO "'${arg}'"; done
INFO "echo --file ${OPT_FILE}"

DEBUG "test2 with ${aGlobalVar}"

function aNewFunc() {
    DEBUG "from within a func ${aGlobalVar}"
}

aNewFunc


DEBUG "test before source   test3"
source "${REPODIR}/run/test3.sh"
DEBUG "test after source    test3"

OLDLOGLEVEL=$LOGLEVEL
NEWLOGLEVEL=ALL
echo "$(color PURPLE "setting new logLevel: $NEWLOGLEVEL")"
setLogLevel $NEWLOGLEVEL
DEBUG "should be logged!!!"
TRACE "should be logged!!!"
FINE "should be logged!!!"
INFOHIGHLIGHT "highlighted info line islong='${islong}'"
FINER "should be logged!!!"
FINEST "should be logged!!!"
INFO "test before run    test3"
${REPODIR}/run/test3.sh "$targetEnvSmallCaps"
DEBUG "test after run    test3"
echo "$(color PURPLE "resetting logLevel to: $OLDLOGLEVEL")"
setLogLevel $OLDLOGLEVEL

## ===========================================================================
TRACE "run/test2.sh done."
