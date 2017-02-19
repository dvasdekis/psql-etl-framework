#!/bin/bash
#
# Set script to error on any fails
set -e
#
# Source the script
source /fullpath/psql-etl-framework/psql_etl.sh
# 
# Call the function
func_psql_etl "demo"
