#!/usr/bin/env bash
set -e
_DIR_=`dirname "$(readlink -f "$0")"`
_FILE_=`basename $0`
_LOG_="/dev/null"
_NOW_=`date +"%Y-%m-%d@%H:%M"`

# Helpers
function CONFIRM {
    read -r -p "${1:-Are you sure?} [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

function INFO {
  echo -e "\e[1;32m[${_FILE_}]\e[0m ${1}"
}

function WARNING {
  echo -e "\e[1;33m[${_FILE_}]\e[0m ${1}"
  CONFIRM && return
  exit 1
}

function ERROR {
  echo -e "\e[1;31m[${_FILE_}]\e[0m ${1}"
  exit 1
}

function TIME_START {
  t1=`date +%s.%N`
}

function TIME_STOP {
  t2=`date +%s.%N`
  dt=`echo "$t2 - $t1" | bc -l`
  dt=`echo "scale=2; $dt / 1" | bc -l`
  echo "Done in ${dt}s"
}

# Default configuration
if [ -f "${_DIR_}/.themestarter" ]; then
  source ${_DIR_}/.themestarter
else
  ERROR "Config not found! Please create ${_DIR_}/.themestarter"
fi

# Check configuration
if [ -z "${REMOTE_DOMAIN}" ]; then
  ERROR "Please configure REMOTE_DOMAIN in ${_DIR_}/.themestarter"
fi
if [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_PATH" ]; then
  ERROR "Please configure REMOVE_HOST / REMOVE_USER / REMOTE_PATH in ${_DIR_}/.themestarter"
fi

# Change to project root directory
cd ${_DIR_}/..

# Determine local domain
if [ ! -z "${LOCAL_DOMAIN}" ]; then
  LOCAL_DOMAIN=${REMOTE_DOMAIN#www.}
  LOCAL_DOMAIN="${LOCAL_DOMAIN%%.*}.${LOCAL_TLD-localhost.test}"
fi
if [ -z "${LOCAL_DOMAIN}" ]; then
  ERROR "Could not determine local domain. Please verify ${_DIR_}/.themestarter"
fi
