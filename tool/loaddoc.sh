#!/usr/bin/env bash
# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

# Idea from: <https://stackoverflow.com/a/48396608/56>

table_schema="trello"
table_name="document"
doc_column="doc"

if (( $# < 1 )); then
	>&2 echo "Usage: $(basename "$0") file_to_load.json [another/file.json...]

Load one or more JSON documents in to the current (env PG*) database. Table info:
     table schema: ${table_schema}
       table name: ${table_name}
        id column: auto generated (int)
    id_doc column: filled by trigger from ${doc_column}->>'id' json value.
       ${doc_column} column: the json-document
"
	
	exit 1
fi

while (( $# >= 1 )); do
	file_to_load="$1"
	if [[ ! -r "$file_to_load" ]]; then
		>&2 echo "Can't read from $file_to_load"
		exit 1
	fi

	psql_file="${0/.sh/.psql}"

	s=$( printf "%$(tput cols)s" )
	echo "${s// /-}"
	echo "json file | $file_to_load "
	# Can't use "-c" because that can't handle "psql-specific features"
	# see: <https://www.postgresql.org/docs/current/app-psql.html#APP-PSQL-INTERPOLATION>
	psql --no-psqlrc --quiet --expanded --tuples-only -v "table_schema=$table_schema" -v "table_name=$table_name" -v "doc_column=$doc_column" -v "file_to_load=$file_to_load" -f "$psql_file" | grep -v ^$

	shift
done
