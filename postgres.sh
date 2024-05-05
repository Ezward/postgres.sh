#!/bin/bash
set -euo pipefail

: ${PGDATABASE:=""}
: ${PGUSER:=postgres}
: ${PGHOST:=localhost}
: ${PGPORT:=5432}
: ${MIGRATIONS:="./migrations"}
: ${SKIP:=""}
: ${DUMPS:="./"}

SCRIPTNAME=$(basename $0)

function print_usage() {
    echo "$SCRIPTNAME is a wrapper around postgresql tools and so depends"
	echo "upon psql, pg_dump, pg_ctl, createdb, and dropdb being installed."
	echo
    echo "Usage: $SCRIPTNAME command {command ...}"
    echo "Commands are executed sequentially in the order they are provided"
    echo
    echo "Commands:"
    echo "  connect: connect command line to the database"
    echo "  create: create the database"
    echo "  drop: drop the database with safety check"
    echo "  drop-forced: drop the database without safety check"
    echo "  dump: dump the database schema and data"
    echo "  dump-data: dump the database data as insert statements"
    echo "  dump-schema: dump the database schema"
    echo "  force-drop: drop the database without safety check"
    echo "  migrate: migrate the database schema"
    echo "  restart: restart the database instance"
    echo
    echo "Environment variables:"
    echo "  PGDATABASE: The database name, no default; this must be set by the caller"
    echo "  PGHOST: The database instance host, defaults to 'localhost'"
    echo "  PGPORT: The database instance port, defaults to 5432"
    echo "  PGUSER: The user that owns the database schema, defaults to 'postgres'"
    echo "  DUMPS: The path to the folder where db dumps are written;"
    echo "         defaults to the same directory as the script."
    echo "  MIGRATIONS: The path to the migration files folder;"
    echo "              defaults to 'migrations' folder in same folder as the script."
	echo "              The migration files must be named such that"
    echo "              'ls' will enumerate them in the order they should be applied."
    echo "  SKIP: if provided, this is the name of the migration file that was last"
    echo "        applied, so only files greater than this will be applied."
    echo
    echo "Examples:"
    echo "  PGDATABASE=mydb $SCRIPTNAME create"
    echo "  PGDATABASE=authdb $SCRIPTNAME create migrate connect"
    echo "  PGDATABASE=food_db $SCRIPTNAME dump drop-forced"
}



# Set dir to script folder, then use relative path from there
cd $(dirname $0)

# one or more commands are required
if [[ $# -lt 1 ]]; then
    echo "$SCRIPTNAME requires one or more command arguments"
    echo
    print_usage
    exit 1
fi

if [[ "$PGDATABASE" == "" ]]; then
    echo "$SCRIPTNAME requires PGDATABASE must be set to the database name"
    echo
    print_usage
    exit 1
fi

function valid_command() {
    case "$1" in
        connect|create|drop|drop-force|dump|dump-data|dump-schema|migrate|restart)
            true
            ;;
        *)
            false
            ;;
    esac
}

function confirm() {
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

function db_exists() {
    echo $(psql -h ${PGHOST} -p ${PGPORT} -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = '${PGDATABASE}'")
}

function connect_db() {
    psql -h ${PGHOST} -p ${PGPORT} -U ${USER} ${PGDATABASE}
}

function create_db() {
    if [ "$(db_exists)" == "1" ]; then
        echo "${PGDATABASE} already exists"
    else
        createdb -h ${PGHOST} -p ${PGPORT} -U ${USER} ${PGDATABASE}
    fi
}

function drop_db() {
    if [ "$(db_exists)" == "1" ]; then
        confirm "Do you want to dump the schema before dropping the db? [y/N] " && pg_dump -h ${PGHOST} -p ${PGPORT} -U ${USER} --schema-only ${PGDATABASE} --file="${PGDATABASE}.schema.$(date -u +"%FT%H%M%SZ").sql"
        confirm "Deletion of the database cannot be undone. Proceed? [y/N] " && dropdb -h ${PGHOST} -p ${PGPORT} -U ${USER} ${PGDATABASE}
    else
        echo "${PGDATABASE} does not exist"
    fi
}

function drop_forced_db() {
    if [ "$(db_exists)" == "1" ]; then
        dropdb -h ${PGHOST} -p ${PGPORT} -U ${USER} ${PGDATABASE}
    else
        echo "${PGDATABASE} does not exist"
    fi
}

function migrate_db() {
    echo "Appling migration scripts in ${MIGRATIONS}..."
    for entry in `ls ${MIGRATIONS}`; do
        if [[ "$entry" > "$SKIP" ]]; then
            echo "Applying ${entry}"
            psql -h ${PGHOST} -p ${PGPORT} -U ${PGUSER} ${PGDATABASE} -a -f ${entry}
        fi
    done
    echo "Migration complete."
}

function dump_db() {
    FILENAME="${PGDATABASE}.$(date -u +"%FT%H%M%SZ").sql"
    echo "Writing ${PGDATABASE} schema and data to ${FILENAME}"
    pg_dump -h ${PGHOST} -p ${PGPORT} -U ${USER} ${PGDATABASE} --file="${DUMPS}${FILENAME}"
}

function dump_schema_db() {
    FILENAME="${PGDATABASE}.schema.$(date -u +"%FT%H%M%SZ").sql"
    echo "Writing ${PGDATABASE} schema to ${FILENAME}"
    pg_dump -h ${PGHOST} -p ${PGPORT} -U ${USER} --schema-only ${PGDATABASE} --file="${DUMPS}${FILENAME}"
}

function dump_data_db() {
    FILENAME="${PGDATABASE}.data.$(date -u +"%FT%H%M%SZ").sql"
    echo "Writing ${PGDATABASE} data to ${FILENAME}"
    pg_dump -h ${PGHOST} -p ${PGPORT} -U ${USER} --column-inserts --data-only ${PGDATABASE} --file="${DUMPS}${FILENAME}"
}

function restart_db() {
    DATADIRECTORY=$(psql -t -h ${PGHOST} -p ${PGPORT} -U ${USER} ${PGDATABASE} -c 'SHOW data_directory')
    pg_ctl restart -D ${DATADIRECTORY}
}

#
# validate commands before running
#
for var in "$@" ; do
    if ! valid_command ${var} ; then
        echo "Invalid command '$var'"
        echo
        print_usage
        exit 1
    fi
done

#
# run commands sequentially
#
for var in "$@" ; do
    echo "$var"
    ${var//-/_}_db
done
