//%attributes = {"invisible":true}
#DECLARE($params : Object)

If (Count parameters:C259=0)
	
	//execute in a worker to process callbacks
	CALL WORKER:C1389(1; Current method name:C684; {})
	
Else 
	
	$file:=File:C1566("/DATA/sample.txt")
	
	var $text_splitter : cs:C1710.text_splitter
	$text_splitter:=cs:C1710.text_splitter.new()
/*
file can be file, text, BLOB
capacity can be a size (1000) or range ("500..1500")
overlap must be smaller than size
trim: default is true
markdown: default is false
tiktoken: default is false
*/
	//$results:=$text_splitter.chunk({file: $file; capacity: "100..200"; overlap: 10})
	//$results:=$text_splitter.chunk({file: $file; capacity: "100..200"; overlap: 10; tiktoken: True})
	//SET TEXT TO PASTEBOARD(JSON Stringify(JSON Parse($results[0]); *))
	
	For ($i; 1; 10000)
		$text_splitter.chunk({file: $file; capacity: "100..200"; overlap: 50}; Formula:C1597(onResponse))
	End for 
	
End if 

//callbacks will fire only if we exit the method