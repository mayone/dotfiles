#!/bin/sh
#
# Check and return true/false.

# Variables
declare -r TRUE=0
declare -r FALSE=1

UNAME_S=$(uname -s)

OS_MAC="Darwin"
OS_LINUX="Linux"
OS_WINDOWS="CYGWIN*|MINGW32*|MSYS*|MINGW*"

check_os() {
  if [[ "$UNAME_S" =~ "$1" ]]; then
    return $TRUE
  else
    return $FALSE
  fi
}

check_cmd() {
  command -v "$1" >/dev/null 2>&1
}

check_exist() {
  test -e "$1" >/dev/null 2>&1
}

check_folder() {
  test -d "$1" >/dev/null 2>&1
}
