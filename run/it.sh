#!/usr/bin/env bash
ranOrSourced=$([[ $_ != $0 ]] && echo "source" || echo -n "exec") # has to be first line of script
TRACING+=("run/it.sh")
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPTDIR}/0BootstrapFuncs.sh"
if [[ -z $1 ]] && fzf --version >/dev/null 2>&1 ; then fzfArg="$(echo -e "localK3s\nHetzner" | fzf +s --ansi) " ; fi
echo $fzfArg
source "${SCRIPTDIR}/$(backToRepoDir "${TRACING[-1]}")/lib/00_init.sh" "$fzfArg$@"
TRACE "${ranOrSourced} ${TRACING[-1]} $* ..."
## ===========================================================================

# bash -c -- "LOGLEVEL=TRACE source lib/00_init.sh localK3s"

cmd="LOGLEVEL=DEBUG source ${ARGS[@]}"
echo "$cmd"
eval "$cmd"


## ===========================================================================
TRACE "run/it.sh done."
