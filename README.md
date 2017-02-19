# PSQL ETL Framework (Bash)


## What does this thing do?

This framework runs SQL against one-or-many psql-compatible hosts, with SQL run in sequence on each host. If there are many hosts, each host will execute its series of SQL in parallel to the others. 

Source the framework multiple times in sequence to execute across multiple PSQL clusters. To perform extracts and/or loads, I recommend that you wrap COPY jobs in functions, and call those.

Look at the files in /demo, then at /demo/psql_etl_demo.sh, to see how easy it is to use.

## Dependencies:

psql, with [~/.pgpass file](https://www.postgresql.org/docs/9.4/static/libpq-pgpass.html) defined for each host
Otherwise, just bash

## Config files:

**clustername**_psql_hosts.txt - A list of upstream PSQL hosts to run SQL against. One per line!

**clustername**_psql_etl.sql - A list SQL commands to be run on the PSQL hosts. One SQL transaction per line!

	If your SQL is too epic to be called in a single line, turn it into a function, and call that.

	Please don't put spaces or punctuation in your clustername. It probably won't work.


## How to use:

1. Start the job in the directory where your config files are
2. Source psql_etl.sh
3. Call func_psql_etl "**clustername**" from Bash.
	* If you need to call another cluster, call it again with the next clustername
	
See the 'demo' folder for an example implementation.

## To do:

1. Set up a DDL script that creates a psql job logging schema inside Postgres
2. Add lines to this script to:
	a. Check if the schema exists (once)
	b. Write to the schema if it does
	c. Not error (but just warn) if it doesn't
	