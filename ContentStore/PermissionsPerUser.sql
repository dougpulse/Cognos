
declare @CognosUserName varchar(max) = 'Hyperion Collision Power User'
declare @CognosUserType varchar(max) = 'group'

declare @querystring nvarchar(max) = 'SELECT ''WSDOTAD:' + left(@CognosUserType, 1) + ':'' + convert(varchar(max), ObjectGUID, 2) as ObjectGUID
FROM OpenQuery ( 
  ADSI,
  ''SELECT sAMAccountName, ObjectGUID 
  FROM  ''''LDAP://WSDOT.LOC/DC=WSDOT,DC=LOC''''
  WHERE objectClass =  ''''' + @CognosUserType + ''''' 
    and sAMAccountName = ''''' + @CognosUserName + '''''
  ''
) A'

declare @ObjectGUID table (
  ObjectGUID varchar(max)
)
insert into @ObjectGUID
exec sp_executesql @querystring

declare @pol table (
  CMID int,
  POLICIES varbinary(max)
)

declare @b64 table (
  id int identity(1,1) not null,
  cmid int,
  POLICIES varchar(max),
  PolicyReadable varchar(max)
)

declare @heirarchy table (
  CMID int,
  ObjectName varchar(max),
  ObjectPath varchar(max)
)

insert @pol
select CMID
, cast(POLICIES as varbinary(max)) as POLICIES
from CMPOLICIES
WHERE POLICIES IS NOT NULL
  --and cmid = 2525
  --and cmid = 2339
;

insert @b64 (cmid, POLICIES)
select cmid,
    cast('' as xml).value(
        'xs:base64Binary(sql:column("@pol.POLICIES"))', 'varchar(max)'
    ) AS POLICIES
from @pol
;

with
src (
  CMID,
  ObjectName,
  ObjectPath) as
(
  select o.CMID
  , n.NAME
  , cast(n.NAME as varchar(max))
  from CMOBJECTS o
    inner join CMOBJNAMES n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
  where n.ISDEFAULT = 1
    and isdate(n.NAME) = 0
    and o.CMID = 2
  
  union all
  select o.CMID
  , n.NAME
  , cast(src.ObjectPath + '/' + n.NAME as varchar(max))
  from CMOBJECTS o
    inner join CMOBJNAMES n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    inner join src on src.CMID = o.PCMID
  where n.ISDEFAULT = 1
    and n.CMID != 0
)
insert into @heirarchy
select *
from src
;

declare @j int = 1
declare @jMax int
select @jMax = id
from @b64

while @j <= @jMax
begin
  update @b64
  set PolicyReadable = dbo.udf_CognosPermissions(POLICIES)
  where id = @j

  set @j = @j + 1
end


select o.*
, b.PolicyReadable
from @heirarchy o
  inner join @b64 b on b.CMID = o.CMID
  inner join @ObjectGUID g on b.PolicyReadable like '%' + g.ObjectGUID + '%'
order by ObjectPath

