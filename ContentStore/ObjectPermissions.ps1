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
declare @DirectoryNamespace varchar(255) = '$AuthenticationNamespace'
declare @DomainName varchar(255) = '$DomainName'
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
src (
  CMID,
  ObjectName,
  ObjectPath,
  ObjectClass,
  Modified
) as (
  select o.CMID
  , n.NAME
  , cast(n.NAME as varchar(max))
  , cast(c.NAME as varchar(max))
  , o.MODIFIED
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
  where o.CMID = 2
  
  union all
  select o.CMID
  , n.NAME
  , cast(src.ObjectPath + '/' + n.NAME as varchar(max))
  , cast(c.NAME as varchar(max))
  , o.MODIFIED
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    inner join src on src.CMID = o.PCMID
  where n.CMID != 0
)

select CMID
, s.ObjectPath
into #cogobj
from src s
where s.ObjectClass in (
          'agentDefinition'
        , 'dataSet2'
        , 'exploration'
        , 'folder'
        , 'jobDefinition'
        , 'module'
        , 'package'
        , 'report'
        , 'reportView'
        , 'shortcut'
        , 'URL'
      )

      
;
with 
objpolicy as (
  select c.ObjectPath
  , CONVERT(varchar(max), CONVERT(varbinary(max), p.POLICIES, 1), 2) as pol
  from #cogobj c
    inner join CMPOLICIES p on p.CMID = c.CMID
),
cte (
  ObjectPath,
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
  select ObjectPath
  , pol
  , len(pol) as l
  , 3 as pos
  , substring(pol, 1, 2) as curr
  , case
    when convert(int, convert(varbinary, '0x' + substring(pol, 1, 2), 1)) < 32 then char(10)
    else cast(cast(convert(binary(2), '0x' + substring(pol, 1, 2), 1) as char(1)) as varchar(max))
  end as valout
  from objpolicy
  union all
  select ObjectPath
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
  , rank() over (partition by ObjectPath order by pos desc) as rnk
  from cte
),
a as (
  --  We need only the results of the last step.
  select ObjectPath
  , valout
  from cte2
  where rnk = 1
),
q as (
  --select ObjectPath
  --, ROW_NUMBER() over (partition by ObjectPath order by ObjectPath) as rownum   --  not reliable because string_split doesn't guarantee order until SQL 2022
  ----, ROW_NUMBER() over (partition by CapabilityPath order by ordinal) as rownum --  Use with SQL 2022 or later
  --, value as val
  ----, substring(value, 11, 32) as val
  --from a
  --  cross apply string_split(valout, char(10))   --  not reliable because string_split doesn't guarantee order until SQL 2022
  --  --cross apply string_split(valout, char(10), 1) --  Use with SQL 2022 or later

  --  SQL Server 2012 does not have string_split()
  SELECT ObjectPath
  , ROW_NUMBER() over (partition by ObjectPath order by ObjectPath) as rownum
  , Split.a.value('.', 'NVARCHAR(MAX)') val
  FROM (
      SELECT ObjectPath
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
objname as (
  select o.CMID
  , coalesce(n2.name, n.NAME) as 'NAME'
  from CMOBJECTS o
    left outer join CMOBJNAMES n on n.CMID = o.CMID
                           and n.LOCALEID = 92
    left outer join CMOBJNAMES n2 on n2.CMID = o.CMID
                           and n2.LOCALEID = 118
),
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
objPerms as (
  select q.ObjectPath
  , q.rownum
  , n.NAME
  from #q q
    inner join objname n on n.CMID = cast(SUBSTRING(val, 3, CHARINDEX(':', val, 3) - 3) as int)
  where q.val like '::%'
    and CHARINDEX(':', val, 3) > 0

  union
  select q.ObjectPath
  , q.rownum
  , SUBSTRING(val, 3, 400) as 'Name'
  from #q q
  where q.val like '::%'
    and CHARINDEX(':', val, 3) = 0

  union
  select q.ObjectPath
  , q.rownum
  , @DomainName + '\' + u.NAME
  from #q q
    inner join objname n on n.NAME = q.val
    inner join cmobjprops33 u on u.CMID = n.CMID
  where n.NAME like @DirectoryNamespace + ':u:%'

  union
  select q.ObjectPath
  , q.rownum
  , q.val
  from #q q
  where q.val like @DirectoryNamespace + ':g:%'

  union
  select q.ObjectPath
  , q.rownum
  , p.perm
  from #q q
    inner join perms p on q.val like '%' + p.perm + '%'
),
executeStart as (
  select cp.ObjectPath
  , cp.rownum
  , cp.NAME
  from objPerms cp
  where cp.NAME = 'execute'
),
readStart as (
  select cp.ObjectPath
  , cp.rownum
  , cp.NAME
  from objPerms cp
  where cp.NAME = 'read'
),
setPolicyStart as (
  select cp.ObjectPath
  , cp.rownum
  , cp.NAME
  from objPerms cp
  where cp.NAME = 'setPolicy'
),
traverseStart as (
  select cp.ObjectPath
  , cp.rownum
  , cp.NAME
  from objPerms cp
  where cp.NAME = 'traverse'
),
writeStart as (
  select cp.ObjectPath
  , cp.rownum
  , cp.NAME
  from objPerms cp
  where cp.NAME = 'write'
),
permClass as (
  select cp.ObjectPath
  , cp.rownum
  , cp.NAME
  , es.rownum as executeStart
  , rs.rownum as readStart
  , ss.rownum as setPolicyStart
  , ts.rownum as traverseStart
  , ws.rownum as writeStart
  from objPerms cp
    left outer join executeStart es on es.ObjectPath = cp.ObjectPath
    left outer join readStart rs on rs.ObjectPath = cp.ObjectPath
    left outer join setPolicyStart ss on ss.ObjectPath = cp.ObjectPath
    left outer join traverseStart ts on ts.ObjectPath = cp.ObjectPath
    left outer join writeStart ws on ws.ObjectPath = cp.ObjectPath
)

select c.ObjectPath
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
, case when left(pc.NAME, 10) = @AuthenticationNamespace + ':g:' then 
  SUBSTRING(pc.name, 17, 2) + 
  SUBSTRING(pc.name, 15, 2) + 
  SUBSTRING(pc.name, 13, 2) + 
  SUBSTRING(pc.name, 11, 2) + 
  '-' + 
  SUBSTRING(pc.name, 21, 2) + 
  SUBSTRING(pc.name, 19, 2) + 
  '-' + 
  SUBSTRING(pc.name, 25, 2) + 
  SUBSTRING(pc.name, 23, 2) + 
  '-' + 
  SUBSTRING(pc.name, 27, 4) +
  '-' + 
  SUBSTRING(pc.name, 31, 12)
  end as ObjectGUID
from #cogobj c
  left outer join permClass pc on pc.ObjectPath = c.ObjectPath
                              and pc.NAME not in (
                                                   select perm
                                                   from perms
                                                 )
order by 1, 2, 3


drop table #q
drop table #cogobj
"

$result = Invoke-Sqlcmd $sqlquery `
			-ServerInstance "$dbServer" `
			-Database "$dbName" `
			-MaxCharLength 1000000 `
			-ConnectionTimeout 120 `
			-QueryTimeout 600

$l = $result.length
$ObjectPermission = @()
$i = 0
$startTime = Get-Date

foreach($row in $result) {
    $r = [PSCustomObject]@{}
    $r | Add-Member -MemberType NoteProperty -Name 'ObjectPath' -Value $row.ObjectPath
    $r | Add-Member -MemberType NoteProperty -Name 'permission' -Value $row.permission
    $r | Add-Member -MemberType NoteProperty -Name 'PrincipalName' -Value $row.PrincipalName
    $o = $row.ObjectGUID
    if ($o.length -gt 1) {
        $filter = "ObjectGUID -eq `"$o`""
        $g = Get-ADGroup -Filter $filter
        if ($g) {
            $r.PrincipalName = $g.Name
        }
        else {
            # group not found in MSAD
        }
    }

    $ObjectPermission += $r

    $i++
    $p = [int]($i * 100 / $l)
    
    $elapsed = ((Get-Date) - $startTime).TotalSeconds
    $remainingItems = $l - $i
    $averageItemTime = $elapsed / $i

    Write-Progress "Processing $l permissions" `
			-Status "$i permissions processed" `
			-PercentComplete $p `
			-SecondsRemaining ($remainingItems * $averageItemTime)
}


$f =  Join-Path (Join-Path $env:USERPROFILE "Downloads") "ObjectPermissions$CognosEnvironment.csv"

$ObjectPermission | Export-Csv -Path $f -NoTypeInformation
Start-Process -FilePath $f
