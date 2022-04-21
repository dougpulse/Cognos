#  Store the cert expiration dates in a CSV file.
$SSLInfo = Import-Csv -Path "E:\tools\SSLCertExpiration.csv"

$SMTPServer = "server.domain.com"
$from = "CognosServer <donotreply@domain.com>"
$to = "Cognos Help <CognosHelp@domain.com>"
$subject = "Cognos:  An SSL cert is about to expire"

#  The email message can include a link to your documentation regarding your SSL certs.
$wikiURL = "http://wiki.domain.com/wiki.php?id=cognos:admin:ssl_cert_schedules"

foreach ($e in $SSLInfo) {
    $e.Expires=[Datetime]::ParseExact($e.Expires, 'M/d/yyyy', $null)
    if ((Get-Date) -gt $e.Expires.AddDays(-10)) {
        $certType = $e.Type               # root, intermediate, or machine
        $certProduct = $e.Product         # Cognos Analytics Server, Framework Manager, or IIS
        $certMachineName = $e.MachineName
        $certMachineDescription = $e.MachineDescription
        $certExpirationDate = $e.Expires

        $body = "The $certType SSL cert "
        $body += "for $certProduct "
        $body += "on $certMachineName ($certMachineDescription) "
        $body += "will expire on " + $certExpirationDate.ToString('MM/dd/yyyy') + ".`r`n"
        $body += "Please visit $wikiURL"
        
        Send-MailMessage -From $from -To $to -Subject $subject -Body $body
        if ($certProduct -eq "Cognos Server") {
            & ((Split-Path $MyInvocation.InvocationName) + "\RequestCognosServerCert.ps1") $certMachineName $certType $certExpirationDate.ToString('MM/dd/yyyy')
        }
    }
}

