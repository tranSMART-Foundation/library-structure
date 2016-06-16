#!/bin/sh

#set -x
set -e

LOAD_SCRIPTS_DIRECTORY=$(pwd)
UPLOAD_SCRIPTS_DIRECTORY=$(dirname "$0")

if [ ! -d "samples/common" ] ; then
    echo "Can only run from the transmart-data top directory"
    exit 1
fi

if [ ! -z "$ORACLE" ] ; then
    if [ ! -d "samples/oracle" ] ; then
	echo "Can only run from the transmart-data top directory"
	exit 1
    fi
    if [ -z "$KETTLE_JOBS_ORA" ] || [ -z "$KITCHEN" ]; then
	echo "KETTLE_JOBS_ORA and KITCHEN must be defined for Oracle."
	echo "These should be defined in the top level vars file"
	echo "which must be sourced before running any make commands or scripts."
	exit 1
    fi
    export MAKECMD="make -C samples/oracle"
else
    if [ ! -d "samples/postgres" ] ; then
	echo "Can only run from the transmart-data top directory"
	exit 1
    fi
    if [ -z "$KETTLE_JOBS_PSQL" ] || [ -z "$KITCHEN" ]; then
	echo "KETTLE_JOBS_PSQL and KITCHEN must be defined for Postgres."
	echo "These should be defined in the top level vars file"
	echo "which must be sourced before running any make commands or scripts."
	exit 1
    fi
# Skip this test... some vars files define psql with 'sudo -E -u postgres'
# while others define the directory and variables or .pgpass files to define the
# postgres database credentials.
#    if [ ! -e "$PGSQL_BIN/psql" ] ; then
#	echo "psql not found in PGSQL_BIN '$PGSQL_BIN'"
#	echo "This should be defined in the top level vars file"
#	echo "which must be sourced before running any make commands or scripts."
#	exit 1
#    fi
    export MAKECMD="make -C samples/postgres"
fi

if [ ! -e "samples/studies/datasets" ] ||
   [ "samples/studies/datasets" -ot "samples/studies/public-feeds" ] ; then
    echo "Updating list of public datasets for download"
    make update_datasets
    echo "DONE Updating list of public datasets for download"
fi


$MAKECMD load_clinical_EtriksGSE15258

$MAKECMD load_ref_annotation_EtriksGSE15258

$MAKECMD load_expression_EtriksGSE15258

echo 'ALL DONE'
