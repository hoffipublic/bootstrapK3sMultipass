#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

LOGLEVEL=DEBUG $SCRIPTDIR/test.sh $@
