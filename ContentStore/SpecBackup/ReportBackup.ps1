$exportResult = & ((Split-Path $MyInvocation.InvocationName) + "\export.ps1")
if ($exportResult -eq 1) {
	#$fldr = ($env:USERPROFILE) + "\repos\CognosReports"
	$fldr = Join-Path ($env:USERPROFILE) "\repos\CognosReports"
	$msg = "`"Daily backup`""
	& ((Split-Path $MyInvocation.InvocationName) + "\push.ps1") $fldr $msg
}