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
	order by 3
;

--   views: actions, cards, checklists, labels, lists, members
--no views: customFields, idTags, labelNames, limits, memberships, pluginData, powerUps, prefs

create view trello_action as
	select t.id                          as doc_id
	,      c.value->>'id'                as id
	,      c.value->>'type'              as type
	,      c.value->>'idMemberCreator'   as id_member_creator
	,      replace(c.value->>'date','T',' ')::timestamp with time zone as date
	from trello t
	,    jsonb_array_elements(t.doc#>'{actions}') c
	order by 1
	,        5
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
	order by 1
	,        5
;

create view trello_checklist
as
	select t.id                        as doc_id
	,      c.value->>'id'              as id
	,      c.value->>'name'            as name
	,      (c.value->>'pos')::numeric  as pos
	,      c.value->>'idCard'          as id_card
	from trello t
	,    jsonb_array_elements(t.doc#>'{checklists}') c
	order by 1
	,        4
;

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
	order by 1
	,        4
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
	order by 3
;

-- other helpful views

create view trello_all_ids
as
with the_data as (
		select l.value->>'id'  as id
		,      'label'         as what
		,      array_agg(t.id) as doc_ids
		from trello t
		,    jsonb_array_elements(t.doc#>'{labels}') l
		group by 1
	union
		select l.value->>'id'  as id
		,      'list'         as what
		,      array_agg(t.id) as doc_ids
		from trello t
		,    jsonb_array_elements(t.doc#>'{lists}') l
		group by 1
	union
		select l.value->>'id'  as id
		,      'member'        as what
		,      array_agg(t.id) as doc_ids
		from trello t
		,    jsonb_array_elements(t.doc#>'{members}') l
		group by 1
	union
		select l.value->>'id'  as id
		,      'card'          as what
		,      array_agg(t.id) as doc_ids
		from trello t
		,    jsonb_array_elements(t.doc#>'{cards}') l
		group by 1
	union
		select l.value->>'id'  as id
		,      'action'        as what
		,      array_agg(t.id) as doc_ids
		from trello t
		,    jsonb_array_elements(t.doc#>'{actions}') l
		group by 1
	union
		select l.value->>'id'  as id
		,      'membership'    as what
		,      array_agg(t.id) as doc_ids
		from trello t
		,    jsonb_array_elements(t.doc#>'{memberships}') l
		group by 1
	union
		select l.value->>'id'  as id
		,      'checklist'     as what
		,      array_agg(t.id) as doc_ids
		from trello t
		,    jsonb_array_elements(t.doc#>'{checklists}') l
		group by 1
	)
	select what
	,      id
	-- Trello id's generated in MongoDB: https://steveridout.github.io/mongo-object-time/
	,      to_timestamp(('x'||substring(id for 8))::bit(32)::int) as creation_date
	from the_data
	order by 1
	,        2
;
