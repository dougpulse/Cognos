<#
.SYNOPSIS
Get specs (.xml and .json files) for packages and data modules.

.DESCRIPTION
Works for a Cognos Analytics content store on SQL Server

.PARAMETER CSServerName
Name of the database server where the Content Store lives.

.PARAMETER CSDatabaseName
Name of the Content Store database.  Typically IBMCognos.

.PARAMETER DirectoryNamespace
Name of the external directory namespace.  This is used for the paths of 
packages and data modules that are in My Content.

.EXAMPLE
.\ModulesAndPackages.ps1 "DatabaseServer" "IBMCognos" "DirectoryNamespace"
#>
[CmdletBinding()]
param( 
    [parameter(position=0, mandatory=$true)]
    [string]$CSServerName,
    [parameter(position=1, mandatory=$true)]
    [string]$CSDatabaseName,
    [parameter(position=2, mandatory=$true)]
    [string]$DirectoryNamespace
)

# $functions = Join-Path $env:USERPROFILE "repos\CognosAdmin\RESTAPI\fn.ps1"
# . $functions

$sqlquery = "
declare @DirectoryNamespace varchar(255) = '$DirectoryNamespace'
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
  where c.name in ('module', 'model')
  --  and n.NAME in ('! BigBudgetModule', 'May New data module')
  --where c.name = 'model'
--    and n.NAME = 'MS2 Validation'

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
    or   p.ObjectPath like @DirectoryNamespace + ':u:%')
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
      when 'module' then CAST('' AS XML).value('xs:base64Binary(sql:column(`"module.CBASEDEF`"))', 'VARBINARY(MAX)')
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

--into #outputs

from zip

order by ObjectPath"

Write-Host "



starting
"

$result = Invoke-Sqlcmd -Query $sqlquery `
                        -ServerInstance $CSServerName `
                        -Database $CSDatabaseName `
                        -MaxCharLength 25000000 `
                        -ConnectionTimeout 10 `
                        -QueryTimeout 600 `
                        -TrustServerCertificate

                        Write-Host "got data... continuing"

$zipPath = Join-Path $env:USERPROFILE "temp.zip"
$zipFolderPath = Join-Path $env:USERPROFILE "temp"
$basePath = Join-Path $env:USERPROFILE "CognosModules"

$basePath | Get-ChildItem -Recurse | Remove-Item -Recurse

# $modules = @()
$l = $result.length
$i = 0
$startTime = Get-Date

$modulesToUnzip = 0
$modulesUnzipped = 0

# Write-Host "starting loop

# "

foreach ($row in $result) {
  # Write-Host $row.ObjectName

  # $r = [PSCustomObject]@{}
  if ($row.ObjectPath -like "Team Content/*") {
    $objPath = $row.ObjectPath
    # $r | Add-Member -MemberType NoteProperty -Name 'ObjectPath'          -Value $row.ObjectPath
  }
  else {
    $objPath = Join-Path "My Content" $row.ObjectPath
    # $r | Add-Member -MemberType NoteProperty -Name 'ObjectPath'          -Value $objPath
  }
  # $r | Add-Member -MemberType NoteProperty -Name 'ObjectType'          -Value $row.ObjectType
  # $r | Add-Member -MemberType NoteProperty -Name 'FileType'            -Value $row.FILE_TYPE
  # $r | Add-Member -MemberType NoteProperty -Name 'CBASEDEF_COMPRESSED' -Value $row.CBASEDEF_COMPRESSED

  if ($row.CBASEDEF_STRING -eq "TODO:  UNZIP PKZIP BINARY") {
    # Write-Host "  unzipping"
    $modulesToUnzip++
    $binary = $row.CBASEDEF_COMPRESSED
    $binary | Set-Content -Path $zipPath -AsByteStream
    try {
      # Write-Host "    expanding"
      Expand-Archive -Path $zipPath -DestinationPath $zipFolderPath
      # Write-Host "    expanded"
      $files = Get-ChildItem -Path $zipFolderPath
      $baseDef = Get-Content $files.FullName
      Remove-Item -Path $zipFolderPath -Recurse
      $modulesUnzipped++
    }
    catch {
      # Write-Host "    failed to expand:  $($row.ObjectPath)"
      $baseDef = ""
    }
    
    # $r | Add-Member -MemberType NoteProperty -Name 'CBASEDEF_STRING'     -Value $baseDef
  }
  else {
    $baseDef = $row.CBASEDEF_STRING
    # $r | Add-Member -MemberType NoteProperty -Name 'CBASEDEF_STRING'     -Value $row.CBASEDEF_STRING
  }

  if ($row.ObjectType -eq "module" -and $row.FILE_TYPE -eq "GZIP") {
    # $r | Add-Member -MemberType NoteProperty -Name 'FileExt'             -Value ".json"
    $fileExt = ".json"
    # Depth defaults
    # ConvertFrom-Json = 1024
    # ConvertTo-Json   = 2  (max = 100)
    $baseDef = $baseDef | ConvertFrom-Json | ConvertTo-Json -Depth 100
  }
  else {
    # $r | Add-Member -MemberType NoteProperty -Name 'FileExt'             -Value ".xml"
    $fileExt = ".xml"
    $baseDef =$baseDef | Format-XML
  }

  # $modules += $r
  
  $relPath = "$($objPath)$($fileExt)"
  $filePath = Join-Path $basePath $relPath
  $folderPath = Split-Path $filePath
  # Write-Host "  writing file"
  if (!(Test-Path $folderPath)) {
    # Write-Host "    $folderPath does not exist"
    New-Item -ItemType Directory -Path $folderPath -Force
  }
  $baseDef | Out-File -FilePath $filePath

  $i++
  $p = [int]($i * 100 / $l)
  
  $elapsed = ((Get-Date) - $startTime).TotalSeconds
  $remainingItems = $l - $i
  $averageItemTime = $elapsed / $i

  Write-Progress "Processing $l modules" -Status "$i modules processed" -PercentComplete $p -SecondsRemaining ($remainingItems * $averageItemTime)
}

Write-Host "Total number of modules:        $l"
Write-Host "Modules to unzip:               $modulesToUnzip"
Write-Host "Modules successfully unzipped:  $modulesUnzipped"
