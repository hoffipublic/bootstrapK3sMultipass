#!/usr/bin/env bash
ranOrSourced_test=$([[ $_ != $0 ]] && echo "source" || echo -n "exec") # has to be first line of script
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPTDIR}/../lib/00_init.sh"
TRACE "${ranOrSourced_test} run/test.sh ..."
## ===========================================================================

source "${REPODIR}/run/0ParseCmdLineArgs.sh"

INFOHIGHLIGHT "in $(basename ${BASH_SOURCE[0]})"
for arg in "${ARGS[@]}" ; do INFO "'${arg}'"; done
INFO "echo --file ${OPT_FILE}"

DEBUG "test before source   test2"
source ${REPODIR}/run/test2.sh
DEBUG "test after  source   test2"

DEBUG "test before run   test2"
${REPODIR}/run/test2.sh
DEBUG "test after  run   test2"

## ===========================================================================
TRACE "${ranOrSourced_test} run/test.sh done."