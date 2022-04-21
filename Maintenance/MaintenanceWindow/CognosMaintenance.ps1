$logfile = "E:\logs\CognosMaintenance.txt"
$datestring = (date).tostring("yyyy-MM-dd")
$dlog = (date).tostring("yyyy-MM-dd hh:mm:ss.fff ")

"$dlog  Start Cognos maintenance" | Out-File -append $logfile

#	set the date to be sure this only happens once
if ($datestring -eq "2020-02-02") {
    #Do something
    #Log as you go
	$msg = ""
	
	
	

    #Log final status
    $dlog = (date).tostring("yyyy-MM-dd hh:mm:ss.fff ")
    "$dlog  Did something" | Out-File -append $logfile
    Send-MailMessage -To "email@domain.com" -From "email@domain.com"  -Subject "$env:COMPUTERNAME Maintenance" -Body $msg -SmtpServer "server.domain.com" -Port 25
}
else {
    "$dlog  Nothing to do" | Out-File -append $logfile
    Send-MailMessage -To "email@domain.com" -From "email@domain.com"  -Subject "$env:COMPUTERNAME Maintenance" -SmtpServer "server.domain.com" -Port 25
}


$dlog = (date).tostring("yyyy-MM-dd hh:mm:ss.fff ")
"$dlog  End Cognos maintenance" | Out-File -append $logfile
