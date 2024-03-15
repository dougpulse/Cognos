$CognosEnvironment = Read-Host "Cognos Environment (P, Q, D):"
switch($CognosEnvironment) {
    "P" {
        $dbServer = "ProdDBServer"
        $dbName = "ProdDBName"
    }
    "Q" {
        $dbServer = "QADBServer"
        $dbName = "QADBName"
    }
    "D" {
        $dbServer = "DevDBServer"
        $dbName = "DevDBName"
    }
}

$AuthenticationNamespace = "NamespaceName"
$DomainName = "DomainName"

"



Getting data from the database.
This may take a couple minutes.



"

$sqlquery = "
declare @DirectoryNamespace varchar(128) = '$DirectoryNamespace'
declare @DomainName varchar(255) = '$DomainName'
;
with 
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

  where n.ISDEFAULT = 1
    and c.NAME = 'capability'
    and n.NAME = 'Capability'

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
  --select CapabilityPath
  --, ROW_NUMBER() over (partition by CapabilityPath order by CapabilityPath) as rownum   --  not reliable because string_split doesn't guarantee order until SQL 2022
  ----, ROW_NUMBER() over (partition by CapabilityPath order by ordinal) as rownum --  Use with SQL 2022 or later
  --, value as val
  ----, substring(value, 11, 32) as val
  --from a
  --  cross apply string_split(valout, char(10))   --  not reliable because string_split doesn't guarantee order until SQL 2022
  --  --cross apply string_split(valout, char(10), 1) --  Use with SQL 2022 or later

  --  SQL Server 2012 does not have string_split()
  SELECT CapabilityPath
  , ROW_NUMBER() over (partition by CapabilityPath order by CapabilityPath) as rownum
  , Split.a.value('.', 'NVARCHAR(MAX)') val
  FROM (
      SELECT CapabilityPath
      , CAST('<X>' + 
          REPLACE(
            replace(
              replace(
                replace(
                  replace(
                    replace(
                      valout, '`"', char(10)
                    ), '<', char(10)
                  ), '>', char(10)
                ), '&', char(10)
              ), '''', char(10)
            ), char(10), '</X><X>'
          ) + '</X>' AS XML
        ) AS String
      from a
  ) AS A
  CROSS APPLY String.nodes('/X') AS Split(a)
)

--  Using a temporary table here reduces run time from 88 seconds to 8 seconds.
select *
into #q
from q
OPTION (MAXRECURSION 0)

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
  --  Cognos roles
  select q.CapabilityPath
  , q.rownum
  , n.NAME
  from #q q
    inner join CMOBJNAMES n on n.CMID = cast(SUBSTRING(q.val, 3, CHARINDEX(':', q.val, 3) - 3) as int)
    inner join CMOBJECTS o on o.CMID = n.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
  where q.val like '::%'
    and CHARINDEX(':', val, 3) > 0
    and n.ISDEFAULT = 1
    and c.NAME = 'role'

  --  Cognos groups?  Cognos groups and users?
  union
  select q.CapabilityPath
  , q.rownum
  , SUBSTRING(val, 3, 400) as 'Name'
  from #q q
  where q.val like '::%'
    and CHARINDEX(':', val, 3) = 0
  
  --  AD groups and users?
  union
  select q.CapabilityPath
  , q.rownum
  , @DomainName + '\' + u.NAME
  from #q q
    inner join CMOBJNAMES n on n.NAME = q.val
    inner join cmobjprops33 u on u.CMID = n.CMID
  where n.NAME like @DirectoryNamespace + '%'

  --  permissions (setPolicy, execute, etc.)
  union
  select q.CapabilityPath
  , q.rownum
  , p.perm
  from #q q
    inner join perms p on q.val like '%' + p.perm + '%'
),
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
, pc.NAME as PrincipalName
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
"

$result = Invoke-Sqlcmd $sqlquery `
			-ServerInstance $dbServer `
			-Database $dbName `
			-MaxCharLength 1000000 `
			-ConnectionTimeout 10 `
			-QueryTimeout 600 `
      -TrustServerCertificate

$l = $result.length
$Capability = @()
$i = 0
$startTime = Get-Date

foreach($row in $result) {
    $r = [PSCustomObject]@{}
    $r | Add-Member -MemberType NoteProperty -Name 'CapabilityPath' -Value $row.CapabilityPath
    $r | Add-Member -MemberType NoteProperty -Name 'permission' -Value $row.permission
    $r | Add-Member -MemberType NoteProperty -Name 'PrincipalName' -Value $row.PrincipalName

    $Capability += $r

    $i++
    $p = [int]($i * 100 / $l)
    
    $elapsed = ((Get-Date) - $startTime).TotalSeconds
    $remainingItems = $l - $i
    $averageItemTime = $elapsed / $i

    Write-Progress "Processing $l capabilities" `
			-Status "$i capabilities processed" `
			-PercentComplete $p `
			-SecondsRemaining ($remainingItems * $averageItemTime)
}


$f =  Join-Path (Join-Path $env:USERPROFILE "Downloads") "Capabilities$CognosEnvironment.csv"

$Capability | Export-Csv -Path $f -NoTypeInformation
Start-Process -FilePath $f
