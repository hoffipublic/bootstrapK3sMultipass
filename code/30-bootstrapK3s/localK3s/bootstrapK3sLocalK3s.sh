#!/usr/bin/env bash
ranOrSourced=$([[ $_ != $0 ]] && echo "source" || echo -n "exec") # has to be first line of script
TRACING+=("code/30-bootstrapK3s/localK3s/bootstrapK3sLocalK3s.sh")
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPTDIR}/$(backToRepoDir "${TRACING[-1]}")/lib/00_init.sh" "$@"
TRACE "${ranOrSourced} ${TRACING[-1]} $* ..."
## ===========================================================================

# nothing yet

## ===========================================================================
TRACE "code/30-bootstrapK3s/localK3s/bootstrapK3sLocalK3s.sh done."