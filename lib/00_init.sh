#!/usr/bin/env bash
# this file is only to be sourced, not executed

# variables to check if already sourced have to be UNIQUE WITHIN THE WHOLE PROJECT!
if [[ ${HAS_ALREADY_BEEN_SOURCED__00_init:=1} = 0 ]]; then return ; fi
HAS_ALREADY_BEEN_SOURCED__00_init=0 # indicate that this file has been sourced

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
REPODIR=${SCRIPTDIR%/*}

cd "${REPODIR}" || exit

dateExe="date"
if [[ $(uname) == "Darwin" ]]; then
 dateExe="gdate"
fi
STARTTIMEMILLIS=$(($($dateExe +'%s%N') / 1000000)) # datetime from nano seconds to in milliseconds
STARTDATE=$($dateExe +'%Y-%m-%d')
STARTTIME=$($dateExe +'%H:%M:%S')

## generate needed transient directories
export GENERATEDDIR="${REPODIR}/generated"
mkdir -p generated/conf/bash
mkdir -p generated/conf/ytt
mkdir -p tmp

function stripRepoDir() {
    local callingScript
    #echo "DEBUG: ${BASH_SOURCE[*]}"
    #callingScript="${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}" # last element of BASH_SOURCE array
    callingScript="$*"
    callingScript="${callingScript#$REPODIR}" # cut off beginning REPODIR path (if there)
    callingScript="${callingScript#/}" # cut off trailing slash (if any)
    echo -n -e "${callingScript}"
}
if [[ ${BASH_SOURCE[1]:0:1} = '/' ]]; then # should only be printed out if a script executes (not sourceing) another script
    echo "sourcing lib/00_init.sh (because script was executed, not sourced in $(stripRepoDir ${BASH_SOURCE[1]}))"
fi

export COLOR_RESET='\e[0m' # No COL
export COLOR_WHITE='\e[1;37m'
export COLOR_BACK_WHITE='\e[0;47m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BACK_BLACK='\e[0;40m'
export COLOR_BLUE='\e[0;34m'
export COLOR_BACK_BLUE='\e[0;44m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_BACK_LIGHT_BLUE='\e[1;104m'
export COLOR_GREEN='\e[0;32m'
export COLOR_BACK_GREEN='\e[0;42m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_BACK_CYAN='\e[0;46m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_BACK_RED='\e[0;41m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_BACK_PURPLE='\e[0;45m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_BACK_YELLOW='\e[1;43m'
export COLOR_GRAY='\e[0;30m'
export COLOR_LIGHT_GRAY='\e[0;37m'
export COLOR_BACK_GRAY='\e[1;40m'

function color() {
    local theColor=$1 ; shift
    if [[ $OPT_NO_COLOR = true ]]; then echo -n "$*" ; return ; fi
    case $theColor in
        'white'|'WHITE')
            echo -n -e "${COLOR_WHITE}$*${COLOR_RESET}"
            ;;
        'black'|'BLACK')
            echo -n -e "${COLOR_BLACK}$*${COLOR_RESET}"
            ;;
        'blue'|'BLUE')
            echo -n -e "${COLOR_BLUE}$*${COLOR_RESET}"
            ;;
        'lightblue'|'LIGHTBLUE')
            echo -n -e "${COLOR_LIGHT_BLUE}$*${COLOR_RESET}"
            ;;
        'green'|'GREEN')
            echo -n -e "${COLOR_GREEN}$*${COLOR_RESET}"
            ;;
        'lightgreen'|'LIGHTGREEN')
            echo -n -e "${COLOR_LIGHT_GREEN}$*${COLOR_RESET}"
            ;;
        'cyan'|'CYAN')
            echo -e "${COLOR_CYAN}$*${COLOR_RESET}"
            ;;
        'lightcyan'|'LIGHTCYAN')
            echo -n -e "${COLOR_LIGHT_CYAN}$*${COLOR_RESET}"
            ;;
        'red'|'RED')
            echo -e "${COLOR_RED}$*${COLOR_RESET}"
            ;;
        'lightred'|'LIGHTRED')
            echo -n -e "${COLOR_LIGHT_RED}$*${COLOR_RESET}"
            ;;
        'purple'|'PURPLE')
            echo -n -e "${COLOR_PURPLE}$*${COLOR_RESET}"
            ;;
        'lightpurple'|'LIGHTPURPLE')
            echo -n -e "${COLOR_LIGHT_PURPLE}$*${COLOR_RESET}"
            ;;
        'brown'|'BROWN')
            echo -n -e "${COLOR_BROWN}$*${COLOR_RESET}"
            ;;
        'yellow'|'YELLOW')
            echo -n -e "${COLOR_YELLOW}$*${COLOR_RESET}"
            ;;
        'gray'|'GRAY')
            echo -n -e "${COLOR_GRAY}$*${COLOR_RESET}"
            ;;
        'lightgray'|'LIGHTGRAY')
            echo -n -e "${COLOR_LIGHT_GRAY}$*${COLOR_RESET}"
            ;;
        *)
            echo -n "UNKNOWN COLOR '${theColor}': $*"
            ;;
    esac
}

function timeElapsed() {
    local ms sec min hours elapsedTime
    local msStr secStr minStr hoursStr
    
    elapsedTime=$(( $($dateExe +'%s%N') / 1000000 - STARTTIMEMILLIS ))
    #fake=$(( $((222 * 3600 * 1000)) + $((3 * 60 * 1000)) + $((4 * 1000)) + 876 ))
    #elapsedTime=$(( elapsedTime + fake ))

    ms=$((elapsedTime % 1000))
    msStr=$(printf "%03d" $ms)
    sec=$((elapsedTime / 1000))
    secStr=$(printf "%02d" $((sec % 60)) )
    min=$((sec / 60))
    minStr=$(printf "%02d" $((min % 60)) )
    hours=$((min / 60))
    [[ hours -gt 0 ]]; hasHours=$?

    if [[ $hasHours -eq 0 ]]; then
        printf "%sh:%sm:%ss,%s" "$hours" "$minStr" "$secStr" "$msStr"
    else
        printf "%sm:%ss,%s" "$minStr" "$secStr" "$msStr"
    fi
}

finish() {
    errorcode=$?
    set +eux # turn off flags
    local from
    from=$(stripRepoDir ${BASH_SOURCE[1]})
    if [[ errorcode -eq 0 ]]; then
        INFO "finish() ok! ($from) elapsedTime: $(timeElapsed)"
    else
        FATAL "$from finish() abnormaly!  elapsedTime: $(timeElapsed) (errorcode: $errorcode)"
    fi
    return $errorcode
}


trap finish EXIT
set -e # exit the script on first error (command not returning $?=0)
set -u # errors if an variable is referenced before being set


declare -A LOGLEVELSHASH=( 
 [FATAL]=1  [ERROR]=2  [WARN]=3  [INFO]=4  [DEBUG]=5  [FINE]=6 [FINER]=7 [FINEST]=8 [TRACE]=9 [ALL]=10
)
set +u
if [[ -z $LOGLEVEL ]]; then LOGLEVEL="INFO" ; fi
LOGLEVELINT=${LOGLEVELSHASH[$LOGLEVEL]}
set -u

function LOGPrefix() {
    local logLevel
    local callingScript
    logLevel="$1"
    if [[ -z $logLevel ]]; then logLevel="INFO" ; fi
    callingScript="$(stripRepoDir "${BASH_SOURCE[2]}")"
    printf "$($dateExe +'%H:%M:%S') %5s $(timeElapsed) ${callingScript} |  " ${logLevel}
}
function LOGMessage() {
    if [[ $OPT_NO_COLOR = true ]]; then
        echo -n "$*"
    else
        color LIGHTGRAY "$*"
    fi
}
function TRACE() {
    local logLevel="TRACE" ; if [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    >&2 printf "$($dateExe +'%H:%M:%S') %5s $(timeElapsed) $*\n" "TRACE"
}
function FINEST() {
    local logLevel="FINEST" ; if [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    >&2 printf "%s\n" "$(LOGPrefix FINEST)$*"
}
function FINER() {
    local logLevel="FINER" ; if [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    >&2 printf "%s\n" "$(LOGPrefix FINER)$*"
}
function FINE() {
    local logLevel="FINE" ; if [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    >&2 printf "%s\n" "$(LOGPrefix FINE)$*"
}
function DEBUG() {
    local logLevel="DEBUG" ; if [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    >&2 printf "%s\n" "$(LOGPrefix DEBUG)$(LOGMessage "$@")"
}
function INFO() {
    local logLevel="INFO" ; if [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    printf "%s\n" "$(LOGPrefix INFO)$(LOGMessage "$@")"
}
function INFOHIGHLIGHT() {
    local logLevel="INFO" ; if [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    printf "%s\n" "$(color LIGHTGRAY "$(LOGPrefix INFO)")$(LOGMessage "$@")"
}
function WARN() {
    local logLevel="WARN" ; if [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    printf "%s\n" "$(LOGPrefix WARN)$(LOGMessage "$@")"
}
function ERROR() {
    local logLevel="ERROR" ; if [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    printf "%s\n" "$(LOGPrefix ERROR)$(LOGMessage "$@")"
}
function FATAL() {
    local logLevel="FATAL" ; if [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    printf "%s\n" "$(color RED "$(LOGPrefix FATAL)$*")"
}
function setLogLevel() {
    local tmp
    tmp=${LOGLEVELSHASH[$1]}
    if [[ $tmp = '' ]]; then
        WARN "unknown LOGLEVEL '$1'"
    else
        LOGLEVEL=$tmp
        LOGLEVELINT=${LOGLEVELSHASH[$1]}
    fi
}

TRACE "SCRIPTDIR: ${SCRIPTDIR}"
TRACE "REPODIR:   ${REPODIR}"

echo > "${GENERATEDDIR}/conf/bash/conf.sh" # erase file contents
echo > "${GENERATEDDIR}/conf/ytt/conf.yml" # erase file contents
for confFile in ${REPODIR}/conf/*.yml ${REPODIR}/conf/*.yaml; do
    {
        echo -e "#! from $(stripRepoDir ${confFile})"
        echo -e "#@overlay/match-child-defaults missing_ok=True"
        echo -e "#@data/values"
        cat "${confFile}"
        echo -e ""
    } >> "${GENERATEDDIR}/conf/ytt/conf.yml"
    # convert to json --> flatten hierarchy --> convert to bash var exports
    {
        echo -e "## from $(stripRepoDir ${confFile})"
        ytt -f "${confFile}" -o json \
        | jq '[leaf_paths as $path | {"key": $path | join("__"), "value": getpath($path)}] | from_entries' \
        | yq eval --prettyPrint '.' - \
        | yq eval '.. style="single"' - \
        | sed -E "s/^([^:]+): (.*)/export \1=\2/"
    } >> "${GENERATEDDIR}/conf/bash/conf.sh"
done
source "${GENERATEDDIR}/conf/bash/conf.sh"

TRACE "sourced lib/00_init.sh now sourcing all other lib/*.sh ..."
for libFile in ${REPODIR}/lib/*.sh; do source $libFile ; done
TRACE "sourced lib/00_init.sh done."
