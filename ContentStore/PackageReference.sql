--  find data containers (packages, modules, uploaded files, and datasets) that are not used
use IBMCognos
GO
/*
    Package Usage
    Are packages used? (by existing presentation outputs)
*/
;
declare @DirectoryNamespace varchar(255) = 'MyNamespace'
declare @DirectoryNamespaceLength int = 11


--  output object full path
--  ...for all reports and dashboards
;
with
objname as (
  select o.CMID
  , coalesce(n2.name, n.NAME) as 'NAME'
  --, n.NAME
  --, n2.NAME
  from CMOBJECTS o
    left outer join CMOBJNAMES n on n.CMID = o.CMID
                           and n.LOCALEID = 92
    left outer join CMOBJNAMES n2 on n2.CMID = o.CMID
                           and n2.LOCALEID = 118
  --order by 2
),
report (PCMID, 
      CMID, 
      ObjectId, 
      ObjectName, 
      ObjectPath, 
      PackageId, 
      done, 
      RootNode, 
      ObjectType) as (
  --  reports
  select o.PCMID
  , n.CMID
  , n.CMID
  , n.NAME
  , cast(n.NAME as varchar(max))
  , r.REFCMID as PackageId
  , 0
  , cast(n.NAME as varchar(max))
  , c.NAME
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    inner join CMREFNOORD1 r on r.CMID = o.CMID --  to get package
  where c.name = 'report'
    --and n.NAME like '%deer%'

  union all
  --  dashboards
  select o.PCMID
  , n.CMID
  , n.CMID
  , n.NAME
  , cast(n.NAME as varchar(max))
  , r.REFCMID as PackageId
  , 0
  , cast(n.NAME as varchar(max))
  , c.NAME
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    inner join CMREFORD1 r on r.CMID = o.CMID --  to get package
  where c.name = 'exploration'
    --and n.NAME like '%daily spend%'

  union all
  --  parent folders
  select o.PCMID
  , n.CMID
  , r.ObjectId
  , r.ObjectName
  , cast(n.NAME + '/' + r.ObjectPath as varchar(max))
  , r.PackageId
  , case when left(n.NAME, @DirectoryNamespaceLength + 1) = @DirectoryNamespace + ':' then 1 else 0 end
  , cast(n.NAME as varchar(max))
  , r.ObjectType
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join report r on r.PCMID = n.CMID
  where n.CMID != 0
    and r.done = 0
)

--  There will be many paths for the same object.
--  Keep only the path for each that starts at the root.
select r.ObjectId
     , r.ObjectName
     , r.ObjectType
     , replace(replace(r.ObjectPath, r.RootNode, isnull(u.Name, r.RootNode)), '/(en) ', '/') as ObjectPath
     , r.PackageId
into #output
from report r
  left outer join (
  select a.OBJID
  , b.NAME

  from CMOBJPROPS1 a
    inner join CMOBJPROPS33 b on b.CMID = a.CMID
  ) u on u.OBJID = r.RootNode
where (r.ObjectPath like 'Team Content%'
  or   r.ObjectPath like @DirectoryNamespace + ':%')
order by ObjectPath
;

--  data container full path
--  ...for all packages, modules, uploaded files, and datasets
with
objname as (
  select o.CMID
  , coalesce(n2.name, n.NAME) as 'NAME'
  --, n.NAME
  --, n2.NAME
  from CMOBJECTS o
    left outer join CMOBJNAMES n on n.CMID = o.CMID
                           and n.LOCALEID = 92
    left outer join CMOBJNAMES n2 on n2.CMID = o.CMID
                           and n2.LOCALEID = 118
  --order by 2
),
package (PCMID, 
        CMID, 
        ObjectId, 
        ObjectName, 
        ObjectPath, 
        done, 
        RootNode, 
        ObjectType) as (
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
  where c.name in ('package', 'module', 'uploadedFile', 'dataSet2')
    --and n.NAME like '%factless%'

  union all
  select o.PCMID
  , n.CMID
  , p.ObjectId
  , p.ObjectName
  , cast(n.NAME + '/' + p.ObjectPath as varchar(max))
  , case when left(n.NAME, @DirectoryNamespaceLength + 1) = @DirectoryNamespace + ':' then 1 else 0 end
  , cast(n.NAME as varchar(max))
  , p.ObjectType
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join package p on p.PCMID = n.CMID
  where n.CMID != 0
    and p.done = 0
)

--  There will be many paths for the same object.
--  Keep only the path for each that starts at the root.
select p.ObjectId
     , p.ObjectName
     , p.ObjectType
     , replace(replace(p.ObjectPath, p.RootNode, isnull(u.Name, p.RootNode)), '/(en) ', '/') as ObjectPath
into #data
from package p
  left outer join (
  select a.OBJID
  , b.NAME

  from CMOBJPROPS1 a
    inner join CMOBJPROPS33 b on b.CMID = a.CMID
  ) u on u.OBJID = p.RootNode
where (p.ObjectPath like 'Team Content%'
  or   p.ObjectPath like @DirectoryNamespace + ':%')
order by ObjectPath
;


--  Identify all instances where a data container uses another data container.
;
with 
subpackages as (
  select p.ObjectId as PackageId
  , p.ObjectPath as PackagePath
  , p.ObjectType as PackageType
  , sp.ObjectId as SubPackageId
  , sp.ObjectPath as SubPackagePath
  , sp.ObjectType as SubPackageType
  , 0 as depth
  
  from #data p
    left outer join CMREFORD1 ro on ro.CMID = p.ObjectId
    left outer join #data sp on sp.ObjectId = ro.REFCMID

  union all
  --    "packages" per data module
  select p.PackageId
  , p.PackagePath
  , p.PackageType
  , sp.ObjectId as SubPackageId
  , sp.ObjectPath as SubPackagePath
  , sp.ObjectType as SubPackageType
  , p.depth + 1
  
  from subpackages p
    inner join CMREFORD1 ro on ro.CMID = p.SubPackageId
    inner join #data sp on sp.ObjectId = ro.REFCMID
  where p.depth < 7 --  because of self-referencing data modules

  union all
  --    "packages" per dataset
  select p.PackageId
  , p.PackagePath
  , p.PackageType
  , sp.ObjectId as SubPackageId
  , sp.ObjectPath as SubPackagePath
  , sp.ObjectType as SubPackageType
  , p.depth + 1
  
  from subpackages p
    inner join CMREFNOORD1 rno on rno.CMID = p.PackageId
    inner join #data sp on sp.ObjectId = rno.REFCMID
  where p.depth < 7 --  because of self-referencing data modules
)

select distinct PackageId
, PackagePath
, PackageType
, SubPackageId
, SubPackagePath
, SubPackageType
into #subdata
from subpackages


--select *
--from #subdata
--where PackagePath like 'Team Content/Reports/Traffic Operations/South Central Traffic/Deer Signs/%'
--order by PackageId
--, SubPackageId

--  Show all data containers
--  Recursively attribute usage to subcontainers
;
with 
scusage as (
  select distinct d.PackageId
  , d.PackagePath
  , d.PackageType
  --, d.SubPackageId
  --, d.SubPackagePath
  --, d.SubPackageType
  , o.ObjectId
  , o.ObjectName
  , o.ObjectPath
  , o.ObjectType
  , 0 as depth
  from #subdata d
    inner join #output o on o.PackageId = d.PackageId
  
  union all
  select sd.PackageId
  , sd.PackagePath
  , sd.PackageType
  , u.ObjectId
  , u.ObjectName
  , u.ObjectPath
  , u.ObjectType
  , u.depth + 1
  from #subdata sd
    inner join #subdata d on d.SubPackageId = sd.PackageId
    inner join scusage u on u.PackageId = d.PackageId
  where u.depth < 3
)

select distinct PackageId
, PackagePath
, PackageType
, ObjectId
, ObjectName
, ObjectPath
, ObjectType
into #scusage
from scusage
order by PackagePath
, ObjectPath



--  Show all data containers and the output objects that use them.
select *
from #scusage
order by PackagePath
, ObjectPath



--  Show all data containers that are not used by any output objects
select distinct d.PackageId
, d.PackagePath
, d.PackageType
from #subdata d

except
select u.PackageId
, u.PackagePath as UnusedPackagePath
, u.PackageType
from #scusage u

order by PackagePath


/*
drop table #data
drop table #output
drop table #subdata
drop table #scusage
*/
