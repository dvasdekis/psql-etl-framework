#!/bin/bash
#
# Set script to error on any fails
set -e
#
# This script is meant to be sourced by a broader ETL process.
# The function func_psql_etl is effectively the 'main' function. It's defined last, and called by the user of the psql_etl.sh job
#
# List of functions
# func_pe_gbl_variables - sets variables within the script
# func_pe_line_counts - Gets line counts for the config files used (used in xargs parallel parameter)
# func_pe_parallel - Runs the sql in the file on multiple servers simultaneously
# func_psql_etl - 'Main' function, running other functions in sequence, and setting global script parameters from input
#
# Begin script function definitions
  #
  # Define global script variables
  function func_pe_gbl_variables {
  # Current directory path
    export pe_gbl_curr_dir="$(dirname "$(readlink -f "$0")")"
  # Forwardslash as variable for reasons
    export pe_gbl_fwdslsh="/"
  # SQL file name suffix (after cluster name)
    export pe_gbl_sql_file_suffix="_psql_etl.sql"
  # Hosts file name suffix (after cluster name)
    export pe_gbl_hosts_file_suffix="_psql_hosts.txt"
  }
  #
  # Get and export a count of rows for the two files
  function func_pe_line_counts {
  # Define SQL file full path
    export pe_fpe_sql_file_loc=$pe_gbl_curr_dir$pe_gbl_fwdslsh$pe_fpe_cluster_name$pe_gbl_sql_file_suffix
  # Define SQL file line counts
    export pe_fpe_sql_line_count=$(cat $pe_fpe_sql_file_loc | wc -l )
  # Define hosts file full path
    export pe_fpe_hosts_file_loc=$pe_gbl_curr_dir$pe_gbl_fwdslsh$pe_fpe_cluster_name$pe_gbl_hosts_file_suffix
  # Define hosts file line count
    export pe_fpe_hosts_line_count=$(cat $pe_fpe_hosts_file_loc | wc -l)
  }
  #
  # This function:
  #   1. Reads each SQL line from $pe_fpe_sql_file_loc
  #   2. Writes the contents to a new temporary file (necessary to deal with escapes and strange characters)
  #   3. Executes each line against each server in parallel from $pe_fpe_hosts_file_loc
  #   4. Waits until execution is complete across every server before starting the next line of SQL
  #   5. Deletes the temporary file located in Step 2
  #
  function func_pe_parallel {
    while read -r pe_sql_file_line; do
      pe_sql_line_tmpfile_loc="$(mktemp)"
      echo "$pe_sql_file_line" > "$pe_sql_line_tmpfile_loc"
      export pe_sql_line_tmpfile_loc_ex=$pe_sql_line_tmpfile_loc
      xargs -a $pe_fpe_hosts_file_loc -d '\n' -I {} -P "$pe_fpe_hosts_line_count"  bash -c 'psql -q -A -t {} -f $pe_sql_line_tmpfile_loc_ex'
      rm -f $pe_sql_line_tmpfile_loc
    done <$pe_fpe_sql_file_loc
  }
  # This is the 'main' function for the script
function func_psql_etl {
  # Define the input variable (cluster name). This is the only variable 'passed' back to the top of the script
    export pe_fpe_cluster_name=$1
  # Run all previously defined functions
    func_pe_gbl_variables
    func_pe_line_counts
    func_pe_parallel
  }
