property path : Text

shared singleton Class constructor($file : 4D:C1709.File)
	
	If ($file=Null:C1517) || (Not:C34(OB Instance of:C1731($file; 4D:C1709.File)))
		return 
	End if 
	
	This:C1470.path:=$file.path
	
	CALL WORKER:C1389(OB Class:C1730(This:C1470).name; Formula:C1597(_Logger_START); $file)
	
Function log($messages : Collection)
	
	If ($messages=Null:C1517) || ($messages.length=0)
		return 
	End if 
	
	CALL WORKER:C1389(OB Class:C1730(This:C1470).name; Formula:C1597(_Logger_LOG); $messages)