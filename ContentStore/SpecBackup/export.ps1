#$d = date
#$dnum = $d.tostring("yyyyMMdd")
$dlog = (date).tostring("yyyy-MM-dd HH:mm:ss.fff ")
$dow = (date).DayofWeek.value__
$thisFolder = (Split-Path $MyInvocation.MyCommand.Source)
$ReportBackupLog = $thisFolder + "\logs\ReportBackupLog.txt"
$repo = "C:\Users\pulsed\repos\CognosReports"

"$dlog  Content Store export beginning" | Out-File -append $ReportBackupLog


$sqlquery = "with src (
  CMID,
  ObjectName,
  ObjectPath,
  ObjectClass,
  Modified) as
(
  select o.CMID
  , n.NAME
  , cast(
      replace(
        replace(
            replace(
                replace(
                    replace(
                        replace(
                            replace(
                                replace(
                                    replace(
                                        n.NAME, char(60), ''    --  <
                                    ), char(62), '' --  >
                                ), char(58), '' --  :
                            ), char(34), '' --  quote
                        ), char(47), '' --  /
                    ), char(92), '' --  \
                ), char(124), ''    --  |
            ), char(63), '' --  ?
        ), char(42), '' --  *
    ) as varchar(max))
  , cast(c.NAME as varchar(max))
  , o.MODIFIED
  from CMOBJECTS o
    inner join CMOBJNAMES n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
  where n.ISDEFAULT = 1
    and isdate(n.NAME) = 0
    and o.CMID = 2
  
  union all
  select o.CMID
  , n.NAME
  , cast(src.ObjectPath + '/' + 
      replace(
        replace(
          replace(
            replace(
              replace(
                replace(
                  replace(
                    replace(
                      replace(
                        n.NAME, char(60), ''
                      ), char(62), ''
                    ), char(58), ''
                  ), char(34), ''
                ), char(47), ''
              ), char(92), ''
            ), char(124), ''
          ), char(63), ''
        ), char(42), ''
      ) as varchar(max))
  , cast(c.NAME as varchar(max))
  , o.MODIFIED
  from CMOBJECTS o
    inner join CMOBJNAMES n on n.CMID = o.CMID
    inner join CMCLASSES c on c.CLASSID = o.CLASSID
    inner join src on src.CMID = o.PCMID
  where n.ISDEFAULT = 1
    and n.CMID != 0
),
obj as (
  select CMID
  , REPLACE(s.ObjectPath,'/','\') + case when s.ObjectClass = 'exploration' then '.json' else '.xml' end as FilePath
  from src s
  where s.ObjectClass in ('report', 'exploration', 'dataSet2')
    and s.ObjectPath like 'Team Content/Reports%'
)

select o.FilePath
, s.SPEC as SPEC
from obj o
  left join CMOBJPROPS7 s on s.CMID = o.CMID"

##	If it's Sunday, don't filter the results.  Get the entire Content Store.
#if ($dow -ne 0) {
#$sqlquery = $sqlquery + "
#  and c.Modified > dateadd(day, -3, getdate())"
#}

$sqlquery = $sqlquery + "
order by 1"



push-location
$result = Invoke-Sqlcmd $sqlquery -ServerInstance "HQOLYMSQL19P" -Database "IBMCOGNOS" -MaxCharLength 1000000
pop-location

$l = $result.length

if ($l -eq 0){
    # No results?  Something went wrong.  Don't change anything.
    $dlog = (date).tostring("yyyy-MM-dd hh:mm:ss.fff ")
    "$dlog  $l reports modified -- something went wrong" | Out-File -append $ReportBackupLog
    #"$dlog  $sqlquery" | Out-File -append $ReportBackupLog
    return 0
}


$dlog = (date).tostring("yyyy-MM-dd hh:mm:ss.fff ")
"$dlog  $l reports modified" | Out-File -append $ReportBackupLog


#	If it's Sunday, delete everything under Team Content\Reports.
#	This is to delete items that are no longer in the Content Store.
#if ($dow -eq 0) {
    $rpts = $repo + "\Team Content\Reports"
	Remove-Item -path $rpts -recurse
#}


#	Write the results to the file system
foreach($row in $result) {
    $filepath = $repo + "\" + $row.FilePath
    $contents = $row.SPEC
	if ($filepath.length -gt 240) {
		"The path is too long:  $filepath" | Out-File -append $ReportBackupLog
		##Try using 8.3 folder/file naming format
		#$folderpath = Split-Path $filepath
		#if (Test-Path $folderpath) {
		#	#The folder exists
		#	$filename = Split-Path $filepath -Leaf
		#	$filepath = Join-Path (New-Object -ComObject Scripting.FileSystemObject).GetFolder($folderpath).shortpath $filename
		#}
	}
	
	#$fldr = Split-Path $filepath
	#if (!(Test-Path $fldr)) {
	#	"Folder not found:  $fldr" | Out-File -append $ReportBackupLog
	#	"Folder not found:  $fldr"
	#}
	
	try {
		if(!(Test-Path $filepath)) {
			try {
				New-Item $filepath -ItemType file -Force -Value $contents
			}
			catch {
				"Error:  " + $row.FilePath | Out-File -append $ReportBackupLog
				"        " + $_.Exception.Message | Out-File -append $ReportBackupLog
				#"        " + $_.Exception.ItemName | Out-File -append $ReportBackupLog
				" " | Out-File -append $ReportBackupLog
			}
		}
		else {
			Set-Content -Path $filepath -Value $contents
		}
	}
	catch {
		"Error:  " + $row.FilePath | Out-File -append $ReportBackupLog
		"        " + $_.Exception.Message | Out-File -append $ReportBackupLog
		#"        " + $_.Exception.ItemName | Out-File -append $ReportBackupLog
		" " | Out-File -append $ReportBackupLog
	}
}

$dlog = (date).tostring("yyyy-MM-dd HH:mm:ss.fff ")
"$dlog  Content Store export complete" | Out-File -append $ReportBackupLog

return 1
