use IBMCognos
go
;
declare @DirectoryNamespace varchar(128) = 'MyNamespaceName'
;
with
capability as (
  select o.CMID

  from CMOBJECTS o
    inner join CMOBJNAMES n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID

  where n.ISDEFAULT = 1
    and n.NAME = 'Capability'
    and c.NAME = 'capability'
), 
capabilities as (
  select cast(n.NAME as varchar(max)) as CapabilityPath
  , n.NAME
  , c.NAME as class
  , o.CMID
  , o.PCMID
  , o.DISABLED

  from CMOBJECTS o
    inner join CMOBJNAMES n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    --inner join capability cap on cap.CMID = o.PCMID

  where n.ISDEFAULT = 1
    and n.NAME = 'Capability'
    and c.NAME = 'capability'

  union all
  select cast(cap.CapabilityPath + '/' + n.NAME as varchar(max))
  , n.NAME
  , c.NAME
  , o.CMID
  , o.PCMID
  , o.DISABLED
  from capabilities cap
    inner join CMOBJECTS o on o.PCMID = cap.CMID
    inner join CMOBJNAMES n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID

  where n.ISDEFAULT = 1
)

select *
into #capabilities
from capabilities
;
with 
capabilitypolicy as (
  select c.CapabilityPath
  --, c.NAME
  --, c.class
  --, c.CMID
  --, c.PCMID
  , c.DISABLED
  , CONVERT(varchar(max), CONVERT(varbinary(max), p.POLICIES, 1), 2) as pol
  from #capabilities c
    inner join CMPOLICIES p on p.CMID = c.CMID
),
cte (
  CapabilityPath,
  pol,
  l,
  pos,
  curr,
  valout
) as (
  --  Loop through the value 2 characters (1 hex value) at a time.
  --  Convert each value to ASCII.
  --  We'll replace anything small (non-printing characters) with LF to keep it simple.
  --    That may not be the best solution.
  select CapabilityPath
  , pol
  , len(pol) as l
  , 3 as pos
  , substring(pol, 1, 2) as curr
  , case
    when convert(int, convert(varbinary, '0x' + substring(pol, 1, 2), 1)) < 32 then char(10)
    else cast(cast(convert(binary(2), '0x' + substring(pol, 1, 2), 1) as char(1)) as varchar(max))
  end as valout
  from capabilitypolicy
  union all
  select CapabilityPath
  , pol
  , l
  , pos + 2 as pos
  , substring(pol, pos, 2) as curr
  , valout + 
    case
      when convert(int, convert(varbinary, '0x' + substring(pol, pos, 2), 1)) < 32 then char(10)
      else cast(cast(convert(binary(2), '0x' + substring(pol, pos, 2), 1) as char(1)) as varchar(max))
    end as valout
  from cte
  where pos < l
), 
cte2 as (
  -- Rank to identify the final value.
  select *
  , rank() over (partition by CapabilityPath order by pos desc) as rnk
  from cte
),
a as (
  --  We need only the results of the last step.
  select CapabilityPath
  , valout
  from cte2
  where rnk = 1
),
q as (
  select CapabilityPath
  , ROW_NUMBER() over (partition by CapabilityPath order by CapabilityPath) as rownum   --  not reliable because string_split doesn't guarantee order until SQL 2022
  --, ROW_NUMBER() over (partition by CapabilityPath order by ordinal) as rownum --  Use with SQL 2022 or later
  , value as val
  --, substring(value, 11, 32) as val
  from a
    cross apply string_split(valout, char(10))   --  not reliable because string_split doesn't guarantee order until SQL 2022
    --cross apply string_split(valout, char(10), 1) --  Use with SQL 2022 or later
)

--  Using a temporary table here reduces run time from 88 seconds to 8 seconds.
select *
into #q
from q
OPTION (MAXRECURSION 0)

--select *
--from #q
--order by CapabilityPath
;

with
perms as (
  select perm
  from (
    values
      ('execute')
    , ('read')
    , ('setPolicy')
    , ('traverse')
    , ('write')
  ) v (perm)
),
capabilityPerms as (
  select q.CapabilityPath
  , q.rownum
  , n.NAME
  from #q q
    inner join CMOBJNAMES n on n.CMID = cast(SUBSTRING(val, 3, CHARINDEX(':', val, 3) - 3) as int)
  where q.val like '::%'
    and CHARINDEX(':', val, 3) > 0
    and n.ISDEFAULT = 1

  union
  select q.CapabilityPath
  , q.rownum
  , SUBSTRING(val, 3, 400) as 'Name'
  from #q q
  where q.val like '::%'
    and CHARINDEX(':', val, 3) = 0

  union
  select q.CapabilityPath
  , q.rownum
  , 'WSDOT\' + u.NAME
  from #q q
    inner join CMOBJNAMES n on n.NAME = q.val
    inner join cmobjprops33 u on u.CMID = n.CMID
  where n.NAME like @DirectoryNamespace + '%'

  union
  select q.CapabilityPath
  , q.rownum
  , p.perm
  from #q q
    inner join perms p on q.val like '%' + p.perm + '%'
),
--capabilityPermType as (
--  select cp.CapabilityPath
--  , cp.rownum
--  , cp.NAME
--  from capabilityPerms cp
--    inner join perms p on p.perm = cp.NAME
--),
executeStart as (
  select cp.CapabilityPath
  , cp.rownum
  , cp.NAME
  from capabilityPerms cp
  where cp.NAME = 'execute'
),
readStart as (
  select cp.CapabilityPath
  , cp.rownum
  , cp.NAME
  from capabilityPerms cp
  where cp.NAME = 'read'
),
setPolicyStart as (
  select cp.CapabilityPath
  , cp.rownum
  , cp.NAME
  from capabilityPerms cp
  where cp.NAME = 'setPolicy'
),
traverseStart as (
  select cp.CapabilityPath
  , cp.rownum
  , cp.NAME
  from capabilityPerms cp
  where cp.NAME = 'traverse'
),
writeStart as (
  select cp.CapabilityPath
  , cp.rownum
  , cp.NAME
  from capabilityPerms cp
  where cp.NAME = 'write'
),
permClass as (
  select cp.CapabilityPath
  , cp.rownum
  , cp.NAME
  , es.rownum as executeStart
  , rs.rownum as readStart
  , ss.rownum as setPolicyStart
  , ts.rownum as traverseStart
  , ws.rownum as writeStart
  from capabilityPerms cp
    left outer join executeStart es on es.CapabilityPath = cp.CapabilityPath
    left outer join readStart rs on rs.CapabilityPath = cp.CapabilityPath
    left outer join setPolicyStart ss on ss.CapabilityPath = cp.CapabilityPath
    left outer join traverseStart ts on ts.CapabilityPath = cp.CapabilityPath
    left outer join writeStart ws on ws.CapabilityPath = cp.CapabilityPath
)

select c.CapabilityPath
, case
    when pc.rownum between coalesce(pc.executeStart, 999) and coalesce(pc.readStart, pc.setPolicyStart, pc.traverseStart, pc.writeStart, 999)
      then 'execute'
    when pc.rownum between coalesce(pc.readStart, 999) and coalesce(pc.setPolicyStart, pc.traverseStart, pc.writeStart, 999)
      then 'read'
    when pc.rownum between coalesce(pc.setPolicyStart, 999) and coalesce(pc.traverseStart, pc.writeStart, 999)
      then 'setPolicy'
    when pc.rownum between coalesce(pc.traverseStart, 999) and coalesce(pc.writeStart, 999)
      then 'traverse'
    when pc.rownum between coalesce(pc.writeStart, 999) and 999
      then 'write'
    else 'inherited'
  end as permission
, pc.NAME
from #capabilities c
  left outer join permClass pc on pc.CapabilityPath = c.CapabilityPath
                              and pc.NAME not in (
                                                   select perm
                                                   from perms
                                                 )
  --and pc.NAME = 'BI Administrators'
order by 1, 2, 3

drop table #q
drop table #capabilities
