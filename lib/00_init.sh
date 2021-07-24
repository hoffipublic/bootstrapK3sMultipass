# shellcheck shell=bash

# variables to check if already sourced have to be UNIQUE WITHIN THE WHOLE PROJECT!
if [[ ${HAS_ALREADY_BEEN_SOURCED__00_init:=1} = 0 ]]; then return ; fi
HAS_ALREADY_BEEN_SOURCED__00_init=0 # indicate that this file has been sourced

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
REPODIR=${SCRIPTDIR%/*}

cd "${REPODIR}" || exit

dateExe="date"
sedExe="sed"
if [[ $(uname) == "Darwin" ]]; then
 dateExe="gdate"
 sedExe="gsed"
fi
STARTTIMEMILLIS=$(($($dateExe +'%s%N') / 1000000)) # datetime from nano seconds to in milliseconds
STARTDATE=$($dateExe +'%Y-%m-%d')
STARTTIME=$($dateExe +'%H:%M:%S')
FILE_DATETIME="$(date +%Y%m%d_%H%M%S)"
FILEPOSTFIX_STARTDATETIME="${FILE_DATETIME}"

function upperFirstChar() {
    local s="$*"
    echo -n "${s^}"
}
function lowerFirstChar() {
    local s="$*"
    echo -n "${s,}"
}
function stripRepoDir() {
    local callingScript
    #echo "DEBUG: ${BASH_SOURCE[*]}"
    #callingScript="${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}" # last element of BASH_SOURCE array
    callingScript="$*"
    callingScript="${callingScript#$REPODIR}" # cut off beginning REPODIR path (if there)
    callingScript="${callingScript#/}" # cut off trailing slash (if any)
    echo -n -e "${callingScript}"
}

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

if [[ ${BASH_SOURCE[1]:0:1} = '/' ]]; then # should only be printed out if a script executes (not sourceing) another script
    echo -e "${COLOR_RED}sourcing lib/00_init.sh (because script was executed, not sourced in $(stripRepoDir ${BASH_SOURCE[1]}))${COLOR_RESET}"
fi

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
        printf "$(color LIGHTGRAY $($dateExe +'%H:%M:%S') %5s $(timeElapsed) finish\(\) $from ok!  elapsedTime: $(timeElapsed)\\n)" "INFO" 
    else
        printf "$(color RED $($dateExe +'%H:%M:%S') %5s $(timeElapsed) finish\(\) $from abnormaly!  elapsedTime: $(timeElapsed) \(errorcode: $errorcode\)\\n)" "FATAL" 
    fi
    return $errorcode
}


trap finish EXIT
# set -E # better ERR trap handling
# set -e # exit the script on first error (command not returning $?=0)
# set -u # errors if an variable is referenced before being set
# set -o pipefail # fail fast if an erroneous command pipes to downstream commands
export DEFAULT_SHELLOPTS="-Eeuo pipefail" # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set ${DEFAULT_SHELLOPTS}



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
    local logLevel="FINEST" ; if [[ ! -z $LOGLEVELINT ]] && [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    >&2 printf "%s\n" "$(LOGPrefix FINEST)$*"
}
function FINER() {
    local logLevel="FINER" ; if [[ ! -z $LOGLEVELINT ]] && [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    >&2 printf "%s\n" "$(LOGPrefix FINER)$*"
}
function FINE() {
    local logLevel="FINE" ; if [[ ! -z $LOGLEVELINT ]] && [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    >&2 printf "%s\n" "$(LOGPrefix FINE)$*"
}
function DEBUG() {
    local logLevel="DEBUG" ; if [[ ! -z $LOGLEVELINT ]] && [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    >&2 printf "%s\n" "$(LOGPrefix DEBUG)$(LOGMessage "$@")"
}
function INFO() {
    local logLevel="INFO" ; if [[ ! -z $LOGLEVELINT ]] && [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    printf "%s\n" "$(LOGPrefix INFO)$(LOGMessage "$@")"
}
function INFOHIGHLIGHT() {
    local logLevel="INFO" ; if [[ ! -z $LOGLEVELINT ]] && [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    printf "%s\n" "$(color LIGHTGRAY "$(LOGPrefix INFO)")$(LOGMessage "$@")"
}
function CALLINFO() {
    printf "%s\n" "$(color GREEN "$@")"
}
function WARN() {
    local logLevel="WARN" ; if [[ ! -z $LOGLEVELINT ]] && [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    printf "%s\n" "$(LOGPrefix WARN)$(LOGMessage "$@")"
}
function ERROR() {
    local logLevel="ERROR" ; if [[ ! -z $LOGLEVELINT ]] && [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
    printf "%s\n" "$(LOGPrefix ERROR)$(LOGMessage "$@")"
}
function FATAL() {
    local logLevel="FATAL" ; if [[ ! -z $LOGLEVELINT ]] && [[ ${LOGLEVELSHASH[$logLevel]} -gt $LOGLEVELINT ]]; then return ; fi
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

if [[ ! ${HAS_ALREADY_BEEN_SOURCED__1ParseCmdLineArgs:=1} = 0 ]]; then source "${REPODIR}/run/1ParseCmdLineArgs.sh" ; fi

## generate needed transient directories
export CACHEDIR=cache
mkdir -p cache
export GENERATEDDIR=generated/${targetEnvSmallCaps}
export GENCONFDIR=${GENERATEDDIR}/conf
mkdir -p ${GENCONFDIR}/bash
mkdir -p ${GENCONFDIR}/ytt
export GENYTTDIR=${GENERATEDDIR}/ytt
mkdir -p ${GENYTTDIR}
export TMPDIR=tmp/${targetEnvSmallCaps}
mkdir -p ${TMPDIR}

shopt -s nullglob

INFOHIGHLIGHT "targetEnv: ${targetEnvSmallCaps}"
TRACE "SCRIPTDIR: ${SCRIPTDIR}"
TRACE "REPODIR:   ${REPODIR}"


echo > "${GENCONFDIR}/bash/conf.sh" # erase file contents
echo > "${GENCONFDIR}/ytt/conf.yml" # erase file contents
for confFile in ${REPODIR}/conf/*.yml ${REPODIR}/conf/*.yaml ${REPODIR}/conf/${targetEnvSmallCaps}/*.yml ${REPODIR}/conf/${targetEnvSmallCaps}/*.yaml; do
    {
        echo -e "#! from $(stripRepoDir ${confFile})"
        echo -e "#@overlay/match-child-defaults missing_ok=True"
        echo -e "#@data/values"
        cat "${confFile}"
        echo -e ""
    } >> "${GENCONFDIR}/ytt/conf.yml"
    # convert to json --> flatten hierarchy --> convert to bash var exports
    {
        echo -e "## from $(stripRepoDir ${confFile})"
        ytt -f "${confFile}" -o json \
        | jq '[leaf_paths as $path | {"key": $path | join("__"), "value": getpath($path)}] | from_entries' \
        | yq eval --prettyPrint '.' - \
        | yq eval '.. style="single"' - \
        | sed -E "s/^([^:]+): (.*)/export \1=\2/"
    } >> "${GENCONFDIR}/bash/conf.sh"
done

case $(uname) in
  'Linux')
    HOSTNIC=$(route | grep '^default' | grep -o '[^ ]*$')
    HOSTIP=$(ifconfig "${HOSTNIC}" | sed -n -E 's/^.*inet ([0-9.]+).*$/\1/p')
    ;;
  'FreeBSD')
    HOSTNIC=$(route | grep '^default' | grep -o '[^ ]*$')
    HOSTIP=$(ifconfig "${HOSTNIC}" | sed -n -E 's/^.*inet ([0-9.]+).*$/\1/p')
    ;;
  'WindowsNT')
    HOSTNIC=unknown
    HOSTIP=unknown
    ;;
  'Darwin')
    HOSTNIC=$(route get example.com | sed -n -E 's/^ *interface: (.*)$/\1/p')
    HOSTIP=$(ifconfig "${HOSTNIC}" | sed -n -E 's/^.*inet ([0-9.]+).*$/\1/p')
    ;;
  *) ;;
esac

echo "#! from lib/00_init.sh
#@overlay/match-child-defaults missing_ok=True
#@data/values
---
HOSTIP: ${HOSTIP}
DNSSERVER: ${HOSTIP} #! same as HOSTIP if using dnsmasq on host
" >> "${GENCONFDIR}/ytt/conf.yml"
echo "#! from lib/00_init.sh
export HOSTIP=${HOSTIP}
export DNSSERVER=${HOSTIP} #! same as HOSTIP if using dnsmasq on host
" >> "${GENCONFDIR}/bash/conf.sh"


source "${GENCONFDIR}/bash/conf.sh"

set ${DEFAULT_SHELLOPTS}

TRACE "sourced lib/00_init.sh now sourcing all other lib/*.sh ..."
for libFile in ${REPODIR}/lib/*.sh; do source $libFile ; done
TRACE "sourced lib/00_init.sh done."
