#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -m 

$SCRIPT_DIR/default-entrypoint.sh &

sleep 10s

$SCRIPT_DIR/init-dbs.sh

fg %1
