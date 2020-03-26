drop table if exists trello cascade
;

create table trello
(   id   serial  PRIMARY KEY
,   doc  jsonb   NOT NULL
)
;

create view trello_board
as
	select id                       as doc_id --int id
	,      t.doc->>'id'             as id
	,      t.doc->>'name'           as name
	,      t.doc->>'desc'           as description
	,      t.doc->>'url'            as url
	,      t.doc->'pinned'='true'   as pinned
	,      t.doc->'starred'='true'  as starred
	,      t.doc->'closed'='true'   as closed
	,      replace(t.doc->>'dateLastActivity','T',' ')::timestamp with time zone as date_last_activity
	,      replace(t.doc->>'dateLastView','T',' ')::timestamp with time zone     as date_last_view
	from trello t
;

-- NIET GEBRUIKEN: prefs; labelNames (redundant); 
-- OF LATER: actions, checklists, memberships
-- Views voor: labels, lists, members
create view trello_label
as
	select t.id               as doc_id
	,      l.value->>'id'     as id
	,      l.value->>'name'   as name
	,      l.value->>'color'  as color
	from trello t
	,    jsonb_array_elements(t.doc#>'{labels}') l
	order by 2 -- Labels seems to be sorted on "id" in Trello's label view
;

create view trello_list
as
	select t.id                          as doc_id
	,      l.value->>'id'                as id
	,      l.value->>'name'              as name
	,      (l.value->>'pos')::numeric    as pos
	,      l.value->'closed'='true'      as closed
	,      l.value->'subscribed'='true'  as subscribed
	from trello t
	,    jsonb_array_elements(t.doc#>'{lists}') l
	order by 4
;

create view trello_member
as
	select t.id                         as doc_id
	,      m.value->>'id'               as id
	,      m.value->>'fullName'         as full_name
	,      m.value->>'initials'         as initials
	,      m.value->>'username'         as username
	,      m.value->>'bio'              as bio
	,      m.value->>'url'              as url
	,      m.value->>'avatarUrl'        as avatar_url
	,      m.value->>'memberType'       as member_type
	,      m.value->'confirmed'='true'  as confirmed
	,      m.value->>'status'           as status
	from trello t
	,    jsonb_array_elements(t.doc#>'{members}') m
;

create view trello_card as
	select t.id                          as doc_id
	,      c.value->>'id'                as id
	,      c.value->>'name'              as name
	,      c.value->>'desc'              as description
	,      (c.value->>'pos')::numeric    as pos
	,      c.value->>'url'               as url
	,      replace(c.value->>'due','T',' ')::timestamp with time zone as due
	,      c.value->'dueComplete'='true' as due_complete
	,      c.value->'closed'='true'      as closed
	,      c.value->'subscribed'='true'  as subscribed
	,      c.value->>'idList'            as id_list
	,      c.value->'idLabels'           as id_labels --jsonb array[string]
	,      c.value->'idMembers'          as id_members --jsonb array[string]
	,      replace(c.value->>'dateLastActivity','T',' ')::timestamp with time zone as date_last_activity
	from trello t
	,    jsonb_array_elements(t.doc#>'{cards}') c
	order by 5
;
