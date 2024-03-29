#!/bin/bash
set -euo pipefail

: ${DBNAME:=""}
: ${USER:=postgres}
: ${HOST:=localhost}
: ${PORT:=5432}

if [ "$DBNAME" == "" ] || [ "$#" != "1" ] || ! [[ "$1" == "dump"  ||  "$1" == "schema" ]]; then
    echo
    echo "Usage: DBNAME=<dbname> $0 dump|schema"
    echo "Optionally override these defaults:"
    echo "  USER:=postgres"
    echo "  HOST:=localhost"
    echo "  PORT:=5432"
    echo "  FILENAME:={DBNAME}.[dump|schema].(date -u +'%FT%H%M%SZ').sql"}
    echo
    exit 1
fi

: ${FILENAME:="${DBNAME}.$1.$(date -u +'%FT%H%M%SZ').sql"}

# set flag is we are dumping only the schema
SCHEMA_FLAG=$([ "$1" == "schema" ] && echo "--schema-only" || echo "")

pg_dump -h ${HOST} -p ${PORT} -U ${USER} ${SCHEMA_FLAG} ${DBNAME} --file=${FILENAME}
