property fileHandle : 4D:C1709.FileHandle
property path : Text

Class constructor($file : 4D:C1709.File)
	
	This:C1470.path:=$file.path
	
Function log($messages : Collection)
/*
`4D.FileHandle` can't be a property of a shared object;
Use a singular process instance instead of a shared singleton
*/
	
	var $file : 4D:C1709.File
	$file:=File:C1566(This:C1470.path)
	
	If (This:C1470.fileHandle=Null:C1517) || (Not:C34($file.exists))
		This:C1470.fileHandle:=$file.open("append")
	End if 
	
	Try(This:C1470.fileHandle.writeLine([Timestamp:C1445].combine($messages).join("\t"; ck ignore null or empty:K85:5)))