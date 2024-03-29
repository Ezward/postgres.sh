#!/bin/bash
set -euo pipefail

: ${DBNAME:=""}
: ${USER:=postgres}
: ${HOST:=localhost}
: ${PORT:=5432}

if [ "$DBNAME" == "" ] || [ "$#" != "0" ]; then
    echo
    echo "Usage: DBNAME=<dbname> $0"
    echo "Optionally override these defaults:"
    echo "  USER:=postgres"
    echo "  HOST:=localhost"
    echo "  PORT:=5432"
    echo
    exit 1
fi

DATADIRECTORY=$(psql -t -h ${HOST} -p ${PORT} -U ${USER} ${DBNAME} -c 'SHOW data_directory')
pg_ctl restart -D ${DATADIRECTORY}
