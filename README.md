postgres-with-trello
====================

In [Trello][], you can [export board-data to JSON][export]. In this repository, you will find SQL to work with those.

The files `data/simple_board_v1.json` and `...v2..` are exported from [this public board][simple_board].

**NOTICE**: this repository uses an [ok-profile][ok].


Getting started
---------------

To get started, open a terminal session and go to this repository folder.

	make 

will show how you how to use the makefile. The command

	make trello

will create the table+views (trello). Now load some data:

	tool/loaddoc.sh data/simple_board.json

Now you are ready to query:

	psql
	\d

The last command shows all tables and views you can query from. Let's query some:

	select * from trello.board;
	select * from trello.card where doc_id=1;
	select * from trello.list;

And to quit `psql`, type:

	\q


More
----

* There are some example queries in [queries.md](queries.md)
* If you want to contribute, please create an [issue][issue] so we can discuss first


[Trello]: https://trello.com/
[export]: https://help.trello.com/article/747-exporting-data-from-trello-1
[simple_board]: https://trello.com/b/ZWvFVK9Z/postgres-with-trello
[ok]: https://github.com/secretGeek/ok-bash
[issue]: https://github.com/doekman/postgres-with-trello/issues
