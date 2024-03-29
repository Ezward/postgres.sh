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

confirm "Deletion of the database cannot be undone. Proceed? [y/N] " && dropdb -h ${HOST} -p ${PORT} -U ${USER} ${DBNAME}
