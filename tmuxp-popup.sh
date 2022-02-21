#!/bin/bash
#
# tmuxp-popup: Connect to a tmuxp managed tmux session in a
# tmux popup window.
#
# https://github.com/von/tmuxp-popup

_VERSION="0.1.0"

######################################################################
# Defaults

# Binaries
_TMUX="tmux"
_TMUXP="tmuxp"

# Enable debugging if true
_DEBUG="false"

# Toggle popup
_TOGGLE="false"

# Options for 'tmux popup'
# Exit when complete, if successful
_POPUP_ARGS="-E -E"
# Bottom of window and full-sized
_POPUP_SIZE="-xP -yP -w100% -h100%"

######################################################################
#
# Utility functions
#

# Handle a debugging message
function debug()
{
  test ${_DEBUG} = "true" && echo "$*" || true
}

# Output an error message
function error()
{
  echo "$*" 1>&2
}

######################################################################
#
# Top-level commands
#

function cmd_help()
{
  cat <<EOF
  Usage: $0 [<options>] <session name>

  Options:
  -c <conf>    tumxp config file
  -d           Turn on debugging.
  -h           Print help and exit.
  -s <size>    tmux popup size
  -t           Toggle popup
  -V           Print version and exit.

  With no option to contrary, create or attach to <session name>.
EOF
}

function cmd_version()
{
  echo "%0 version ${_VERSION}"
}

######################################################################
#
# Main
#

set -o errexit  # Exit on error

test -z "${TMUX}" && { error "$0 must be run from within tmux" ; exit 1 ; }

# Leading colon means silent errors, script will handle them
# Colon after a parameter, means that parameter has an argument in $OPTARG
while getopts ":c:dhs:tv" opt; do
  case $opt in
    c) _TMUXP_CONFIG=$OPTARG ;;
    d) _DEBUG="true" ; debug "Debugging enabled" ;;
    h) cmd_help ; exit 0 ;;
    s) _POPUP_SIZE="$OPTARG" ;;
    t) _TOGGLE="true" ;;
    v) cmd_version ; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG" >&2 ;;
  esac
done

shift $(($OPTIND - 1))

test $# = 0 && { error "Missing session name" ; exit 1 ; }
_SESSION=$1 ; shift
test $# -gt 0 && error "Ignoring extra aruments"

if test "${_TOGGLE}" = true ; then
  debug "Toggling..."
  _CURRENT_SESSION="$(tmux display-message -p -F "#{session_name}")"
  if test "${_CURRENT_SESSION}" = "${_SESSION}" ; then
    debug "Detacting from current session ${_SESSION}"
    ${_TMUX} detach-client
    exit 0
  fi
fi

_TMUXP_CONFIG=${_TMUXP_CONFIG:-${_SESSION}}
debug "Loading session ${_SESSION} from config file ${_TMUXP_CONFIG}"
"${_TMUXP}" load -d "${_TMUXP_CONFIG}" > /dev/null

debug "Attaching to session ${_SESSION}..."
# "no previous window" error message - see https://github.com/tmux-python/tmuxp/issues/364
"${_TMUX}" popup ${_POPUP_ARGS} ${_POPUP_SIZE} "${_TMUX} attach -t ${_SESSION}"

exit 0
