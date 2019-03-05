#	If ReportBackupLog.txt is too large, rename it.

$dnum = (date).tostring("yyyyMMdd.HHmmss")
if ((Get-Item "E:\logs\ReportBackupLog.txt").length -gt 500kb) {
	Rename-Item -Path "E:\logs\ReportBackupLog.txt" -NewName "ReportBackupLog.$dnum.txt"
}


#	be sure the local git repo is in synch with the remote repo

$fldr = "E:\ReportBackup"
Set-Location -Path $fldr
$pull = git pull

$dlog = (date).tostring("yyyy-MM-dd hh:mm:ss.fff ")
"" | Out-File -append "E:\logs\ReportBackupLog.txt"
"$dlog  git pull complete" | Out-File -append "E:\logs\ReportBackupLog.txt"
#"---   BEGIN PULL OUTPUT   ---" | Out-File -append "E:\logs\ReportBackupLog.txt"
$pull | Out-File -append "E:\logs\ReportBackupLog.txt"
#"---   END PULL OUTPUT   ---" | Out-File -append "E:\logs\ReportBackupLog.txt"
"" | Out-File -append "E:\logs\ReportBackupLog.txt"


#	get the report specs
& ((Split-Path $MyInvocation.InvocationName) + "\export.ps1")


#	push the changes to the remote git repository
$msg = "`"Daily backup`""
& ((Split-Path $MyInvocation.InvocationName) + "\push.ps1") $fldr $msg
