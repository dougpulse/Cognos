--  get locations of schedules
;
with cte(PCMID, 
     CMID, 
     ScheduleId, 
     ObjectName, 
     ObjectPath, 
     done, 
     --RootNode, 
     Modified, 
     ReportId) as 

(
  select o.PCMID
  , n.CMID
  , n.CMID
  , n.NAME
  , cast(n.NAME as varchar(max))
  , 0
  --, cast(n.NAME as varchar(max))
  , o.MODIFIED
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
  , case when left(n.NAME, 8) = 'WSDOTAD:' then 1 else 0 end
  --, cast(n.NAME as varchar(max))
  , cte.Modified
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


select c.ScheduleId
, c.ObjectName
, c.Modified
, c.ObjectPath
, c.ReportId
into #schedules
from cte c
where c.ObjectPath like 'Team Content%'
  --or c.ReportPath like '<DirectoryNamespace>:%'    --  for My Content
order by ObjectPath