# postgres.sh; shell scripts to work with postgresql

These are a very thin layer over the postgres utilities to make it easy to work with postgres databases from the command line.  These are best used by copying them to a folder on your computer and modifying the `defaults_db.sh` with values specific to your database.  The defaults are:

- PGDATABASE=""
- PGUSER=postgres
- PGHOST=localhost
- PGPORT=5432

The default for `PGDATABASE` is a blank string, which must be overridden in order to use the utilities.  That can be done each time a utility is called;

```bash
$ PGDATABASE=my_test_database ./create_db.sh
```

or if you only work with one database then you can edit the `defaults_db.sh` to use those defaults.  Alternatively, you can set the override values into your environment so they are set at startup by adding the lines to your shell profile (~/.bash_profile or ~/zsh_profile).  For example;

```bash
export PGDATABASE:="my_database"
export PGUSER:="my_user"
export PGHOST:=localhost
export PGPORT:=5432
```

If you work with more than one database then you can make a copy of the scripts for each project, usually in a `scripts` sub-folder, and then modify that project's `scripts/defaults_db.sh` for that project's database. Then run them from the project's folder, `./scripts/connect_db.sh`.  Do that for each project that uses a database.

## TODO
- [ ] extend migrate_db.sh to be real migration utility that maintains the state of the migration in a table in the database.
