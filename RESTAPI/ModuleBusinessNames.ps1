$ExistingVariables = Get-Variable | Select-Object -ExpandProperty Name


function Invoke-Sql{<#
  .SYNOPSIS
  Runs a SQL query

  .DESCRIPTION
  Connection variables and a SQL string, optionally an array of parameters are passed to the function, which then connects to the designated SQL instance and performs the query.
  Because a dynamically generated SQL statement is NOT secure and vulnerable to SQL injection attacks, unless otherwise handled, use the parameterized option for passing variables.

  .PARAMETER Datasource
  A string of the datasource, AKA the server name. Required. Defaults to the first position

  .PARAMETER Database
  A string of the database name. Required. Defaults to the second position

  .PARAMETER SQLCommand
  A string of the query to run. Required. Defaults to the third position. When used as a parameterized query the paramters should be replaced with question marks.

  .PARAMETER Parameters
  An array of variables that the function will parameterize for the SQL server. Optional. Defaults to fourth position

  .EXAMPLE
  $sqlcommand="Select * from table"
  invoke-sql localhost $database $sqlcommand

  .EXAMPLE
  $sqlcommand= "Select * from table where field=? or field =?"
  $params=@("value1","value2")
  invoke-sql localhost $database $sqlcommand $params

  #>
  [CmdletBinding()]
  param( 
      [parameter(position=0, mandatory=$true)]
      [string]$datasource,
      [parameter(position=1, mandatory=$true)]
      [string]$database,
      [parameter(position=2, mandatory=$true)]
      [string] $sqlCommand,
      [parameter(position=3)]
      [array]$parameters
  )
  $connectionString = "Data Source=$dataSource; " +
              "Integrated Security=SSPI; " +
              "Initial Catalog=$database"

  $connection = new-object system.data.SqlClient.SQLConnection($connectionString)

  if($null -eq $parameters){
      $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
   }
   else {
      #the user has sent a parameterized query. Search the query for the character ? and replace with a @a# where # corresponds to which ? in the query it is.
      $mymatches=$([regex]::matches($sqlcommand,'\?'))|sort index -desc #we want to start at the end of the string so as we adjust the string count it doesn't break things
      if($parameters.Length -ne $mymatches.length){throw "Parameter counts do not match."} #error check, make sure what the query expects for parameters is the same number of params entered
      $counter=$mymatches.length
      foreach ($match in $mymatches){
          $sqlcommand=$sqlcommand.substring(0,$match.index) +"@a$counter"+ $sqlcommand.substring($match.index+1)
          $counter--
      }
      $counter=1 #counter should be reset to 1 to fill in the parameters
      $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)

      foreach ($p in $parameters){
          $command.Parameters.AddWithValue("@a$counter",$p)|out-null
          $counter++
      }
  }
  $connection.Open()
  $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
  $dataset = New-Object System.Data.DataSet
  $adapter.Fill($dataSet) | Out-Null

  $connection.Close()
  $dataSet.tables
}

function Get-TableMetadata {
  [cmdletbinding()]
  param (
    [parameter(Mandatory=$true)]
    [string]$TableName,
    [parameter(Mandatory=$true)]
    [object]$TablesMetadata
  )
  $matchCount = 0
  $r = [PSCustomObject]@{}
  foreach ($tm in $TablesMetadata) {
    if ($tm.TableName -eq $TableName) {
      $matchCount++
      $r = $r | Select-Object -Property * -ExcludeProperty *
      $r | Add-Member -MemberType NoteProperty -Name 'Label' -Value $tm.Label
      $r | Add-Member -MemberType NoteProperty -Name 'Description' -Value $tm.Description
    }
  }

  if ($matchCount -gt 1) {
    "Warning:  More than 1 record matches $Tablename.  Returning last item found."
  }

  $r
}

function Get-ColumnMetadata {
  [cmdletbinding()]
  param (
    [parameter(Mandatory=$true)]
    [string]$TableName,
    [parameter(Mandatory=$true)]
    [string]$ColumnName,
    [parameter(Mandatory=$true)]
    [object]$ColumnsMetadata
  )
  $matchCount = 0
  $r = [PSCustomObject]@{}
  foreach ($cm in $ColumnsMetadata) {
    if ($cm.TableName -eq $TableName -and $cm.ColumnName -eq $ColumnName) {
      $matchCount++
      $r = $r | Select-Object -Property * -ExcludeProperty *
      $r | Add-Member -MemberType NoteProperty -Name 'Label' -Value $cm.Label
      $r | Add-Member -MemberType NoteProperty -Name 'Description' -Value $cm.Description
    }
  }

  if ($matchCount -gt 1) {
    "Warning:  More than 1 record matches $Tablename.$Columnname.  Returning last item found."
  }

  $r
}



"





--------------------------------------
starting
--------------------------------------
"

$protocol = "https"
$serverName = "yourServerName"
$port = "9300"
$uriBase = "$protocol`://$serverName`:$port"
$contentType = "application/json; charset=utf-8"

$userNamespace = "yourDirectoryNamespace"
$userName = Read-Host "User Name"
$userPassword = ""
$UserPwd = Read-Host "Password" -AsSecureString
$userPassword = ConvertFrom-SecureString -SecureString $UserPwd -AsPlainText
if (!$userPassword) {
  break
}

$modulePath = Read-Host "Module Path"
$database = Read-Host "Database Name"
$dbEnvironment = Read-Host "Database Environment"

$sqlParams = @()
$sqlParams += $database
$sqlParams += $dbEnvironment

"
getting metadata..."
# ---------------------------------------------------------
#    Data Library

$sqlTable = "/*  TABLE  */
select 
  EnvironmentName
, HardwareSystemName
, [DatabaseName]
, TableName
, coalesce(BusinessName, '') as BusinessName
, coalesce([Description], '') as [Description]

from [your database objects]

where DatabaseMetadata.DatabaseName = ?
  and Environment.EnvironmentName = ?

order by 1, 2, 3, 4
;
"
$DataCatalogDatabase = "yourDataCatalogDatabaseName"
$DataCatalogServer = "yourDataCatalogServerName"
$rsltTable = Invoke-Sql -datasource $DataCatalogServer -database $DataCatalogDatabase -sqlCommand $sqlTable -parameters $sqlParams
$l = $rsltTable.length

$tables = @()
foreach($row in $rsltTable) {
  $r = [PSCustomObject]@{}
  $r | Add-Member -MemberType NoteProperty -Name 'TableName' -Value $row.TableName
  $r | Add-Member -MemberType NoteProperty -Name 'Label' -Value $row.BusinessName
  $r | Add-Member -MemberType NoteProperty -Name 'Description' -Value $row.Description
  $tables += $r
}
"
got $l tables"
if ($l -eq 0) {
  "    Verify database name and environment."
}

$sqlColumn = "/*  COLUMN  */
select 
  EnvironmentName
, HardwareSystemName as ServerName
, [DatabaseName]
, TableName
, [ColumnName]
, coalesce(BusinessName, '') as BusinessName
, coalesce([Description], '') as [Description]

from [your database objects]

where DatabaseMetadata.DatabaseName = ?
  and Environment.EnvironmentName = ?

order by 1, 2, 3, 4, 5
;
"
$rsltTable = Invoke-Sql -datasource $DataCatalogServer -database $DataCatalogDatabase -sqlCommand $sqlColumn -parameters $sqlParams
$l = $rsltColumn.length

$columns = @()
foreach($row in $rsltColumn) {
  $r = [PSCustomObject]@{}
  $r | Add-Member -MemberType NoteProperty -Name 'TableName' -Value $row.TableName
  $r | Add-Member -MemberType NoteProperty -Name 'ColumnName' -Value $row.ColumnName
  $r | Add-Member -MemberType NoteProperty -Name 'Label' -Value $row.BusinessName
  $r | Add-Member -MemberType NoteProperty -Name 'Description' -Value $row.Description
  $columns += $r
}
"
got $l columns"
if ($l -eq 0) {
  "    Verify database name and environment."
}



"
getting data module..."
# ---------------------------------------------------------
#    Cognos REST API
#  docs at
#  http://<cognos_analytics_server>:<port>/api/api-docs


$bdy = [PSCustomObject]@{}
$paramarray = @()
$param = [PSCustomObject]@{}
    $param | Add-Member -MemberType NoteProperty -Name 'name'  -Value "CAMNamespace"
    $param | Add-Member -MemberType NoteProperty -Name 'value' -Value $userNamespace
    $paramarray += $param
$param = [PSCustomObject]@{}
    $param | Add-Member -MemberType NoteProperty -Name 'name'  -Value "CAMUsername"
    $param | Add-Member -MemberType NoteProperty -Name 'value' -Value $userName
    $paramarray += $param
$param = [PSCustomObject]@{}
    $param | Add-Member -MemberType NoteProperty -Name 'name'  -Value "CAMPassword"
    $param | Add-Member -MemberType NoteProperty -Name 'value' -Value $userPassword
    $paramarray += $param
$bdy | Add-Member -MemberType NoteProperty -Name 'parameters' -Value $paramarray

$body = ConvertTo-Json $bdy

#"
#/* log in */"
$uri = "$uriBase/api/v1/session"
$a = Invoke-RestMethod -Uri $uri -Method Put -contentType $contentType -SessionVariable "Session" -Body $body

# "
# #/* get session - fails but gets xsrf token */"
# next line throws error, but retrieves a XSRF-Token cookie
$a = Invoke-RestMethod -Uri $uri -Method Get -contentType $contentType -WebSession $Session -ErrorAction Ignore


$Cookies = $Session.Cookies.GetCookies($uri)
$XSRFTOKEN = $Cookies["XSRF-TOKEN"].Value

$headers = @{
    'x-xsrf-token' = $XSRFTOKEN
    'accept' = $contentType
    'Cache-Control' = 'no-cache'
}

#"
#/* get modules */"
$uri = "$uriBase/api/v1/modules"
$modules = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -contentType $contentType -WebSession $Session
$moduleId = ""

foreach ($m in $modules.modules) {
    $path = Join-Path $($m.ancestors.name -join "\") $($m.name)
    $mpath = ($path).Replace("\", "/")
    if ($mpath -eq $modulePath) {
        $moduleId = $m.id
    }
}

if (!$moduleId) {
  "

Module not found
  Verify module path and name."
}
else {
  #"
  #/* get the requested module */"
  $uri = "$uriBase/api/v1/modules/$moduleId"
  $module = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -contentType $contentType -WebSession $Session

  #"
  #/* get the querySubject */"
  $qs = $module.querySubject
  
  foreach ($q in $qs) {
      #"===---  " + $q.identifier + "  ---==="
      $tm = ""
      $tm = Get-TableMetadata -TableName $q.identifier -TablesMetadata $tables
      if ($tm.label) {
        "label = $($tm.label)"
        $q.label = $tm.label
      }
      if ($tm.Description) {
        if (!$q.description) {
          $q | Add-Member -MemberType NoteProperty -Name 'description' -Value $tm.Description
        }
        else {
          $q.Description = $tm.Description
        }
      }
      foreach ($qi in $q.item) {
          $cm = ""
          $cm = Get-ColumnMetadata -TableName $q.identifier -ColumnName $qi.queryItem.identifier -ColumnsMetadata $columns
          if ($cm.label) {
            $qi.queryItem.label = $cm.label
          }
          if ($cm.Description) {
            if (!$qi.queryItem.description) {
              $qi.queryItem | Add-Member -MemberType NoteProperty -Name 'description' -Value $cm.Description
            }
            else {
              $qi.queryItem.description = $cm.Description
            }
          }
      }  }
  $newModule = $module | ConvertTo-Json -Depth 8
  
  #"
  #/* overwrite the requested module */"
  $module = Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -contentType $contentType -WebSession $Session -Body $newModule
}



# log out
$uri = "$uriBase/api/v1/session"
$done = Invoke-RestMethod -Uri $uri -Method Delete -WebSession $Session
$done



$NewVariables = Get-Variable | Select-Object -ExpandProperty Name | Where-Object {$ExistingVariables -notcontains $_ -and $_ -ne "ExistingVariables"}
if ($NewVariables) {
  #Write-Host "Removing the following variables:`n`n$NewVariables"
  Remove-Variable $NewVariables
}
else {
  #Write-Host "No new variables to remove!"
}
