#!/bin/bash
set -euo pipefail

: ${PGDATABASE:=""}
: ${PGUSER:=postgres}
: ${PGHOST:=localhost}
: ${PGPORT:=5432}

if [ "$PGDATABASE" == "" ] || [ "$#" != "0" ]; then
    echo
    echo "Usage: PGDATABASE=<dbname> $0"
    echo "Optionally override these defaults:"
    echo "  PGUSER:=postgres"
    echo "  PGHOST:=localhost"
    echo "  PGPORT:=5432"
    echo
    exit 1
fi

DATADIRECTORY=$(psql -t -h ${PGHOST} -p ${PGPORT} -U ${PGUSER} ${PGDATABASE} -c 'SHOW data_directory')
pg_ctl restart -D ${DATADIRECTORY}
