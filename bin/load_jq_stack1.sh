#!/bin/sh
set -e
cd "$(dirname "$0")/.."
echo 'JQS='\'"$(pwd)"'/lib/jqs1.lib.sh'\''; . "$JQS"'
