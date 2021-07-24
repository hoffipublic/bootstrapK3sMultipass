# shellcheck shell=bash

# variables to check if already sourced have to be UNIQUE WITHIN THE WHOLE PROJECT!
if [[ ${HAS_ALREADY_BEEN_SOURCED__60_k8sFuncs:=1} = 0 ]]; then return ; fi
HAS_ALREADY_BEEN_SOURCED__60_k8sFuncs=0 # indicate that this file has been sourced
TRACE "sourcing lib/60_k8sFuncs.sh"

## kubewaitPodRunning -n namespace -l label=labelvalue 'podnamesRegex' <sleepBetweenTries(5)> <timesToTry(10)> <sleepAfterSuccess(0)>
function kubewaitPodRunning() {
    set +e
    local namespace
    namespace=""
    local label
    label=""
    while [[ ${1:0:1} = "-" ]]; do
        if [[ "$1" = "-n" ]]; then namespace="-n $2"; shift ; shift ; fi
        if [[ "$1" = "-l" ]]; then label="-l $2"; shift ; shift ; fi
    done
    local podnamesRegex
    set +u
    podnamesRegex="$1"
    if [[ $podnamesRegex == ".*" || $podnamesRegex == "*" ]]; then podnamesRegex="[a-zA-Z0-9-]*"; fi
    local initialSleeptime
    initialSleeptime=1 ;  if [[ -n $2 ]]; then initialSleeptime=$2 ; fi
    local sleepBetweenTries
    sleepBetweenTries=5 ; if [[ -n $3 ]]; then sleepBetweenTries=$3 ; fi
    local timesToTry
    timesToTry=10 ;       if [[ -n $4 ]]; then timesToTry=$4 ; fi
    local sleepAfterSuccess
    sleepAfterSuccess=0 ; if [[ -n $5 ]]; then sleepAfterSuccess=$5 ; fi
    set -u
    echo "initial:$initialSleeptime betweenTries:$sleepBetweenTries times:$timesToTry after:$sleepAfterSuccess"

    sleep "${initialSleeptime}"
    for ((i = 1; i <= timesToTry; ++i)); do
        echo "waited $(( (i - 1) * sleepBetweenTries + initialSleeptime ))s : kubectl ${namespace} get pod ${label} | grep -E '^${podnamesRegex}'"
        local parsedLines
        parsedLines="$(kubectl ${namespace} get pod ${label} | sed -n -E "s/^(${podnamesRegex}[^ ]*) +([0-9]+)\\/([0-9]+) +([^ ]+).*$/\\1 \\2 \\3 \\4/p")"
        local line
        local podname
        local ready
        local readyExpected
        local status
        local allRunningAndReady
        allRunningAndReady=true
        while IFS= read -r line; do
            podname="$(awk '{print $1}' <<< $line)"
            ready="$(awk '{print $2}' <<< $line)"
            readyExpected="$(awk '{print $3}' <<< $line)"
            status="$(awk '{print $4}' <<< $line)"
            if [[ $status != "Running" ||  $ready -ne $readyExpected ]]; then
                allRunningAndReady=false
                break
            fi
        done <<< "${parsedLines}"

        if $allRunningAndReady ; then
            echo "pod(s) ${label} ${podnamesRegex} Running and ready"
            sleep "${sleepAfterSuccess}"
            set ${DEFAULT_SHELLOPTS}
            return 0
        elif [[ ${timesToTry} -eq ${i} ]]; then
            error "kubewaitPodRunning did not succeed after ${initialSleeptime}s + ${timesToTry} * ${sleepBetweenTries}s waiting for : kubectl ${namespace} get pod ${label} | grep -E '^${podnamesRegex}'"
            set ${DEFAULT_SHELLOPTS}
            return 1
        fi
        sleep "${sleepBetweenTries}"
    done
}
export -f kubewaitPodRunning



TRACE "sourced lib/60_k8sFuncs.sh done."
