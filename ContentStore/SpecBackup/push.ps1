param([string]$fldr, [string]$msg)

#cd $fldr

#	Identify all of the changes to reports.
#	Push the changes to the git repository.
#	Record in a text file what files changed.


#$d = date
$dnum = (date).tostring("yyyyMMdd")
$dlog = (date).tostring("yyyy-MM-dd HH:mm:ss.fff ")
$thisFolder = (Split-Path $MyInvocation.MyCommand.Source)
$ReportBackupLog = $thisFolder + "\logs\ReportBackupLog.txt"
$UpdatesLog = $thisFolder + "\logs\updates$dnum.txt"


if ($fldr -eq "") {
	"$dlog  no folder provided" | Out-File -append $ReportBackupLog
	exit
}
if (!(Test-Path "$fldr\.git" -PathType Container)) {
    #    folder path not found
    "$dlog  $fldr is not a git repository" | Out-File -append $ReportBackupLog
    exit
}

if ($msg -eq "") {
	"$dlog  no message provided" | Out-File -append $ReportBackupLog
	exit
}


Set-Location -Path $fldr
#Write-Host "Path set to $fldr"

#	get repo status
$status = git status --porcelain

#	for each item that was changed (modified or added)
#		if it's an xml file, tidy the XML

#Write-Host " " >> "..\updates$dnum.txt"
$cmd = $env:USERPROFILE + "\repos\WindowsTools\tidy.exe"

foreach ($line in $status) {
	if (($line.Substring(0, 3) -eq " M " -Or $line.Substring(0, 3) -eq " A ") -And $line.Substring($line.length - 5, 4) -eq ".xml") {
		#	we want this one
		#$f = "`"" + $fldr + "\" +  $line.Substring(4, $line.length - 5) + "`""
		#$f = $f.replace("/", "\")
		$f = Join-Path $fldr $line.Substring(4, $line.Length - 5)
		
		if(!(Test-Path $f)) {
			"File not found:  $f" | Out-File -append $ReportBackupLog
		}
		
		$args = @(
			"-q", 
			"-xml", 
			"-wrap", "0", 
			"-indent", 
			"-o", $f, 
			$f
		)
		
		#	tidy
		#& "e:\tools\tidy.bat" $f
		#& "e:\tools\tidy.exe" "-q -xml -wrap 0 -indent -o $f $f"
		& $cmd $args
		
		##	record the change locally
		##Write-Host $f
		#$f | Out-File -append $UpdatesLog
	}
	
	if (($line.Substring(0, 3) -eq " M " -Or $line.Substring(0, 3) -eq " A ") -And $line.Substring($line.length - 6, 5) -eq ".json") {
		#	we want this one
		$f = "`"" + $fldr + "\" +  $line.Substring(4, $line.length - 5) + "`""
		$f = $f.replace("/", "\")
		
		(get-content $f) | convertfrom-json | convertto-json -depth 100 | set-content $f
	}
}


#	now that we've tidied the xml, let's rerun status to see what really changed...
$status = git status --porcelain
#	...and record what changed
foreach ($line in $status) {
	if (($line.Substring(0, 3) -eq " M " -Or $line.Substring(0, 3) -eq " A ") -And ($line.Substring($line.length - 5, 4) -eq ".xml" -Or $line.Substring($line.length - 6, 5) -eq ".json")) {
		#	we want this one
		$f = "`"" + $fldr + "\" +  $line.Substring(4, $line.length - 5) + "`""
		$f = $f.replace("/", "\")
		
		#	record the change locally
		#Write-Host $f
		$f | Out-File -append $UpdatesLog
	}
}



#	push the changes to remote git repo
git add -A
git commit -m $msg
git push

$dlog = (date).tostring("yyyy-MM-dd HH:mm:ss.fff ")
"$dlog  git push complete" | Out-File -append $ReportBackupLog