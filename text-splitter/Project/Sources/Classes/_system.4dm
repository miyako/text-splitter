property threads : Integer

Class constructor()
	
	var $systemInfo : Object
	$systemInfo:=System info:C1571
	var $cpuThreads : Integer
	$cpuThreads:=$systemInfo.cpuThreads
	
	If ($systemInfo.processor="@apple@")
		$cpuThreads/=2
	End if 
	
	This:C1470.threads:=$cpuThreads