# shellcheck shell=bash

function backToRepoDir() { # for each slash in $1-string a '../' (and cut off the last slash if there)
    local cdBackString=""
    set +u
    for ((i=0;i<$(echo "$*"  | tr -cd '/' | wc -c);i++)); do cdBackString="../$cdBackString" ; done
    set -u
    echo -n "${cdBackString::-1}" # cut off last character
}
