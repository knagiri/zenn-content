#!/bin/env bash

set -eu

article_name=${1:-""}
# Check if `article_name($1)` is exists
if [ -z "$article_name" ]; then
  echo "[Error]: Input new article name" 1>&2
  exit 1
fi

function main() {
    local _prefix=$(get_prefix)

    # Ex) "2022-12-15_pman-nasub-moyac"
    yarn zenn new:article --slug "${_prefix}-${article_name}"

    return 0
}

function get_prefix() {
    date +%Y%m%d
    return 0
}

main $1
