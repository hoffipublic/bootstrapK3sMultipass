#!/usr/bin/env bash
# this file is only to be sourced, not executed

# variables to check if already sourced have to be UNIQUE WITHIN THE WHOLE PROJECT!
if [[ ${HAS_ALREADY_BEEN_SOURCED__15_commonVars:=1} = 0 ]]; then return ; fi
HAS_ALREADY_BEEN_SOURCED__15_commonVars=0 # indicate that this file has been sourced
TRACE "sourcing lib/15_commonVars.sh"

aCommonVar=aCommonVarValue

TRACE "sourced lib/15_commonVars.sh done."
