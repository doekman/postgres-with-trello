SHELL=/bin/bash

usage: pre_requisites
	@echo
	@echo "Usage: make [DROP|CREATE|trello]"
	@echo
	@echo "Using psql environment variables:"
	@echo "- PGDATABASE: $(PGDATABASE)   #defaults to '${USER}'"
	@echo "- PGUSER: $(PGUSER)   #defaults to 'postgres'"

trello: db_exists
	@psql -tf trello.sql

CREATE: pre_requisites2
	createdb --encoding=UTF8

DROP: pre_requisites2
	dropdb --if-exists $(PGDATABASE)

db_exists: pre_requisites
	@psql -tc "SELECT 'postgres'' time: '||now()"

pre_requisites:
	@if [ -z $(shell which psql) ]; then \
		echo "The 'psql' utility can't be found"; \
		exit 1; \
	fi

pre_requisites2: pre_requisites
	@if [ -z $(PGDATABASE) ]; then \
		echo "The PGDATABASE environment variable is not set (see '.ok' for settings)"; \
		exit 1; \
	fi
