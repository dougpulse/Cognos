$logfile = "E:\logs\CognosMaintenance.txt"
$datestring = (date).tostring("yyyy-MM-dd")
$dlog = (date).tostring("yyyy-MM-dd hh:mm:ss.fff ")

"$dlog  Starting Cognos	Please wait 10 minutes for full service startup." | Out-File -append $logfile

Start-Service -Name "IBM Cognos"

$dlog = (date).tostring("yyyy-MM-dd hh:mm:ss.fff ")
"$dlog  End Cognos maintenance" | Out-File -append $logfile
