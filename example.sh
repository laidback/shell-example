#!/usr/bin/env bash
#
# Example bash script showcasing different cases of how to do things

# default script settings
# * fail immediately on the first error occuring
# * allow clean trapping for ERR
# * fail also if the call to nested functions fails
# * fail if unset variables are used
set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

# global exports and paths
export PATH=$PATH

# check if program dependencies exist
command -v which > /dev/null 2>&1 || { log "Require xx to be there." ERROR; exit 1; }

# global logging settings
# possible severity values are: 
# * INFO, NOTICE, WARNING, ERROR, CRITICAL
readonly DATE='date +%Y/%m/%d:%H:%M:%S'
readonly LOGFILE=>&1
readonly SEVERITY=INFO

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

# ------------------------------
# err_report
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
# ------------------------------
function err_report() {
    log "errexit on line $(caller)" ERROR
}

# set the global error reporting trap
trap err_report ERR

# ------------------------------
# get_abs_dir
# follow BASH_SOURCE if source is symlink until you find the real root
# Globals:
#   BASH_SOURCE[0]
# Arguments:
#   None
# Returns:
#   abs_dir: the absolute directory where the script resides
# ------------------------------
function get_abs_dir() {
    local bash_src="${BASH_SOURCE[0]}"
    
    while [ -h "$bash_src" ]; do
         # get parent directory
        abs_dir="$( cd -P $(dirname "$bash_src") && pwd)"
        bash_src="$(readlink "$bash_src")"
        [[ $bash_src != /* ]] && bash_src="$abs_dir/$bash_src"
    done
    abs_dir="$(cd -P $(dirname "$bash_src") && pwd)"
    echo $abs_dir
}

# apply passed params to variables
# this can be done at the top of your script. This way you can refer to the globals
# without having to worry about interference because of sideeffects caused by changed variables.
# if you are paranoid you can set them to readonly also.
scriptname=$0
var1=$1
var2=$2
var3=$3
# ...

# read command line params
read -p "Enter some value: " x
read -p "Enter other value: " y

# simple function definition
function foo() {    
    log "foo function"
}

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

function main() {
    # log argc and argv
    # argv needs to be written to a string, because it will be passed as multiple 
    # parameters by default. This does not work with the log function taking two params.
    # Example: "$@" expands to "$1" "$2" ...
    log "argc \$#: $#"
    fall=$(printf "%s" "$@")
    log "argv \$@: $all" 

    foo

    # this can test nicely and exit with the error trap
    # we simply test the return for a zero value
    test -z "$(bar 5)" || { 
        log "the call to bar went wrong" ERROR; false; 
    }

    # this too, but does not include the nice message
    ret=$(bar 5)
}

# call the main function. This way it is easier to put more variables into locals
# the convention is like in C or java with argc and argv
main "$#" "$@"
exit 0

# vim: ft=sh sw=4 ts=4 sts=4 et nowrap:
