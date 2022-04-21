# SSL Cert Renewal
SSL certificates expire.  It's a little embarrassing when your Cognos service stops working because you missed a deadline.


<dl>
  <dt>SSLCertExpiration.csv</dt>
  <dd>Contains data about your SSL cert expiration dates.  Used by SSLExpiration.ps1<br />I have divided some of this data up by Cognos service (dispatcher, content manager, ...) but my systems are all single-server.  Your mileage may vary.</dd>
  
  <dt>SSLExpiration.ps1</dt>
  <dd>Identifies any SSL certificates that will expire in the next 10 days.  This is run daily using Windows Task Scheduler.<br />Calls RequestCognosServerCert.ps1 if appropriate.</dd>
  
  <dt>RequestCongosServerCert.ps1</dt>
  <dd>As a convenience, because my local webmaster is my Certificate Authority (CA), if the cert about to expire is a server cert, I generate the signing request and automatically email the request to the CA.</dd>
</dl>
