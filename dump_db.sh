#!/bin/bash
set -euo pipefail

# set defaults
. ./defaults_db.sh

if [ "$PGDATABASE" == "" ] || [ "$#" != "1" ] || ! [[ "$1" == "dump"  ||  "$1" == "schema" ]]; then
    echo
    echo "Usage: PGDATABASE=<dbname> $0 dump|schema"
    echo "Optionally override these defaults:"
    echo "  PGUSER:=postgres"
    echo "  PGHOST:=localhost"
    echo "  PGPORT:=5432"
    echo "  FILENAME:={PGDATABASE}.[dump|schema].(date -u +'%FT%H%M%SZ').sql"}
    echo
    exit 1
fi

: ${FILENAME:="${PGDATABASE}.$1.$(date -u +'%FT%H%M%SZ').sql"}

# set flag is we are dumping only the schema
SCHEMA_FLAG=$([ "$1" == "schema" ] && echo "--schema-only" || echo "")

pg_dump -h ${PGHOST} -p ${PGPORT} -U ${PGUSER} ${SCHEMA_FLAG} ${PGDATABASE} --file=${FILENAME}
