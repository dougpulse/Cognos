#  docs at
#  http://<cognos_analytics_server>:<port>/api/api-docs

# $thisFolder = (Split-Path $MyInvocation.MyCommand.Source)
# Set-Location $thisFolder
# $functions = ".\fn.ps1"
$functions = Join-Path $env:USERPROFILE "repos\CognosAdmin\RESTAPI\fn.ps1"
. $functions

$serverName = Read-Host "Cognos Server Name"

$CognosSession = start-CognosSession -serverName $serverName

if ($CognosSession) {
        $uriBase = $CognosSession.uriBase
        $protocol = $CognosSession.protocol
        $serverName = $CognosSession.serverName
        $port = $CognosSession.port
        $Session = $CognosSession.Session
        $headers = $CognosSession.Headers
        $contentType = $CognosSession.contentType
        #"********************
        #Cognos Session:"
        #Write-Host $CognosSession
        #"********************"

        #=====================================================================================================================
        #   DDDDD      OOO          SSS   TTTTTTT U    U FFFFFF FFFFFF
        #   D     D  O     O       S         T    U    U F      F
        #   D     D  O     O        SSS      T    U    U FFFF   FFFF
        #   D     D  O     O           S     T    U    U F      F
        #   DDDDD      OOO          SSS      T     UUUU  F      F
        #=====================================================================================================================
		
        "



                STARTING

        ========================================
        "

        $contentId = "library"
        $uri = "$uriBase/api/v1/content/$contentId/items"
        $content = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -contentType $contentType -WebSession $Session
        $content.content | Format-List

        #=====================================================================================================================
        #   DDDDD      OOO   N    N EEEEEE      DDDDD      OOO   IIIII N    N  GGGG        SSS   TTTTTTT U    U FFFFFF FFFFFF
        #   D     D  O     O N N  N E           D     D  O     O   I   N N  N G           S         T    U    U F      F
        #   D     D  O     O N  N N EEEE        D     D  O     O   I   N  N N G  GGG       SSS      T    U    U FFFF   FFFF
        #   D     D  O     O N   NN E           D     D  O     O   I   N   NN G    G          S     T    U    U F      F
        #   DDDDD      OOO   N    N EEEEEE      DDDDD      OOO   IIIII N    N  GGGG        SSS      T     UUUU  F      F
        #=====================================================================================================================

        stop-CognosSession -CognosSession $CognosSession
}