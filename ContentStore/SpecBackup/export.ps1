#
#	extract report specifications from the Cognos Content Store database
#	save the report specs to the file system
#


#$d = date
#$dnum = $d.tostring("yyyyMMdd")
$dlog = (date).tostring("yyyy-MM-dd HH:mm:ss.fff ")
$dow = (date).DayofWeek.value__


"$dlog  Content Store export beginning" | Out-File -append "E:\logs\ReportBackupLog.txt"


$sqlquery = "with cte2(CMID,
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
											n.NAME, char(60), ''	--	<
										), char(62), ''	--	>
									), char(58), ''	--	:
								), char(34), ''	--	quote
							), char(47), ''	--	/
						), char(92), ''	--	\
					), char(124), ''	--	|
				), char(63), ''	--	?
			), char(42), ''	--	*
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
       , cast(cte2.ObjectPath + '/' + 
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
         inner join cte2 cte2 on cte2.CMID = o.PCMID
       where n.ISDEFAULT = 1
         and n.CMID != 0
)

select REPLACE(c.ObjectPath,'/','\') + case when c.ObjectClass = 'exploration' then '.json' else '.xml' end as FilePath
, s.SPEC as SPEC
from cte2 c
  left join CMOBJPROPS7 s on s.CMID = c.CMID
where c.ObjectClass in ('report', 'exploration', 'dataSet2')
  and c.ObjectPath like 'Team Content/Reports%'"

#	If it's Sunday, don't filter the results.  Get the entire Content Store.
if ($dow -ne 0) {
$sqlquery = $sqlquery + "
  and c.Modified > dateadd(day, -3, getdate())"
}

$sqlquery = $sqlquery + "
order by 1"


push-location
try {
	$result = Invoke-Sqlcmd $sqlquery -ServerInstance "<servername>" -Database "IBMCOGNOS" -MaxCharLength 2000000 -ErrorAction 'Stop' -QueryTimeout 900
}
catch {
	pop-location
	$dlog = (date).tostring("yyyy-MM-dd HH:mm:ss.fff ")
	"$dlog  Error:  $($_.Exception.Message)" | Out-File -append "E:\logs\ReportBackupLog.txt"	#write the error to the log
	break																						#quit the program without making changes
}

pop-location

$l = $result.length

$dlog = (date).tostring("yyyy-MM-dd HH:mm:ss.fff ")
if ($dow -ne 0) {
"$dlog  $l reports modified" | Out-File -append "E:\logs\ReportBackupLog.txt"
}

#	If it's Sunday, delete everything under Team Content\Reports.
#	This is to delete items that are no longer in the Content Store.
if ($dow -eq 0) {
"$dlog  $l reports total" | Out-File -append "E:\logs\ReportBackupLog.txt"
	Remove-Item -path "E:\ReportBackup\Team Content\Reports" -recurse
}


#	Write the results to the file system
foreach($row in $result)
{
    $filepath = "E:\ReportBackup\"+$row.FilePath
    $contents = $row.SPEC
	
	try {
		if(!(Test-Path $filepath))
		{
			New-Item $filepath -ItemType file -Force -Value $contents
		}
		else
		{
			Set-Content -Path $filepath -Value $contents
		}
	}
	catch {
		"Error:  " + $row.FilePath | Out-File -append "E:\logs\ReportBackupLog.txt"
		"        " + $_.Exception.Message | Out-File -append "E:\logs\ReportBackupLog.txt"
		#"        " + $_.Exception.ItemName | Out-File -append "E:\logs\ReportBackupLog.txt"
		" " | Out-File -append "E:\logs\ReportBackupLog.txt"
	}
}

$dlog = (date).tostring("yyyy-MM-dd HH:mm:ss.fff ")
"$dlog  Content Store export complete" | Out-File -append "E:\logs\ReportBackupLog.txt"