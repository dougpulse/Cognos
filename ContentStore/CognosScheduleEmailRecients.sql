
create table #report (
	ReportId int,
	ReportName varchar(256),
	ReportPath varchar(4000)
)

create table #schedules (
	ScheduleId int,
	ObjectName varchar(256),
	ObjectPath varchar(4000),
	ReportId int
)

create table #ScheduleDelivery (
	CMID int,
	DELIVOPTIONS ntext,
	CAMID xml,
	Email xml
)

create table #CAMID (
	id int identity(1,1),
	CMID int,
	ReportName varchar(100),
	ReportPath varchar(500),
	SchedulePath varchar(500),
	CAMID xml
)

create table #Email (
	id int identity(1,1),
	CMID int,
	ReportName varchar(100),
	ReportPath varchar(500),
	SchedulePath varchar(500),
	Email xml
)

create table #output (
	id int identity(1,1),
	CMID int,
	ReportName varchar(100),
	ReportPath varchar(500),
	SchedulePath varchar(500),
	email varchar(100)
)

--================================================================================
--	get locations of reports and report views
;
with cte(PCMID, 
		 CMID, 
		 ReportId, 
		 ReportName, 
		 ReportPath, 
		 done, 
		 RootNode) as 

(
	select o.PCMID
	, n.CMID
	, n.CMID
	, n.NAME
	, cast(n.NAME as varchar(max))
	, 0
	, cast(n.NAME as varchar(max))
	from CMOBJECTS o
	  inner join CMOBJNAMES n on n.CMID = o.CMID
	  inner join CMCLASSES c on c.CLASSID = o.CLASSID
	where n.ISDEFAULT = 1
	  and isdate(n.NAME) = 0
	  and c.name in ('report')--, 'reportview')

	union all
	select o.PCMID
	, n.CMID
	, cte.ReportId
	, cte.ReportName
	, cast(n.NAME + '/' + cte.ReportPath as varchar(max))
	, case when left(n.NAME, 8) = 'AuthenticationNamespaceName:' then 1 else 0 end
	, cast(n.NAME as varchar(max))
	from CMOBJECTS o
	  inner join CMOBJNAMES n on n.CMID = o.CMID
	  inner join cte cte on cte.PCMID = n.CMID
	where n.ISDEFAULT = 1
	  and n.CMID != 0
	  and cte.done = 0
)

insert #report
select c.ReportId
, c.ReportName
, replace(c.ReportPath, c.RootNode, isnull(u.Name, c.RootNode)) as ReportPath
from cte c
  left outer join (
	select a.OBJID
	, b.NAME

	from CMOBJPROPS1 a
		inner join CMOBJPROPS33 b on b.CMID = a.CMID
  ) u on u.OBJID = c.RootNode
where (c.ReportPath like 'Team Content%'
	or  c.ReportPath like 'AuthenticationNamespaceName:%')	--	"My Content"
order by ReportPath



--================================================================================
--	get locations of schedules
;
with cte(PCMID, 
		 CMID, 
		 ScheduleId, 
		 ObjectName, 
		 ObjectPath, 
		 done, 
		 RootNode, 
		 ReportId) as 

(
	select o.PCMID
	, n.CMID
	, n.CMID
	, n.NAME
	, cast(n.NAME as varchar(max))
	, 0
	, cast(n.NAME as varchar(max))
	, 0
	from CMOBJECTS o
	  inner join CMOBJNAMES n on n.CMID = o.CMID
	  inner join CMCLASSES c on c.CLASSID = o.CLASSID
	where n.ISDEFAULT = 1
	  and c.name = 'schedule'

	union all
	select o.PCMID
	, n.CMID
	, cte.ScheduleId
	, cte.ObjectName
	, cast(n.NAME + '/' + cte.ObjectPath as varchar(max))
	, case when left(n.NAME, 8) = 'AuthenticationNamespaceName:' then 1 else 0 end
	, cast(n.NAME as varchar(max))
	, case
		when c.NAME in ('report', 'reportview') then o.CMID
		else cte.ReportId
	  end
	from CMOBJECTS o
	  inner join CMOBJNAMES n on n.CMID = o.CMID
	  inner join CMCLASSES c on c.CLASSID = o.CLASSID
	  inner join cte cte on cte.PCMID = n.CMID
	where n.ISDEFAULT = 1
	  and n.CMID != 0
	  and cte.done = 0
)

insert #schedules
select c.ScheduleId
, c.ObjectName
, replace(c.ObjectPath, c.RootNode, isnull(u.Name, c.RootNode)) as ObjectPath
, c.ReportId
from cte c
  left outer join (
	select a.OBJID
	, b.NAME

	from CMOBJPROPS1 a
		inner join CMOBJPROPS33 b on b.CMID = a.CMID
  ) u on u.OBJID = c.RootNode
where c.ObjectPath like 'Team Content%'
  or c.ObjectPath like 'AuthenticationNamespaceName:%'
order by ObjectPath



--================================================================================
--	get delivery info as xml
insert #ScheduleDelivery
select CMID
, DELIVOPTIONS
, cast(case
	when cast(DELIVOPTIONS as varchar(max)) like '%to;%'
		then replace(replace(SUBSTRING(cast(DELIVOPTIONS as varchar(max)), CHARINDEX('<value xsi', cast(DELIVOPTIONS as varchar(max)), CHARINDEX('to;', cast(DELIVOPTIONS as varchar(max))) + 4), CHARINDEX('</value>', cast(DELIVOPTIONS as varchar(max)), CHARINDEX('<value xsi', cast(DELIVOPTIONS as varchar(max)), CHARINDEX('to;', cast(DELIVOPTIONS as varchar(max))) + 4)) - CHARINDEX('<value xsi', cast(DELIVOPTIONS as varchar(max)), CHARINDEX('to;', cast(DELIVOPTIONS as varchar(max))) + 4) + 8), 'xsi:type', 'type'), 'SOAP-ENC:arrayType', 'arrayType')
	else ''
  end as xml) as CAMID
, cast(case
	when cast(DELIVOPTIONS as varchar(max)) like '%toAddress;%'
		then replace(replace(SUBSTRING(cast(DELIVOPTIONS as varchar(max)), CHARINDEX('<value xsi', cast(DELIVOPTIONS as varchar(max)), CHARINDEX('toAddress;', cast(DELIVOPTIONS as varchar(max))) + 4), CHARINDEX('</value>', cast(DELIVOPTIONS as varchar(max)), CHARINDEX('<value xsi', cast(DELIVOPTIONS as varchar(max)), CHARINDEX('toAddress;', cast(DELIVOPTIONS as varchar(max))) + 4)) - CHARINDEX('<value xsi', cast(DELIVOPTIONS as varchar(max)), CHARINDEX('toAddress;', cast(DELIVOPTIONS as varchar(max))) + 4) + 8), 'xsi:type', 'type'), 'SOAP-ENC:arrayType', 'arrayType')
	else ''
  end as xml) as Email

from CMOBJPROPS26

where cast(DELIVOPTIONS as varchar(max)) like 'saveOutput%'
  and cast(DELIVOPTIONS as varchar(max)) like '%email;runOptionEnum;runOptionBoolean;__;<value xsi:type="xsd:boolean">true</value>%'
  


--================================================================================

insert #CAMID
select sd.CMID
, r.ReportName
, r.ReportPath
, s.ObjectPath
, sd.CAMID
from #ScheduleDelivery sd
	inner join #schedules s on s.ScheduleId = sd.CMID
	inner join #report r on r.ReportId = s.ReportId
where cast(sd.CAMID as varchar(max)) <> ''

insert #Email
select sd.CMID
, r.ReportName
, r.ReportPath
, s.ObjectPath
, sd.Email
from #ScheduleDelivery sd
	inner join #schedules s on s.ScheduleId = sd.CMID
	inner join #report r on r.ReportId = s.ReportId
where cast(sd.Email as varchar(max)) <> ''


declare @maxId int
select @maxId = max(id)
from #CAMID

declare @i int
set @i = 1

declare @CMID int
declare @ReportName varchar(100)
declare @ReportPath varchar(500)
declare @SchedulePath varchar(500)
declare @arrlen int

declare @x xml
declare @xOut varchar(128)


while @i <= @maxId
begin
	select @CMID = CMID
	, @ReportName = ReportName
	, @ReportPath = ReportPath
	, @SchedulePath = SchedulePath
	, @x = CAMID
	from #CAMID n
	where id = @i

	insert #output
	select x.cmid
	, rn
	, rp
	, sp
	, b.NAME
	from (
		select @CMID as cmid
		, @ReportName as rn
		, @ReportPath as rp
		, @SchedulePath as sp
		, replace(replace(pd.value('text()[1]', 'varchar(128)'), 'CAMID("', ''), '")', '') as camid
		from @x.nodes('//value') as x(Rec)
		cross apply @x.nodes('//value/item') as i(pd)
	  ) x
	  inner join CMOBJPROPS1 a on a.OBJID = x.camid
	  inner join CMOBJPROPS33 b on b.CMID = a.CMID

	set @i = @i + 1
end



select @maxId = max(id)
from #Email

set @i = 1

while @i <= @maxId
begin
	select @CMID = CMID
	, @ReportName = ReportName
	, @ReportPath = ReportPath
	, @SchedulePath = SchedulePath
	, @x = Email
	from #Email n
	where id = @i

	insert #output
	select @CMID
	, @ReportName
	, @ReportPath
	, @SchedulePath
	, pd.value('text()[1]', 'varchar(128)')
	from @x.nodes('//value') as x(Rec)
	cross apply @x.nodes('//value/item') as i(pd)

	set @i = @i + 1
end


select *
from #output


drop table #report
drop table #schedules
drop table #ScheduleDelivery
drop table #CAMID
drop table #Email
drop table #output
