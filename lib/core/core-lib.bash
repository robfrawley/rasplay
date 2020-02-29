#!/bin/bash

function bool_to_string() {
  local val="${1}"
  local str_t="${2:-ON}"
  local str_f="${3:-OFF}"
  local str

  if [[ ${val} -gt 0 ]]; then
    str="${str_t}"
  else
    str="${str_f}"
  fi

  printf -- '%-3s (%d)' "${str}" "${val}"
}

function number_round() {
  local float_val="${1}"
  local precision="${2:-2}"

  printf -- "%.${precision}f" $(
    echo "scale=${precision};(((10^${precision})*${float_val})+0.5)/(10^${precision})" \
      | bc
  )
}

function run_math_stmt() {
  local statement="${1}"
  local precision="${2:-2}"
  local arguments=("${@:3}")

  number_round $(
    echo "scale=${precision};$(
      printf -- "${statement}" "${arguments[@]}" || printf -- "${statement}"
    )" | bc
  ) ${precision}
}

function number_base_switch() {
  local numerator="${1}"
  local denom_cur="${2:-100}"
  local denom_new="${3:-100}"
  local precision="${4:-2}"

  run_math_stmt "${numerator}*${denom_new}/${denom_cur}" ${precision}
}

function number_floor() {
  awk '{print int($0)}' <<< "${1}"
}

function number_ceil() {
  awk '{print ($0-int($0)>0)?int($0)+1:int($0)}' <<< "${1}"
}

readonly _LIB_CALLER_PATH="$(
  realpath -e "${BASH_SOURCE[-1]}" 2> /dev/null || printf -- '%s' "${BASH_SOURCE[-1]}"
)"

readonly _LIB_CALLER_ROOT="$(
  dirname "${_LIB_CALLER_PATH}" 2> /dev/null
)"

readonly _LIB_CALLER_FILE="$(
  basename "${_LIB_CALLER_PATH}" 2> /dev/null
)"

readonly _LIB_CALLER_EXTS="$(
  grep -oE '\.[a-zA-Z0-9]+$' <<< "${_LIB_CALLER_PATH}" 2> /dev/null | \
    sed -E 's/^\.//'
)"

readonly _LIB_CALLER_NAME="$(
  basename "${_LIB_CALLER_PATH}" ".${_LIB_CALLER_EXTS}"
)"
