#!/bin/bash
set -euo pipefail

# set defaults
. ./defaults_db.sh

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

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

confirm "Deletion of the database cannot be undone. Proceed? [y/N] " && dropdb -h ${PGHOST} -p ${PGPORT} -U ${PGUSER} ${PGDATABASE}
