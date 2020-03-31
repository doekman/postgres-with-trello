#!/usr/bin/env bash
# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

# Idea from: <https://stackoverflow.com/a/48396608/56>

if (( $# < 1 )); then
	>&2 echo "Usage: $(basename $0) file_to_load.json"
	exit 1
fi

file_to_load="$1"
if [[ ! -r "$file_to_load" ]]; then
	>&2 echo "Can't read from $file_to_load"
	exit 1
fi

table_schema="public"
table_name="trello"
doc_column="doc"
psql_file="${0/.sh/.psql}"

# Can't use "-c" because that can't handle "psql-specific features"
# see: <https://www.postgresql.org/docs/current/app-psql.html#APP-PSQL-INTERPOLATION>
psql -v "table_schema=$table_schema" -v "table_name=$table_name" -v "doc_column=$doc_column" -v "file_to_load=$file_to_load" -f "$psql_file"|sed 's/^INSERT /UPSERT /'
