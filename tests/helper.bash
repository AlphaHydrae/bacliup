#!/usr/bin/env bash
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
root_dir="$(dirname "$script_dir")"
bin_dir="${root_dir}/bin"

tmp_dirs=()
trap "cleanup" EXIT

function cleanup() {
  for dir in "${tmp_dirs[@]}"; do
    test -n "$dir" && test -d "$dir" && rm -fr "$dir"
  done
}

function common_setup() {
  load 'libs/support/load'
  load 'libs/assert/load'

  tmp_dir=`mktemp -d -t bacliup.tests.XXXXXX`
  tmp_dirs+=("$tmp_dir")
  echo "Temporary directory: $tmp_dir"

  PATH="$bin_dir:$PATH"

  twd="${tmp_dir}/twd"
  export HOME="$twd"

  mkdir "$twd"
  cd "$twd"
}

function common_teardown() {
  cleanup
}

function fail() {
  local msg="$@"

  >&2 echo "TEST ERROR: $msg"
  exit 2
}
