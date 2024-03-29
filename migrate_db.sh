#!/bin/bash
set -euo pipefail

: ${DBNAME:=""}
: ${USER:=postgres}
: ${HOST:=localhost}
: ${PORT:=5432}

if [[ "$DBNAME" == "" ]] || [[ "$#" < "1" ]] || [[ "$#" > "2" ]]; then
    echo
    echo "Usage: DBNAME=<dbname> $0 migrations {skip}"
    echo
    echo "  migrations: is the path to the migration files named such that"
    echo "              'ls' will enumerate them in the order they should be applied."
    echo "  skip: if provided, this is the filename of migration that was last"
    echo "        applied, so only files greater than this will be applied."
    echo
    echo "Optionally override these defaults:"
    echo "  USER:=postgres"
    echo "  HOST:=localhost"
    echo "  PORT:=5432"
    echo
    exit 1
fi

MIGRATIONS=$1
SKIP=$([ "$#" == "2" ] && echo "$2" || echo "")
if [ "$MIGRATIONS" != "" ]; then
    echo "Appling migration scripts in ${MIGRATIONS}..."
    for entry in `ls ${MIGRATIONS}`; do
        if [[ "$entry" > "$SKIP" ]]; then
            echo "Applying ${entry}"
            psql -h ${HOST} -p ${PORT} -U ${USER} ${DBNAME} -a -f ${entry}
        fi
    done
    echo "Migration complete."
fi
