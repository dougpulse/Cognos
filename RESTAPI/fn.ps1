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