drop table if exists trello cascade
;

create table trello
(   id   serial  PRIMARY KEY
,   doc  jsonb   NOT NULL
)
;

create view trello_board
as
	select id                as doc_id --int id
	,      t.doc->>'id'      as id
	,      t.doc->>'name'    as name
	,      t.doc->>'desc'    as desc
	,      t.doc->>'pinned'  as pinned
	,      t.doc->>'starred' as starred
	,      t.doc->>'url'     as url
	,      t.doc->>'closed'  as closed
	,      replace(t.doc->>'dateLastActivity','T',' ')::timestamp with time zone as date_last_activity
	,      replace(t.doc->>'dateLastView','T',' ')::timestamp with time zone     as date_last_view
	from trello t
;

-- NIET GEBRUIKEN: prefs; labelNames (redundant); 
-- OF LATER: actions, checklists, memberships
-- Views voor: labels, lists, members
create view trello_label
as
	select t.id              as doc_id
--	,      t.doc->>'id'      as board_id
	,      l.value->>'id'    as id
	,      l.value->>'name'  as name
	,      l.value->>'color' as color
	from trello t
	,    jsonb_array_elements(t.doc#>'{labels}') l
;

create view trello_list
as
	select t.id                as doc_id
--	,      t.doc->>'id'        as board_id
	,      l.value->>'id'      as id
	,      l.value->>'name'    as name
	,      l.value->>'pos'     as pos
	,      l.value->>'closed'  as closed
	from trello t
	,    jsonb_array_elements(t.doc#>'{lists}') l
;

create view trello_member
as
	select t.id                   as doc_id
--	,      t.doc->>'id'           as board_id
	,      m.value->>'id'         as id
	,      m.value->>'bio'        as bio
	,      m.value->>'url'        as url
	,      m.value->>'fullName'   as fullName
	,      m.value->>'initials'   as initials
	,      m.value->>'username'   as username
	,      m.value->>'avatarUrl'  as avatarUrl
	,      m.value->>'confirmed'  as confirmed
	from trello t
	,    jsonb_array_elements(t.doc#>'{members}') m
;

create view trello_card as
	select t.id                             as doc_id
--	,      t.doc->>'id'                     as board_id
	,      c.value->>'id'                   as id
	,      c.value->>'name'                 as name
	,      c.value->>'url'                  as url
	,      replace(c.value->>'due','T',' ')::timestamp with time zone as due
	,      c.value->>'due_complete'         as due_complete
	,      c.value->>'idBoard'              as id_board
	,      c.value->>'idLabels'             as id_labels     --rather have: #>'{labels,,color}'
	,      c.value->>'idMembers'            as id_members    --rather join in: '{members,username}'
	,      c.value->>'idList'               as id_list
	,      replace(c.value->>'dateLastActivity','T',' ')::timestamp with time zone as date_last_activity
	from trello t
	,    jsonb_array_elements(t.doc#>'{cards}') c
;

create view trello_card_label as
	select t.id              as doc_id
	,      t.doc->>'id'      as board_id
	,      c.value->>'id'    as card_id
	,      l.value           as label_id
	from trello t
	,    jsonb_array_elements(t.doc#>'{cards}') c
	,    jsonb_array_elements(c#>'{idLabels}') l
;
