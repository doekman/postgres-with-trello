Example queries
===============

Filtering on arrays
-------------------

Filter on an green label:

	SELECT *
	FROM trello_card
	WHERE id_labels @> '["5e7b7e537669b22549566428"]';

or even:

	SELECT *
	FROM trello_card c
	WHERE EXISTS
	(	SELECT * 
		FROM trello_label l 
		WHERE c.id_labels @> jsonb_build_array(l.id)
		  AND l.color = 'green'
	);


One could also work with postgres arrays, but mixing types makes stuff more complex:

	-- Ripped from: <https://dba.stackexchange.com/a/54289>
	CREATE OR REPLACE FUNCTION jsonb_array_to_text_array(_js jsonb) RETURNS text[] 
	LANGUAGE sql IMMUTABLE PARALLEL SAFE AS
		'SELECT ARRAY(SELECT jsonb_array_elements_text(_js))'
	;

Select green (5e7b7e537669b22549566428) labeled cards:

	SELECT *
	FROM trello_card
	WHERE (id_labels @> ARRAY['5e7b7e537669b22549566428'])
	ORDER BY "pos";

