function get-CAMIDFromADGUID {<#
    .SYNOPSIS
    Find the GUID in Active Directory that matches the CAMID of a user or group in Cognos.
  
    .DESCRIPTION
    
    .PARAMETER CAMID
    The ADGUID in the format
    DirectoryNamespace:type:GUID
	
	.PARAMETER DirectoryNamespace
	Name of namespace configured in Cognos to use Active Directory

    .EXAMPLE
    $CAMID = get-CAMIDFromADGUID "01234567-0123-0123-0123-0123456789ab" "MyNamespace"
    # result = "MyNamespace:g:674523012301230101230123456789ab"
    $uri = "$uriBase/api/v1/users?id=$CAMID"
    $content = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -contentType $contentType -WebSession $Session
    #>
    [cmdletbinding()]
    param (
      [parameter(position=0, Mandatory=$true)]
      [string]$ADGUID,
      [parameter(position=1, Mandatory=$true)]
      [string]$DirectoryNamespace
    )

    $CAMID = "$DirectoryNamespace:g:" + `
              $ADGUID.substring( 6,  2) + `
              $ADGUID.substring( 4,  2) + `
              $ADGUID.substring( 2,  2) + `
              $ADGUID.substring( 0,  2) + `
              $ADGUID.substring(11,  2) + `
              $ADGUID.substring( 9,  2) + `
              $ADGUID.substring(16,  2) + `
              $ADGUID.substring(14,  2) + `
              $ADGUID.substring(19,  4) + `
              $ADGUID.substring(24, 12)

    $CAMID.ToString()
}

function get-ADGUIDFromCAMID {<#
    .SYNOPSIS
    Find the GUID in Active Directory that matches the CAMID of a user or group in Cognos.
  
    .DESCRIPTION
    
    .PARAMETER CAMID
    The CAMID in the format
    DirectoryNamespace:type:GUID

    .EXAMPLE
    Get-ADGroup get-ADGUIDFromCAMID("MyNamespace:g:0123456789abcdef0123456789abcdef")
    Get-ADUser get-ADGUIDFromCAMID("MyNamespace:u:0123456789abcdef0123456789abcdef")
    #>
    [cmdletbinding()]
    param (
      [parameter(position=0, Mandatory=$true)]
      [string]$CAMID
    )
	
	$start = $CAMID.IndexOf(":") + 3
	
    $ADGUID = $CAMID.Substring($start +  6, 2) + `
              $CAMID.Substring($start +  4, 2) + `
              $CAMID.Substring($start +  2, 2) + `
              $CAMID.Substring($start +  0, 2) + `
              '-' + `
              $CAMID.Substring($start + 10, 2) + `
              $CAMID.Substring($start +  8, 2) + `
              '-' + `
              $CAMID.Substring($start + 14, 2) + `
              $CAMID.Substring($start + 12, 2) + `
              '-' + `
              $CAMID.Substring($start + 16, 4) + `
              '-' + `
              $CAMID.Substring($start + 20, 12)
    $ADGUID
}

function get-ADPath {<#
    .SYNOPSIS
    Return a human-readable path to the object in Active Directory.
  
    .DESCRIPTION
    
    .PARAMETER CAMID
    The CAMID in the format
    DirectoryNamespace:type:GUID

    .EXAMPLE
    get-ADPath "CN=Smith\, John,OU=MyUnit,OU=Accounts,DC=company,DC=com" "company.com" 2
    #>
    [cmdletbinding()]
    param (
      [parameter(position=0, Mandatory=$true)]
      [string]$DistinguishedName,
      [parameter(position=1, Mandatory=$true)]
      [string]$BasePath,
      [parameter(position=2, Mandatory=$true)]
      [int32]$BasePathLength
    )
    $a = $DistinguishedName -split ","

    $b = @()
    $b += $BasePath
    for ($i = $a.Length - 1 - $BasePathLength; $i -ge 0; $i--) {
        $b += $a[$i].Substring(3)
    }
    $b -join "\"
}

function start-CognosSession {<#
    .SYNOPSIS
    Start a Cognos REST API session.
  
    .DESCRIPTION
    docs at http://<cognos_analytics_server>:<port>/api/api-docs
	Asks for user name and password
	Exits on empty password

    .PARAMETER serverName
    Cognos server to use.
  
    .EXAMPLE
    start-CognosSession "CognosServer.company.com"
  
    #>
    [CmdletBinding()]
    param( 
        [parameter(position=0, mandatory=$true)]
        [PSCustomObject]$serverName
    )
    # Write-Host "start-CognosSession start"
    $CognosSession = [PSCustomObject]@{}

    $protocol = "https"
    $port = "9300"
    $uriBase = "$protocol`://$serverName`:$port"
    $contentType = "application/json; charset=utf-8"

    $CognosSession | Add-Member -MemberType NoteProperty -Name 'protocol' -Value $protocol
    $CognosSession | Add-Member -MemberType NoteProperty -Name 'serverName' -Value $serverName
    $CognosSession | Add-Member -MemberType NoteProperty -Name 'port' -Value $port
    $CognosSession | Add-Member -MemberType NoteProperty -Name 'uriBase' -Value $uriBase
    $CognosSession | Add-Member -MemberType NoteProperty -Name 'contentType' -Value $contentType
    
    $userNamespace = "DirectoryNamespace"
    $userName = Read-Host "User Name:  "
    $UserPwd = Read-Host "Password" -AsSecureString
    
    $err = $false

    try {
        $userPassword = ConvertFrom-SecureString -SecureString $UserPwd -AsPlainText
    }
    catch {
        Write-Host "Empty password.  Quitting."
        $err = $true
    }

    if (!$err) {
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
        $uri = "$uriBase/api/v1/session"
        
        $a = Invoke-RestMethod -Uri $uri -Method Put -contentType $contentType -SessionVariable "Session" -Body $body
        
        # next line throws error, but retrieves a XSRF-Token cookie
        Write-Host "Ignore the next error.  The next line throws an error, but retrieves a XSRF-Token cookie."
        $a = Invoke-RestMethod -Uri $uri -Method Get -contentType $contentType -WebSession $Session
        $CognosSession | Add-Member -MemberType NoteProperty -Name 'Session' -Value $Session -TypeName 'Microsoft.PowerShell.Commands.WebRequestSession'
        
        $Cookies = $Session.Cookies.GetCookies($uri)
        $XSRFTOKEN = $Cookies["XSRF-TOKEN"].Value
        
        [System.Collections.IDictionary]$headers = @{
            'x-xsrf-token' = $XSRFTOKEN
            'accept' = 'application/json'
            'Cache-Control' = 'no-cache'
        }
        
        $CognosSession | Add-Member -MemberType NoteProperty -Name 'Headers' -Value $headers

        $CognosSession
    }
    else {
        $null
    }
    # Write-Host "start-CognosSession end"
}

function stop-CognosSession {<#
    .SYNOPSIS
    End a Cognos REST API session.
  
    .DESCRIPTION

    .PARAMETER CognosSession
    CognosSession object created by start-CognosSession
  
    .EXAMPLE
    end-CognosSession -CognosSession $CognosSession
  
    #>
    [CmdletBinding()]
    param( 
        [parameter(position=0, mandatory=$true)]
        [PSCustomObject]$CognosSession
    )
    # Write-Host "stop-CognosSession start"
    # log out
    $uri = "$($CognosSession.uriBase)/api/v1/session"
    Invoke-RestMethod -Uri $uri -Method Delete -WebSession $CognosSession.Session
    # Write-Host "stop-CognosSession end"
}

function get-CognosURIfromPath {<#
    .SYNOPSIS
    Get API URI from object path.
  
    .DESCRIPTION
    Result:
        the href of the object
        If the path is not found, nothing is returned.

  
    .PARAMETER path
    Path to the object.  Either format will work.
    Team Content\Reports\Finance\Accounting\Organization Developed Reports\FRACS
    Team content > Reports > Finance > Accounting > Organization Developed Reports > FRACS

    .PARAMETER CognosSession
    CognosSession object created by start-CognosSession
  
    .EXAMPLE
    $sqlcommand="Select * from table"
    invoke-sql localhost $database $sqlcommand
  
    #>
    [CmdletBinding()]
    param( 
        [parameter(position=0, mandatory=$true)]
        [string]$path,
        [parameter(position=1, mandatory=$true)]
        [PSCustomObject]$CognosSession
    )
    # Write-Host "get-CognosURIfromPath start"

    $path = $path -ireplace " > ", "\"
    $path = $path -ireplace "Team Content\\", "Team Folders\"

    $arrPath = $path -split "\\"

    $uriBase = $CognosSession.uriBase
    $headers = $CognosSession.Headers
    $Session = $CognosSession.Session

    $uri = "$uriBase/api/v1/content"
    
    $content = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -contentType "application/json" -WebSession $Session

    for ($i = 0; $i -lt $arrPath.Length; $i++){
        foreach ($c in $content.content) {
            if ($c.defaultName -eq $arrPath[$i]) {
                $hrefItems = ($c.links | Where-Object rel -EQ "items").href
                $hrefSelf = ($c.links | Where-Object rel -EQ "self").href
                if ($i -eq $arrPath.Length - 1) {
                    $done = $true
                }
                break
            }
        }
        $uriItems = "$uriBase$hrefItems"
        $content = Invoke-RestMethod -Uri $uriItems -Method Get -Headers $headers -contentType "application/json" -WebSession $Session
    }
    if ($done) {
        $hrefSelf
    }
    # Write-Host "get-CognosURIfromPath end"
}

function get-CognosObjects {<#
    .SYNOPSIS
    Get all Cognos objects of a certain type within another object, recursively.
  
    .DESCRIPTION
  
    .PARAMETER hrefItems
    items href property of the parent parent object.
  
    .PARAMETER CognosSession
    CognosSession object created by start-CognosSession

    .PARAMETER objectType
    Type of object to capture.  If omitted, all objects are captured.
  
    .EXAMPLE
    get-CognosObjects -hrefItems $href -CognosSession $CognosSession -objectType "report"
  
    #>
    [CmdletBinding()]
    param( 
        [parameter(position=0, mandatory=$true)]
        [string]$hrefItems,
        [parameter(position=1, mandatory=$true)]
        [PSCustomObject]$CognosSession,
        [parameter(position=2, mandatory=$false)]
        [string] $objectType,
        [parameter(position=3, mandatory=$false)]
        [string] $relativePath = "",
        [parameter(position=4, mandatory=$false)]
        [Int32] $depth = 0
    )
    # Write-Host "$("  "*$depth)get-CognosObjects start"

    $uriBase = $CognosSession.uriBase
    $headers = $CognosSession.Headers
    $Session = $CognosSession.Session

    $uri = "$uriBase$hrefItems"
    $content = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -contentType "application/json" -WebSession $Session
    $depth++
    
    $out = @()
    foreach ($c in $content.content) {
        if ($c.type -eq $objectType -or !$objectType) {
            $o = [PSCustomObject]@{}
                $o | Add-Member -MemberType NoteProperty -Name 'relativePath' -Value "$relativePath\$($c.defaultName)"
                $o | Add-Member -MemberType NoteProperty -Name 'object' -Value $c
            $out += $o
        }

        if ( `
                !$objectType `
            -or $c.type -eq "folder" `
            -or $c.type -eq "package" `
            -or !@("shortcut","schedule").Contains($c.Type) `
            -or ( `
                     @("report","reportView").Contains($c.type) `
                -and (@("schedule","reportVersion","history").Contains($objectType)) `
            ) `
        ) {
            $href = ($c.links | Where-Object rel -EQ "self").href
            $out += get-CognosObjects -hrefItems "$href/items" -CognosSession $CognosSession -objectType $objectType -depth $depth -relativePath "$relativePath\$($c.defaultName)"
        }
    }

    if ($depth -gt 20) {
        Write-Host "maximum depth"
        exit
    }

    $out

    # Write-Host "$("  "*($depth-1))get-CognosObjects end"
}

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
      $mymatches = $([regex]::matches($sqlcommand, '\?')) | sort index -desc #we want to start at the end of the string so as we adjust the string count it doesn't break things
      if($parameters.Length -ne $mymatches.length){throw "Parameter counts do not match."} #error check, make sure what the query expects for parameters is the same number of params entered
      $counter = $mymatches.length
      foreach ($match in $mymatches){
          $sqlcommand = $sqlcommand.substring(0, $match.index) + "@a$counter" + $sqlcommand.substring($match.index + 1)
          $counter--
      }
      $counter = 1 #counter should be reset to 1 to fill in the parameters
      $command = new-object system.data.sqlclient.sqlcommand($sqlCommand, $connection)

      foreach ($p in $parameters){
          $command.Parameters.AddWithValue("@a$counter", $p) | out-null
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

function Format-XML {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [string]$xmlcontent
    )
    $xmldoc = New-Object -TypeName System.Xml.XmlDocument
    $xmldoc.LoadXml($xmlcontent)
    $sw = New-Object System.IO.StringWriter
    $writer = New-Object System.Xml.XmlTextwriter($sw)
    $writer.Formatting = [System.XML.Formatting]::Indented
    $xmldoc.WriteContentTo($writer)
    $sw.ToString()
}