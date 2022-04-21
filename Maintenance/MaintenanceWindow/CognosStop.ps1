$logfile = "E:\logs\CognosMaintenance.txt"
$datestring = (date).tostring("yyyy-MM-dd")
$dlog = (date).tostring("yyyy-MM-dd hh:mm:ss.fff ")

"$dlog  Start Cognos maintenance" | Out-File -append $logfile
"$dlog  Stopping Cognos" | Out-File -append $logfile

Stop-Service -Name "IBM Cognos"
