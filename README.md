postgres-with-trello
====================

In [Trello][], you can [export board-data to JSON][export]. In this repository, you will find SQL to work with those.

The file `data/simple_board.json` is exported from [this public board][simple_board].


Getting started
---------------

To get started, open a terminal session and go to this repository folder.

	make 

will show how you how to use the makefile.

	export PGDATABASE=doc_db

will set the database `psql` will be using. Now for some real action:

	make CREATE trello

asks make to create the database (CREATE) and the table+views (trello). Now load some data:

	tool/loaddoc.sh data/simple_board.json

Now you are ready to query:

	psql
	\d

The last command shows all tables and views you can query from. Let's query some:

	select * from trello_board;
	select * from trello_card where doc_id=1;
	select * from trello_list;

And to quit `psql`, type:

	\q


[Trello]: https://trello.com/
[export]: https://help.trello.com/article/747-exporting-data-from-trello-1
[simple_board]: https://trello.com/b/ZWvFVK9Z/postgres-with-trello
