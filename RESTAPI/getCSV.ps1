#$functions = Join-Path $env:USERPROFILE "repos\Cognos\RESTAPI\fn.ps1"
Set-Location $thisFolder
$functions = ".\fn.ps1"
. $functions


$serverName = Read-Host "Cognos server name"

$CognosSession = start-CognosSession -serverName $serverName

if ($CognosSession) {
  $uriBase = $CognosSession.uriBase
#   $protocol = $CognosSession.protocol
#   $serverName = $CognosSession.serverName
#   $port = $CognosSession.port
  $Session = $CognosSession.Session
#   $headers = $CognosSession.Headers
#   $contentType = $CognosSession.contentType

  #=====================================================================================================================
  #   DDDDD      OOO          SSS   TTTTTTT U    U FFFFFF FFFFFF
  #   D     D  O     O       S         T    U    U F      F
  #   D     D  O     O        SSS      T    U    U FFFF   FFFF
  #   D     D  O     O           S     T    U    U F      F
  #   DDDDD      OOO          SSS      T     UUUU  F      F
  #=====================================================================================================================


  "
    
    
    
    
    
  "

  $path = Read-Host "Path to object"

  $href = get-CognosURIfromPath -path $path -CognosSession $CognosSession

  if ($href) {
      $co = get-CognosObjects -hrefItems "$href/items" -CognosSession $CognosSession -objectType "output"

      $b = @()
      foreach ($o in $co) {
          $b += $o.object.id
      }
      $storeID = "'$($b -join "','")'"

    #  So we found the output.  How do we get the CSV content?


    #   There doesn't appear to be a way to do this using the REST API.
    #   We'll run a query against the Content Store database to get the CSV results.

    $sql = "
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
    r as (
      select convert(varchar(max), decompress(CONVERT(varbinary(max), d.DATAPROP, 1)), 2) as doc
      , 5 as pos
      from         CMOBJECTS o
        inner join CMSTOREIDS s on s.CMID = o.CMID
        inner join objname n on n.CMID = o.CMID
        inner join CMCLASSES c on c.CLASSID = o.CLASSID
        inner join CMDATA d on d.CMID = o.CMID

      where d.CONTENTTYPE like 'application/csv%'
        and s.STOREID in ($storeID)
    ),
    cte (
        doc
      , l
      , pos
      , curr
      , valout
    ) as (
      --  Loop through the value 2 characters (1 hex value) at a time.
      --  Convert each value to ASCII.
      --  We'll replace anything small (non-printing characters) with LF to keep it simple.
      --    That may not be the best solution.
      select 
        doc
      , len(doc) as l
      , pos + 2 as pos
      , substring(doc, pos, 2) as curr
      , case
          when convert(int, convert(binary(2), '0x' + substring(doc, pos, 2), 1)) = 9 then ','
          when convert(int, convert(binary(2), '0x' + substring(doc, pos, 2), 1)) = 10 then char(10)
          when convert(int, convert(binary(2), '0x' + substring(doc, pos, 2), 1)) < 32 then ''
        else cast(cast(     convert(binary(2), '0x' + substring(doc, pos, 2), 1) as char(1)) as varchar(max))
      end as valout
      from r
      union all
      select 
        doc
      , l
      , pos + 2 as pos
      , substring(doc, pos, 2) as curr
      , valout + 
        case
          when convert(int, convert(binary(2), '0x' + substring(doc, pos, 2), 1)) = 9 then ','
          when convert(int, convert(binary(2), '0x' + substring(doc, pos, 2), 1)) = 10 then char(10)
          when convert(int, convert(binary(2), '0x' + substring(doc, pos, 2), 1)) < 32 then ''
          else cast(cast(   convert(binary(2), '0x' + substring(doc, pos, 2), 1) as char(1)) as varchar(max))
        end as valout
      from cte
      where pos < l
    ), 
    cte2 as (
      -- Rank to identify the final value.
      select *
      , rank() over (partition by doc order by pos desc) as rnk
      from cte
    )

    select cast(replace(valout, char(9), ',') as varchar(max)) as valout
    from cte2
    where rnk = 1
    OPTION (MAXRECURSION 0)
    "

    $DatabaseServer = Read-Host "Content Store database server name"
    $ContentStoreDB = Read-Host "Content Store database name"

    $dataset = Invoke-Sqlcmd $sql -ServerInstance $DatabaseServer -Database $ContentStoreDB -MaxCharLength 1000000 -ConnectionTimeout 30 -QueryTimeout 600 -TrustServerCertificate
    $l = $dataset.length
    #should be one row
    "$l rows found"

    $csv = @()
    foreach($row in $dataset) {
      $csv += $row.valout
    }
    
    $csv
  }
  else {
      "path not found"
  }
  
  
  #=====================================================================================================================
  #   DDDDD      OOO   N    N EEEEEE      DDDDD      OOO   IIIII N    N  GGGG        SSS   TTTTTTT U    U FFFFFF FFFFFF
  #   D     D  O     O N N  N E           D     D  O     O   I   N N  N G           S         T    U    U F      F
  #   D     D  O     O N  N N EEEE        D     D  O     O   I   N  N N G  GGG       SSS      T    U    U FFFF   FFFF
  #   D     D  O     O N   NN E           D     D  O     O   I   N   NN G    G          S     T    U    U F      F
  #   DDDDD      OOO   N    N EEEEEE      DDDDD      OOO   IIIII N    N  GGGG        SSS      T     UUUU  F      F
  #=====================================================================================================================
  
  # log out
  $uri = "$uriBase/api/v1/session"
  $done = Invoke-RestMethod -Uri $uri -Method Delete -WebSession $Session
}
$done
