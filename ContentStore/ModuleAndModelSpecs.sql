use IBMCognos
GO
;

declare @DirectoryNamespace varchar(255) = 'MyNamespace'
declare @DirectoryNamespaceLength int = 11

--  data container full path
--  ...for all packages, modules, uploaded files, and datasets
;
with
objname as (
  select o.CMID
  , coalesce(n2.name, n.NAME) as 'NAME'
  from CMOBJECTS o
    left outer join CMOBJNAMES n on n.CMID = o.CMID
                           and n.LOCALEID = 92
    left outer join CMOBJNAMES n2 on n2.CMID = o.CMID
                           and n2.LOCALEID = 118
),
package (
      PCMID
    , CMID
    , ObjectId
    , ObjectName
    , ObjectPath
    , done
    , RootNode
    , ObjectType
    , ParentObjectType
  ) as (
  select o.PCMID
  , n.CMID
  , n.CMID
  , cast(n.NAME as varchar(550))
  , cast(n.NAME as varchar(max))
  , 0
  , cast(n.NAME as varchar(max))
  , c.NAME
  , cast(null as varchar(50))
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
  --where c.name in ('package', 'module', 'uploadedFile', 'dataSet2')
  --where c.name in ('module', 'model')
  --  and n.NAME in ('! BigBudgetModule', 'May New data module')
  --where c.name = 'model'

  union all
  select o.PCMID
  , n.CMID
  , p.ObjectId
  , cast(
    case 
      when p.ParentObjectType is null
        then
          case 
            when c.NAME = 'folder'
              then p.ObjectName
            when c.NAME = 'package'
              then n.NAME
            when c.NAME = 'exploration'
              then n.NAME + '--' + p.ObjectName
          end
      else p.ObjectName
    end as varchar(550))
  , case
      when p.ParentObjectType is null and c.NAME = 'package'
        then cast(n.NAME as varchar(max))
      else cast(n.NAME + '/' + p.ObjectPath as varchar(max))
    end
  , case when left(n.NAME, @DirectoryNamespaceLength + 1) = @DirectoryNamespace + ':' then 1 else 0 end
  , cast(n.NAME as varchar(max))
  , p.ObjectType
  , case when p.ParentObjectType is null then c.NAME else p.ParentObjectType end
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    inner join package p on p.PCMID = n.CMID
  where n.CMID != 0
    and p.done = 0
),
content as (
  --  There will be many paths for the same object.
  --  Keep only the path for each that starts at the root.
  select p.ObjectId
       , p.ObjectName
       , p.ObjectType
       , replace(replace(p.ObjectPath, p.RootNode, isnull(u.Name, p.RootNode)), '/(en) ', '/') as ObjectPath
       , p.ParentObjectType
  
  from package p
    left outer join (
    select a.OBJID
    , b.NAME

    from CMOBJPROPS1 a
      inner join CMOBJPROPS33 b on b.CMID = a.CMID
    ) u on u.OBJID = p.RootNode
  where (p.ObjectPath like 'Team Content%'
    or   p.ObjectPath like @DirectoryNamespace + ':%')
),
objprops86 as (
  select s.CMID
  , cast(s.CBASEDEF as varchar(max)) as CBASEDEF
  from CMOBJPROPS86 s
),
zip as (
  select  
    d.ObjectId
  , d.ObjectName
  , d.ObjectType
  , d.ParentObjectType
  , d.ObjectPath
  --, module.CBASEDEF AS CBASEDEF_BASE64
  , case d.ObjectType
      when 'module' then CAST('' AS XML).value('xs:base64Binary(sql:column("module.CBASEDEF"))', 'VARBINARY(MAX)')
      when 'model' then cast(model.cmodel as varbinary(max))
    end as CBASEDEF_COMPRESSED
  from content d
    left outer join objprops86 module on module.CMID = d.ObjectId
    left outer join CMOBJPROPS7 model on model.CMID = d.ObjectId
)

select  
  ObjectId
, ObjectName
, ObjectType
, ParentObjectType
, ObjectPath
--, CBASEDEF_BASE64
, CBASEDEF_COMPRESSED
--, cast(cbasedef_compressed as varchar(max)) as CBASEDEF_COMPRESSED_vc
, CASE CAST(LEFT(CBASEDEF_COMPRESSED, 4) AS VARBINARY(MAX))
    WHEN 0x1F8B0800 THEN 'GZIP'
    WHEN 0x504B0304 THEN 'ZIP'
  END AS FILE_TYPE
, CASE CAST(LEFT(CBASEDEF_COMPRESSED, 2) AS VARBINARY(MAX))
    WHEN 0x1F8B 
      THEN CONVERT(VARCHAR(MAX), DECOMPRESS (CBASEDEF_COMPRESSED))
    WHEN 0x504B 
      THEN 'TODO:  UNZIP PKZIP BINARY'
  END as CBASEDEF_STRING

into #outputs

from zip

order by ObjectPath

/*
model    CMOBJPROPS7.CMODEL
package  (model contains spec)
module   CMOBJPROPS86.CBASEDEF


TODO:  
unzip ZIP binary
extract data source(s) from models (xml)
extract data source(s) from modules (json)

drop table #zip

*/


/* ************************************************************************* */
/* ************************************************************************* */

/*
    Now let's go find all of the models that use specific data sources.
*/
select o.ObjectId
, o.ObjectName
, o.ObjectPath
, cast(o.CBASEDEF_STRING as xml) as CBASEDEF_STRING_x
into #models
from #outputs o
where o.FILE_TYPE = 'GZIP'
  and o.ObjectType = 'model'

;
WITH 
--XMLNAMESPACES ('http://www.developer.cognos.com/schemas/bmt/60/12' as ns)
----('http://www.developer.cognos.com/schemas/bmt/60/7' as ns)  --  The version differs per object.  Can we somehow ignore the xml namespace and still get results?  *: to the rescue!
--,
models as (
select o.ObjectId
, o.ObjectPath
--, model.datasource.value('ns:cmDataSource[1]', 'varchar(255)') as DataSource
, model.datasource.value('*:cmDataSource[1]', 'varchar(255)') as DataSource --  *: namespace-unaware in XPath2.0    "This would not work with elements in the default namespace, though." - Rafael Winterhalter on SO
--, model.datasource.value('*[local-name() = "cmDataSource"][1]', 'varchar(255)') as DataSource --  older xpath
from #models o
  --cross apply o.CBASEDEF_STRING_x.nodes('/ns:project/ns:dataSources/ns:dataSource') as model(datasource)
  cross apply o.CBASEDEF_STRING_x.nodes('/*:project/*:dataSources/*:dataSource') as model(datasource)
  --cross apply o.CBASEDEF_STRING_x.nodes('/*[local-name() = "project"]/*[local-name() = "dataSources"]/*[local-name() = "dataSource"]') as model(datasource)
)
select *
from models
where DataSource in (
  'My Data Source'
, 'My Other Data Source'
)
order by 2, 3

/* ************************************************************************* */
/* ************************************************************************* */


drop table #models
drop table #outputs
