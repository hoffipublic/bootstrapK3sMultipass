#!/usr/bin/env bash
ranOrSourced=$([[ $_ != $0 ]] && echo "source" || echo -n "exec") # has to be first line of script
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TRACING+=("code/10-bootstrapInfra/localK3s/bootstrapInfraLocalK3s.sh")
source "${SCRIPTDIR}/$(backToRepoDir "${TRACING[-1]}")/lib/00_init.sh" "$@"
TRACE "${ranOrSourced} ${TRACING[-1]} $* ..."
## ===========================================================================

bootstrapInfraCommonBaseDir="code/10-bootstrapInfra/common"
source "${bootstrapInfraCommonBaseDir}/bootstrapInfraCommonCommon.sh" $K3SNODECOUNT $K3SNODENAMEPREFIX
K3SNODES=("${COMMONNODES[@]}")
K3SNODEIPS=("${COMMONNODEIPS[@]}")



## ===========================================================================
TRACE "code/10-bootstrapInfra/localK3s/bootstrapInfraLocalK3s.sh done."