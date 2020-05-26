param([string]$fldr, [string]$msg)


#	Identify all of the changes to reports.
#	Push the changes to the git repository.
#	Record in a text file what files changed.



#$d = date
$dnum = (date).tostring("yyyyMMdd")
$dlog = (date).tostring("yyyy-MM-dd HH:mm:ss.fff ")


if ($fldr -eq "") {
	"$dlog  no folder provided" | Out-File -append "E:\logs\ReportBackupLog.txt"
	exit
}
if (!(Test-Path "$fldr\.git" -PathType Container)) {
    #    folder path not found
    "$dlog  $fldr is not a git repository" | Out-File -append "E:\logs\ReportBackupLog.txt"
    exit
}

if ($msg -eq "") {
	"$dlog  no message provided" | Out-File -append "E:\logs\ReportBackupLog.txt"
	exit
}


Set-Location -Path $fldr
#Write-Host "Path set to $fldr"

#	get repo status
$status = git status --porcelain

$status | Out-File -append "E:\logs\gitstatus$dnum.txt"

#	for each item that was changed (modified or added)
#		if it's an xml file, tidy the XML

#Write-Host " " >> "..\updates$dnum.txt"
$cmd = "e:\tools\tidy.exe"

foreach ($line in $status) {
	if (($line.Substring(0, 3) -eq " M " -Or $line.Substring(0, 3) -eq " A " -Or $line.Substring(0, 3) -eq "?? ") -And $line.Substring($line.length - 5, 4) -eq ".xml") {
		#	we want this one
		$f = "`"" + $fldr + "\" +  $line.Substring(4, $line.length - 5) + "`""
		$f = $f.replace("/", "\")
		
		$args = @(
			"-q", 
			"-xml", 
			"-wrap", "0", 
			"-indent", 
			"-o", $f, 
			$f
		)
		
		#	tidy
		#& "e:\tools\tidy.exe" "-q -xml -wrap 0 -indent -o $f $f"
		& $cmd $args
		
		##	record the change locally
		##Write-Host $f
		#$f | Out-File -append "E:\logs\updates$dnum.txt"
	}
	
	if (($line.Substring(0, 3) -eq " M " -Or $line.Substring(0, 3) -eq " A ") -And $line.Substring($line.length - 6, 5) -eq ".json") {
		#	we want this one
		$f = "`"" + $fldr + "\" +  $line.Substring(4, $line.length - 5) + "`""
		$f = $f.replace("/", "\")
		
		(get-content $f) | convertfrom-json | convertto-json -depth 100 | set-content $f
		#$dlog = (date).tostring("yyyy-MM-dd HH:mm:ss.fff ")
		#"$dlog  tidied $f" | Out-File -append "E:\logs\ReportBackupLog.txt"
	}
}


#	now that we've tidied the files, let's rerun status to see what really changed...
$status = git status --porcelain
#	...and record what changed
foreach ($line in $status) {
	if (($line.Substring(0, 3) -eq " M " -Or $line.Substring(0, 3) -eq " A " -Or $line.Substring(0, 3) -eq "?? ") -And ($line.Substring($line.length - 5, 4) -eq ".xml" -Or $line.Substring($line.length - 6, 5) -eq ".json")) {
		#	we want this one
		$f = "`"" + $fldr + "\" +  $line.Substring(4, $line.length - 5) + "`""
		$f = $f.replace("/", "\")
		
		#	record the change locally
		#Write-Host $f
		$f | Out-File -append "E:\logs\updates$dnum.txt"
	}
}



#	push the changes to remote git repo
git add -A
git commit -m $msg
git push

$dlog = (date).tostring("yyyy-MM-dd HH:mm:ss.fff ")
"$dlog  git push complete" | Out-File -append "E:\logs\ReportBackupLog.txt"
