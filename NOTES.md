Notes
-----

Some working notes here. Via [this tweet][crunchy_tweet] and [this post][crunchy_blog] I found out you can use `COPY` to insert JSON data:

	$ cat data/til.json | psql -h localhost -p 5432 doc_db -c "COPY trello.document(doc) FROM STDIN;"

This is going to be much faster than my current method. It doesn't do UPSERT though. It generates an error when the trigger (via `doc_id`-extraction) want to make it update:

	ERROR:  duplicate key value violates unique constraint "document_doc_id_key"

And with some Trello exports it has problems:

	$ cat data/todo.json | psql -h localhost -p 5432 doc_db -c "COPY trello.document(doc) FROM STDIN;"
	ERROR:  invalid input syntax for type json
	DETAIL:  Character with value 0x0a must be escaped.
	CONTEXT:  ...

Error in PostgreSQL 10, and also in Postgres 12.


[crunchy_tweet]: https://twitter.com/crunchydata/status/1265324567867699200
[crunchy_blog]: https://info.crunchydata.com/blog/fast-csv-and-json-ingestion-in-postgresql-with-copy

