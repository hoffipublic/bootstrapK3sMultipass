#!/usr/bin/env bash
# this file is only to be sourced, not executed

# variables to check if already sourced have to be UNIQUE WITHIN THE WHOLE PROJECT!
if [[ ${HAS_ALREADY_BEEN_SOURCED__10_globalVars:=1} = 0 ]]; then return ; fi
HAS_ALREADY_BEEN_SOURCED__10_globalVars=0 # indicate that this file has been sourced
TRACE "sourcing lib/10_globalVars.sh"


aGlobalVar="ThisIsAGlobalVar"

TRACE "sourced lib/10_globalVars.sh done."
