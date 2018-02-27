#!/usr/bin/env bash
#
# Example bash script showcasing different cases of how to do things

# default script settings
# * fail immediately on the first error occuring
# * fail also if the call to nested functions fails
# * fail if unset variables are used
set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

# global exports ans paths
export PATH=$PATH

readonly DATE='date +%Y/%m/%d:%H:%M:%S'
readonly LOGFILE=>&1
readonly SEVERITY=INFO
# INFO
# NOTICE
# WARNING
# ERROR
# CRITICAL

# ------------------------------
# log
# Globals:
#   LOGFILE
#   SEVERITY
# Arguments:
#   msg: the string message to log
#   severity: the severity of the message. Default is $SEVERITY
# Returns:
#   None
# ------------------------------
function log() {
    local msg="${1}"
    local severity="${2:-$SEVERITY}"

    case $severity in
        INFO)
            echo "$(tput setaf 2)["`${DATE}]`" $msg $(tput sgr0)" $LOGFILE;;
        NOTICE)
            echo "$(tput setaf 4)["`${DATE}]`" $msg $(tput sgr0)" $LOGFILE;;
        WARNING)
            echo "$(tput setaf 3)["`${DATE}]`" $msg $(tput sgr0)" $LOGFILE;;
        ERROR)
            echo "$(tput setaf 1)["`${DATE}]`" $msg $(tput sgr0)" $LOGFILE;;
        CRITICAL)
            echo "$(tput setaf 6)["`${DATE}]`" $msg $(tput sgr0)" $LOGFILE;;
        *)
            echo "$(tput setaf 7)["`${DATE}]`" $severity $msg $(tput sgr0)" $LOGFILE;;
    esac
}

# set exit actions even for the error situation
trap "log 'thanks for using this script'" 0

function err_report() {
    log "errexit on line $(caller)" ERROR
}
trap err_report ERR

# get your own absolute directory location
BASH_SRC="${BASH_SOURCE[0]}"
while [ -h "$BASH_SRC" ]; do  # follow if source is symlink
    ABS_DIR="$( cd -P $(dirname "$BASH_SRC") && pwd)" # get dirname of parent
    BASH_SRC="$(readlink "$BASH_SRC")"
    [[ $BASH_SRC != /* ]] && BASH_SRC="$ABS_DIR/$BASH_SRC"
done
ABS_DIR="$(cd -P $(dirname "$BASH_SRC") && pwd)"
log "absolute directory is: $ABS_DIR"

# argc and argv logging
log "argc \$#: $#" 

# argv needs to be written to a string, because it will be passed as multiple 
# parameters which does not work with the log function.
# passing "$@" expands to "$1" "$2" ...
all=$(printf "%s" "$@")
log "argv \$@: $all" 

# apply passed params to variables
scriptname=$0
var1=$1
var2=$2
var3=$3
# ...

# read command line params
read -p "Enter some value: " x
read -p "Enter other value: " y

# check if program dependencies exist
command -v which > /dev/null 2>&1 || { 
    log "Require xx to be there." ERROR; 
    exit 1; 
}

# simple function definition
function foo() {    
    log "foo function"
}
foo

# simple function with parameters.
# function receices a count and lenght like the whole script
# !!! $0 is still the script name, so it starts with $1 !!!
function bar() {
    log "local bar variables:"
    log "\$#: $#"
    log "\$@: $@"
    log "\$0: $0"
    log "\$1: $1"

    # script will fail here due to 'set -o nounset'
    log "\$2: $2"
}

# this can test nicely and exit with the error trap
# we simply test the return for a zero value
test -z "$(bar 5)" || { 
    log "the call to bar went wrong" ERROR; false; 
}

# this too, but does not include the nice message
ret=$(bar 5)

log "thanks for learning bash ... bye"

exit 0

# vim: ft=sh sw=4 ts=4 sts=4 et nowrap:

