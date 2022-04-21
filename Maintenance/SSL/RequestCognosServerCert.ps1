param([string]$serverName, [string]$certType, [string]$expirationDate)

$cognos = "E:\Program Files\ibm\cognos\analytics"

e:
cd "$cognos\bin"

ThirdPartyCertificateTool.bat -java:local -c -e -d "CN=$serverName.domain.com,O=domain,C=US" -H $serverName.wsdot.loc -a RSA -r encryptRequest.csr -p NoPassWordSet

$subject = "SSL Cert for $servername"
$from = "DoNotReply@domain.com"
#  Assuming your webmaster provides your CA certs...
$to = "Cognos Help <CognosHelp@domain.com>,Domain Webmaster <Webmaster@domain.com>"
$attachment = ".\encrypt.csr"
$body = "The $certType SSL cert for the Cognos service "
$body += "on $serverName "
$body += "will expire on $expirationDate.`r`n"
$body += "Please provide the server cert in PEM (Base-64 encoded ASCII) format "
$body += "for the attached signing request to Cognos Help <CognosHelp@domain.com>."

Send-MailMessage -From $from -To $to -Subject $subject -Body $body -Attachments $attachment
