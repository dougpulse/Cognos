--  objects owned by the selected user
;
declare @DirectoryNamespace varchar(255) = '$AuthenticationNamespace'
declare @username nvarchar(256) = N'username'
;
with 
objname as (
  select o.CMID
  , coalesce(n2.name, n.NAME) as 'NAME'
  from CMOBJECTS o
    left outer join CMOBJNAMES n on n.CMID = o.CMID
                           and n.LOCALEID = 92		--	en
    left outer join CMOBJNAMES n2 on n2.CMID = o.CMID
                           and n2.LOCALEID = 118	--	en-us
),
usr as (
  select u.CMID
  from CMOBJPROPS33 u
  where u.NAME = @username
), 
userobjects as (
  select o.CMID
  , o.MODIFIED
  , o.OWNER
  , n.NAME
  , c.NAME as Class
  , po.CMID as ParentCMID
  , po.OWNER as ParentOwner
  , pn.NAME as ParentName
  , pc.NAME as ParentClass
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    inner join CMREFNOORD2 n2 on n2.CMID = o.CMID
    inner join CMOBJECTS po on po.CMID = o.PCMID
    inner join objname pn on pn.CMID = po.CMID
    inner join CMCLASSES pc on pc.CLASSID = po.CLASSID
    inner join usr u on u.CMID = n2.REFCMID
), 
cte(
  PCMID, 
  CMID, 
  ObjectId, 
  ObjectName, 
  ObjectPath, 
  done, 
  RootNode,
  ObjectClass
  ) as (
  select o.PCMID
  , n.CMID
  , n.CMID
  , n.NAME
  , cast(n.NAME as varchar(max))
  , 0
  , cast(n.NAME as varchar(max))
  , c.NAME
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    inner join userobjects uo on uo.CMID = o.CMID
  
  union all
  select o.PCMID
  , n.CMID
  , cte.ObjectId
  , cte.ObjectName
  , cast(n.NAME + '/' + cte.ObjectPath as varchar(max))
  , case when left(n.NAME, 8) = @DirectoryNamespace + ':' then 1 else 0 end
  , cast(n.NAME as varchar(max))
  , cte.ObjectClass
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join cte cte on cte.PCMID = n.CMID
  where n.CMID != 0
    and cte.done = 0
)

select c.ObjectId
, c.ObjectName
, replace(c.ObjectPath, c.RootNode, isnull(u.Name, c.RootNode)) as ObjectPath
, c.ObjectClass
into #reports
from cte c
  left outer join (
  select a.OBJID
  , b.NAME

  from CMOBJPROPS1 a
    inner join CMOBJPROPS33 b on b.CMID = a.CMID
  ) u on u.OBJID = c.RootNode
where (c.ObjectPath like 'Team Content%'
  or  c.ObjectPath like @DirectoryNamespace + ':%')
order by ObjectPath

select *
from #reports
order by ObjectPath

drop table #reports
