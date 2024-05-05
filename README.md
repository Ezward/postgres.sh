# postgres.sh; shell script to work with postgresql databases

postgres.sh is a wrapper around postgresql tools and so depends
upon psql, pg_dump, pg_ctl, createdb, and dropdb being installed.
The script includes a minimal database migration facility.

## Usage: postgres.sh command {command ...}
Commands are executed sequentially in the order they are provided

## Commands:
- connect: connect command line to the database
- create: create the database
- drop: drop the database with safety check
- drop-forced: drop the database without safety check
- dump: dump the database schema and data
- dump-data: dump the database data as insert statements
- dump-schema: dump the database schema
- force-drop: drop the database without safety check
- migrate: migrate the database schema
- restart: restart the database instance

## Environment variables:
- PGDATABASE: The database name, no default; this must be set by the caller
- PGHOST: The database instance host, defaults to 'localhost'
- PGPORT: The database instance port, defaults to 5432
- PGUSER: The user that owns the database schema, defaults to 'postgres'
- DUMPS: The path to the folder where db dumps are written;
         defaults to the same directory as the script.
- MIGRATIONS: The path to the migration files folder.
              The migration files must be named such that
              'ls' will enumerate them in the order they should be applied.
- SKIP: If provided, this is the name of the migration file that was last
        applied, so only files greater than this will be applied.

## Examples:
The default for `PGDATABASE` is a blank string, which must be overridden in order to use the utilities.  That can be done each time a utility is called;

- create a database named 'mydb'
```bash
PGDATABASE=mydb postgres.sh create
```

- create a database named 'authdb', then run sql migration files in the 'migrations' folder and finally connect to the database.
```bash
PGDATABASE=authdb postgres.sh create migrate connect
```

- dump the data and schema for the database named 'food_db' and then drop the database.
```bash
PGDATABASE=food_db postgres.sh dump drop-forced
```

Alternatively, you can set the override values into your environment so they are set at startup by adding the lines to your shell profile (~/.bash_profile or ~/zsh_profile).  For example;

```bash
export PGDATABASE:="my_database"
export PGUSER:="my_user"
export PGHOST:=localhost
export PGPORT:=5432
```

If you work with more than one database then you can make a copy of the script for each project, usually in a `scripts` sub-folder, and then modify the defaults at the top of the script for that project's database. Then run them from the project's folder, `./scripts/connect_db.sh`.  Do that for each project that uses a database.

## TODO
- [ ] extend migration function to maintain the state of the migration in a table in the database.
