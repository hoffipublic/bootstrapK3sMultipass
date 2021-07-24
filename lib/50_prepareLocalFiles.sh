# shellcheck shell=bash

# variables to check if already sourced have to be UNIQUE WITHIN THE WHOLE PROJECT!
if [[ ${HAS_ALREADY_BEEN_SOURCED__50_prepareLocalFiles:=1} = 0 ]]; then return ; fi
HAS_ALREADY_BEEN_SOURCED__50_prepareLocalFiles=0 # indicate that this file has been sourced
TRACE "sourcing lib/50_prepareLocalFiles.sh"

function fileAppendSentinelsIfAbsent() {
    local SENTINELSTART="#BEGIN MARKER used for automation, DO NOT CHANGE this comment line"
    local SENTINELENDIN="#ENDIN MARKER used for automation, DO NOT CHANGE this comment line"
    local file="$1"
    if ! grep -E "^${SENTINELSTART}" "${file}" >/dev/null 2>&1 ; then
        { echo
          echo $SENTINELSTART
          echo $SENTINELENDIN
        } >> "${file}"
    fi
}
function fileLineExistsBetweenSentinels() {
    local SENTINELSTART="#BEGIN MARKER used for automation, DO NOT CHANGE this comment line"
    local SENTINELENDIN="#ENDIN MARKER used for automation, DO NOT CHANGE this comment line"
    local match=$1
    local file=$2
    local sedExe
    if gsed --version >/dev/null 2>&1 ; then sedExe="gsed" ; else sedExe="sed" ; fi
    $sedExe -n "/^${SENTINELSTART}/,/${SENTINELENDIN}/p" "${file}" | grep "${match}" >/dev/null
}
function fileAppendBetweenSentinels() {
    local SENTINELENDIN="#ENDIN MARKER used for automation, DO NOT CHANGE this comment line"
    local line=$1
    local file=$2
    local sedExe
    if gsed --version >/dev/null 2>&1 ; then sedExe="gsed" ; else sedExe="sed" ; fi
    $sedExe -i "/^${SENTINELENDIN}/i ${line}" "${file}"
}
function filePrependBetweenSentinels() {
    local SENTINELSTART="#BEGIN MARKER used for automation, DO NOT CHANGE this comment line"
    local line=$1
    local file=$2
    local sedExe
    if gsed --version >/dev/null 2>&1 ; then sedExe="gsed" ; else sedExe="sed" ; fi
    $sedExe -i "/^${SENTINELSTART}/a ${line}" "${file}"
}
function fileReplaceBetweenSentinels() {
    # http://fahdshariff.blogspot.com/2012/12/sed-mutli-line-replacement-between-two.html
    local SENTINELSTART="#BEGIN MARKER used for automation, DO NOT CHANGE this comment line"
    local SENTINELENDIN="#ENDIN MARKER used for automation, DO NOT CHANGE this comment line"
    local match=$1
    local replace=$2
    local file=$3
    local sedExe
    if gsed --version >/dev/null 2>&1 ; then sedExe="gsed" ; else sedExe="sed" ; fi
    $sedExe -i "/^${SENTINELSTART}/,/^${SENTINELENDIN}/{/${SENTINELSTART}/n;/${SENTINELENDIN}/!{s/${match}/${replace}/g}}" "$file"
}
function fileDeleteLinesBetweenSentinels() {
    local SENTINELSTART="#BEGIN MARKER used for automation, DO NOT CHANGE this comment line"
    local SENTINELENDIN="#ENDIN MARKER used for automation, DO NOT CHANGE this comment line"
    local match=$1
    local file=$2
    local sedExe
    if gsed --version >/dev/null 2>&1 ; then sedExe="gsed" ; else sedExe="sed" ; fi
    $sedExe -i "/^${SENTINELSTART}/,/^${SENTINELENDIN}/{/${SENTINELSTART}/n;/${SENTINELENDIN}/!{/${match}/d}}" "$file"
}
function fileDeleteAllBetweenSentinels() {
    local SENTINELSTART="#BEGIN MARKER used for automation, DO NOT CHANGE this comment line"
    local SENTINELENDIN="#ENDIN MARKER used for automation, DO NOT CHANGE this comment line"
    local file=$1
    local sedExe
    if gsed --version >/dev/null 2>&1 ; then sedExe="gsed" ; else sedExe="sed" ; fi
    $sedExe -i "/^${SENTINELSTART}/,/^${SENTINELENDIN}/{//!d}" "${file}"
}
function fileDeleteAllBetweenSentinelsIncludingSentinels() {
    local SENTINELSTART="#BEGIN MARKER used for automation, DO NOT CHANGE this comment line"
    local SENTINELENDIN="#ENDIN MARKER used for automation, DO NOT CHANGE this comment line"
    local file=$1
    local sedExe
    if gsed --version >/dev/null 2>&1 ; then sedExe="gsed" ; else sedExe="sed" ; fi
    $sedExe -i "/^${SENTINELSTART}/,/${SENTINELENDIN}/d" "${file}"
}


sudoFunc fileAppendSentinelsIfAbsent /etc/hosts
sudoFunc fileAppendSentinelsIfAbsent /usr/local/etc/dnsmasq.conf


TRACE "sourced lib/50_prepareLocalFiles.sh done."
