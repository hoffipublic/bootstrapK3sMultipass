#!/usr/bin/env bash
ranOrSourced=$([[ $_ != $0 ]] && echo "source" || echo -n "exec") # has to be first line of script
TRACING+=("code/10-bootstrapInfra/bootstrapInfraCommon.sh")
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPTDIR}/$(backToRepoDir "${TRACING[-1]}")/lib/00_init.sh" "$@"
TRACE "${ranOrSourced} ${TRACING[-1]} $* ..."
## ===========================================================================

bootstrapInfraBaseDir="code/10-bootstrapInfra/${targetEnvSmallCaps}"
source "${bootstrapInfraBaseDir}/bootstrapInfra${targetEnv}.sh"


## ===========================================================================
TRACE "code/10-bootstrapInfra/bootstrapInfraCommon.sh done."