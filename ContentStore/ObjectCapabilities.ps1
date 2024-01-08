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

$DirectoryNamespace = "NamespaceName"

"



Getting data from the database.
This may take a couple minutes.



"

$sqlquery = "
declare @DirectoryNamespace varchar(255) = '$DirectoryNamespace'
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
src (
    CMID
  , ObjectName
  , ObjectPath
  , ObjectClass
) as (
  select o.CMID
  , n.NAME
  , cast(n.NAME as varchar(max))
  , cast(c.NAME as varchar(max))
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
  where o.CMID = 2
  
  union all
  select o.CMID
  , n.NAME
  , cast(src.ObjectPath + '/' + n.NAME as varchar(max))
  , cast(c.NAME as varchar(max))
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
          'folder'
        , 'package'
      )

;
with 
objpolicy as (
  select c.ObjectPath
  --The delimiter between Deny and Grant is 4 nulls.  --  null = CHAR(0)  = CHAR(0x00)
  --Change null null null null to null ZZ null.       --     Z = CHAR(90) = CHAR(0x5A)
  --Then we'll have a delimiter we can use.
  , replace(CONVERT(varchar(max), CONVERT(varbinary(max), p.UCPOLICIES, 1), 2), '00000000', '005A5A00') as pol
  from #cogobj c
    inner join CMOBJPROPS55 p on p.CMID = c.CMID
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
  select ObjectPath
  , ROW_NUMBER() over (partition by ObjectPath order by ObjectPath) as rownum   --  not reliable because string_split doesn't guarantee order until SQL 2022
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
where len(val) > 1
OPTION (MAXRECURSION 0)

;
with
objname as (
  select o.CMID
  , coalesce(n2.name, n.NAME) as 'NAME'
  --into #objname
  from CMOBJECTS o
    left outer join CMOBJNAMES n on n.CMID = o.CMID
                           and n.LOCALEID = 92
    left outer join CMOBJNAMES n2 on n2.CMID = o.CMID
                           and n2.LOCALEID = 118
),
capabilities as (
  select capability
  --into #capabilities
  from (
    values
      ('canAuthorDashboard')
    , ('canEditBursting')
    , ('canEditHTML')
    , ('canEditUserDefinedSQL')
    , ('canEditUserDefinedSQLinMUI')
    , ('canGenerateCSVOutput')
    , ('canGeneratePDFOutput')
    , ('canGenerateXLSOutput')
    , ('canGenerateXMLOutput')
    , ('canUseAdaptiveAnalytics')
    , ('canUseAdaptiveAnalyticsAdministration')
    , ('canUseAnalysisStudio')
    , ('canUseAssistant')
    , ('canUseBursting')
    , ('canUseConditionalSubscriptions')
    , ('canUseEV')
    , ('canUseEventStudio')
    , ('canUseExploration')
    , ('canUseExternalData')
    , ('canUseGlossary')
    , ('canUseHTML')
    , ('canUseLineage')
    , ('canUseMetricsManagerAdministration')
    , ('canUseMetricStudio')
    , ('canUseMetricStudioEditView')
    , ('canUseMyDataSets')
    , ('canUsePlanningAdministration')
    , ('canUsePlanningContributor')
    , ('canUsePowerPlay')
    , ('canUseQueryStudio')
    , ('canUseQueryStudioAdvancedMode')
    , ('canUseReportStudio')
    , ('canUseSpecifications')
    , ('canUseUserDefinedSQL')
    , ('canUseUserDefinedSQLinMUI')
    , ('canUseWebBasedModeling')
    , ('canViewGeneratedQueryText')
  ) v (capability)
),
qc as (
  select q.ObjectPath
  , q.rownum
  , c.capability
  , len(c.capability) as caplen
  , max(len(c.capability)) over (partition by q.ObjectPath, q.val) as maxcaplen
  from #q q
    left outer join capabilities c on q.val like '%' + c.capability + '%'
),
objectCapabilities as (
  select *
  from qc
  where caplen = maxcaplen
), 
objectPrincipals as (
  select *
  from #q
  where val like '::%'
    or  val like @DirectoryNamespace + '%'
),
delim as (
  select *
  from #q
  where val = 'ZZ'
),
objectCapPrin1 as (
  select op.ObjectPath
  , op.rownum
  , op.val
  , oc.rownum as caprow
  , oc.capability
  , max(oc.rownum) over (partition by op.ObjectPath, op.rownum) as maxcaprow
  from objectPrincipals op
    inner join objectCapabilities oc on oc.ObjectPath = op.ObjectPath
                                    and oc.rownum < op.rownum
),
usr as (
  select n.NAME
  , u.NAME as UserName
  from objname n
    inner join cmobjprops33 u on u.CMID = n.CMID
  where n.NAME like @DirectoryNamespace + ':u:%'
),
almostthere as (
  select ocp.ObjectPath
  , ocp.rownum
  , case
      when ocp.val like '::%'
        and CHARINDEX(':', val, 3) > 0
        then n.NAME
      when ocp.val like '::%'
        then SUBSTRING(ocp.val, 3, 4000)
      when ocp.val like @DirectoryNamespace + ':u:%'
        then u.UserName
      else ocp.val
    end as principal
  , ocp.capability
  , ocp.maxcaprow
  from objectCapPrin1 ocp
    left outer join usr u on u.NAME = ocp.val
    left outer join objname n on n.CMID = case when ocp.val like '::%' and CHARINDEX(':', ocp.val, 3) > 3 then cast(SUBSTRING(ocp.val, 3, CHARINDEX(':', ocp.val, 3) - 3) as int) else -1 end
  where ocp.caprow = ocp.maxcaprow
)

select a.ObjectPath
, a.capability
, a.principal
, case count(d.ObjectPath)
    when 2 then 'grant'
    when 1 then 'deny'
  end as permission
, case when left(a.principal, 10) = @DirectoryNamespace + ':g:' then 
  SUBSTRING(a.principal, 17, 2) + 
  SUBSTRING(a.principal, 15, 2) + 
  SUBSTRING(a.principal, 13, 2) + 
  SUBSTRING(a.principal, 11, 2) + 
  '-' + 
  SUBSTRING(a.principal, 21, 2) + 
  SUBSTRING(a.principal, 19, 2) + 
  '-' + 
  SUBSTRING(a.principal, 25, 2) + 
  SUBSTRING(a.principal, 23, 2) + 
  '-' + 
  SUBSTRING(a.principal, 27, 4) +
  '-' + 
  SUBSTRING(a.principal, 31, 12)
  end as ObjectGUID
from almostthere a
  left outer join delim d on d.ObjectPath = a.ObjectPath
                         and d.rownum between a.maxcaprow and a.rownum
group by a.ObjectPath
, a.capability
, a.principal
, case when left(a.principal, 10) = @DirectoryNamespace + ':g:' then 
  SUBSTRING(a.principal, 17, 2) + 
  SUBSTRING(a.principal, 15, 2) + 
  SUBSTRING(a.principal, 13, 2) + 
  SUBSTRING(a.principal, 11, 2) + 
  '-' + 
  SUBSTRING(a.principal, 21, 2) + 
  SUBSTRING(a.principal, 19, 2) + 
  '-' + 
  SUBSTRING(a.principal, 25, 2) + 
  SUBSTRING(a.principal, 23, 2) + 
  '-' + 
  SUBSTRING(a.principal, 27, 4) +
  '-' + 
  SUBSTRING(a.principal, 31, 12)
  end


drop table #q
drop table #cogobj

"

$result = Invoke-Sqlcmd $sqlquery -ServerInstance $dbServer -Database $dbName -MaxCharLength 1000000 -ConnectionTimeout 10 -QueryTimeout 600

$l = $result.length
$ObjectCapability = @()
$i = 0
$startTime = Get-Date

foreach($row in $result) {
    $r = [PSCustomObject]@{}
    $r | Add-Member -MemberType NoteProperty -Name 'ObjectPath' -Value $row.ObjectPath
    $r | Add-Member -MemberType NoteProperty -Name 'capability' -Value $row.capability
    $r | Add-Member -MemberType NoteProperty -Name 'permission' -Value $row.permission
    $r | Add-Member -MemberType NoteProperty -Name 'PrincipalName' -Value $row.principal
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

    $ObjectCapability += $r

    $i++
    $p = [int]($i * 100 / $l)
    
    $elapsed = ((Get-Date) - $startTime).TotalSeconds
    $remainingItems = $l - $i
    $averageItemTime = $elapsed / $i

    Write-Progress "Processing $l capabilities" -Status "$i capabilities processed" -PercentComplete $p -SecondsRemaining ($remainingItems * $averageItemTime)
}


$f =  Join-Path (Join-Path $env:USERPROFILE "Downloads") "ObjectCapabilities$CognosEnvironment.csv"

$ObjectCapability | Export-Csv -Path $f -NoTypeInformation
Start-Process -FilePath $f
