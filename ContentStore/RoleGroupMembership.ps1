$AuthenticationNamespace = "NamespaceName"
$SQLServer = "SQLServerName"
"




Getting data from the database.
This may take a couple minutes.



"

$sqlquery = "
declare @DirectoryNamespace varchar(255) = '$AuthenticationNamespace'
;
with
objname as (
  select o.CMID
  , coalesce(n2.name, n.NAME) as 'NAME'
  from CMOBJECTS o
    left outer join CMOBJNAMES n on n.CMID = o.CMID
                           and n.LOCALEID = 92    --  en
    left outer join CMOBJNAMES n2 on n2.CMID = o.CMID
                           and n2.LOCALEID = 118  --  en-us
),
rolegroup (
    CMID
  , ObjectName
  , ObjectPath
  , ObjectClass
  , done
) as (
  select o.CMID
  , n.NAME
  , cast(n.NAME as varchar(max))
  , cast(c.NAME as varchar(max))
  , 1
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
  where n.NAME = 'Cognos'
    and c.NAME = 'namespace'
    
  union all
  select o.CMID
  , n.NAME
  , cast(rg.ObjectPath + '/' + n.NAME as varchar(max))
  , cast(c.NAME as varchar(max))
  , rg.done + 1
  from CMOBJECTS o
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    inner join rolegroup rg on rg.CMID = o.PCMID
  where n.CMID != 0
    and c.NAME in ('namespaceFolder', 'group', 'role')
),
members as (
  select rg.CMID
  , rg.ObjectPath
  , rg.ObjectClass
  , coalesce(u.NAME, n.NAME) as MemberName
  , c.NAME as MemberClass
  , o.CMID as MemberCMID
  , case when c.NAME = 'group' and n.NAME like @DirectoryNamespace + ':g:%' then 
      SUBSTRING(n.name, 17, 2) + 
      SUBSTRING(n.name, 15, 2) + 
      SUBSTRING(n.name, 13, 2) + 
      SUBSTRING(n.name, 11, 2) + 
      '-' + 
      SUBSTRING(n.name, 21, 2) + 
      SUBSTRING(n.name, 19, 2) + 
      '-' + 
      SUBSTRING(n.name, 25, 2) + 
      SUBSTRING(n.name, 23, 2) + 
      '-' + 
      SUBSTRING(n.name, 27, 4) +
      '-' + 
      SUBSTRING(n.name, 31, 12)
    end as MemberObjectGUID
  from rolegroup rg
    inner join CMREFORD1 r on r.CMID = rg.CMID
    inner join CMOBJECTS o on o.CMID = r.REFCMID
    inner join objname n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    left outer join CMOBJPROPS33 u on u.CMID = o.CMID
)

select *
from members
order by ObjectPath
"

$result = Invoke-Sqlcmd $sqlquery -ServerInstance "$SQLServer" -Database "IBMCOGNOS" -MaxCharLength 1000000 -ConnectionTimeout 120 -QueryTimeout 600

$l = $result.length
$i = 0
$startTime = Get-Date
$out = @()

foreach($row in $result) {
    $o = $row.MemberObjectGUID
    if ($o.length -gt 1) {
        $filter = "ObjectGUID -eq `"$o`""
        $g = Get-ADGroup -Filter $filter 
        if ($g) {
            $m = Get-ADGroupMember $g -Recursive
            foreach ($member in $m) {
                $r = [PSCustomObject]@{}
                $r | Add-Member -MemberType NoteProperty -Name 'ObjectPath' -Value $row.ObjectPath
                $r | Add-Member -MemberType NoteProperty -Name 'ObjectClass' -Value $row.ObjectClass
                $r | Add-Member -MemberType NoteProperty -Name 'MemberClass' -Value 'account'
                $r | Add-Member -MemberType NoteProperty -Name 'MemberName' -Value $member.Name
                $out += $r
            }
        }
        else {
            # group not found in MSAD
            $r = [PSCustomObject]@{}
            $r | Add-Member -MemberType NoteProperty -Name 'ObjectPath' -Value $row.ObjectPath
            $r | Add-Member -MemberType NoteProperty -Name 'ObjectClass' -Value $row.ObjectClass
            $r | Add-Member -MemberType NoteProperty -Name 'MemberClass' -Value $row.MemberClass
            $r | Add-Member -MemberType NoteProperty -Name 'MemberName' -Value $row.MemberName
            $out += $r
        }
    }
    else {
        # no ObjectGUID provided
        $r = [PSCustomObject]@{}
        $r | Add-Member -MemberType NoteProperty -Name 'ObjectPath' -Value $row.ObjectPath
        $r | Add-Member -MemberType NoteProperty -Name 'ObjectClass' -Value $row.ObjectClass
        $r | Add-Member -MemberType NoteProperty -Name 'MemberClass' -Value $row.MemberClass
        $r | Add-Member -MemberType NoteProperty -Name 'MemberName' -Value $row.MemberName
        $out += $r
    }

    $i++
    $p = [int]($i * 100 / $l)
    # $elapsed = ((Get-Date) - $startTime).TotalSeconds
    # $remainingItems = $l - $i
    # $averageItemTime = $elapsed / $i
    Write-Progress "Evaluating $l roles and groups" -Status "$i evaluated" -PercentComplete $p # -SecondsRemaining ($remainingItems * $averageItemTime)
}
"


"
#$out

$f =  Join-Path (Join-Path $env:USERPROFILE "Downloads") "RoleGroupMembership.csv"
$out | Export-Csv -Path $f -NoTypeInformation
Start-Process -FilePath $f
