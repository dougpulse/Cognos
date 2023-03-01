;
with cte(
  PCMID, 
  CMID, 
  ReportName, 
  ReportPath, 
  done, 
  RootNode
  ) as 
(
  select o.PCMID
  , o.CMID
  , n.NAME
  , cast(n.NAME as varchar(max))
  , 0
  , cast(n.NAME as varchar(max))

  from CMOBJECTS o
    inner join CMOBJNAMES n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    inner join CMREFNOORD1 r on r.CMID = o.CMID
    inner join CMOBJECTS b on b.CMID = r.REFCMID
    inner join CMOBJECTS do on do.CMID = b.PCMID
    inner join CMOBJNAMES dn on dn.CMID = do.CMID

  where n.ISDEFAULT = 1
    and c.NAME in ('reportView', 'shortcut')
    and dn.NAME = 'Deleted Object Folder'

  union all
  select o.PCMID
  , o.CMID
  , cte.ReportName
  , cast(n.NAME + '/' + cte.ReportPath as varchar(max))
  , case when left(n.NAME, 8) = 'MyNamespace:' then 1 else 0 end
  , cast(n.NAME as varchar(max))

  from CMOBJECTS o
    inner join CMOBJNAMES n on n.CMID = o.CMID
    inner join cte cte on cte.PCMID = o.CMID

  where n.ISDEFAULT = 1
    and n.CMID != 0
    and cte.done = 0
)


select replace(c.ReportPath, c.RootNode, isnull(u.Name, c.RootNode)) as ReportPath

from cte c
  left outer join (
  select a.OBJID
  , b.NAME

  from CMOBJPROPS1 a
    inner join CMOBJPROPS33 b on b.CMID = a.CMID
  ) u on u.OBJID = c.RootNode

where (c.ReportPath like 'Team Content%'
  or  c.ReportPath like 'MyNamespace:%')

order by ReportPath
