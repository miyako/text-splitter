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
	
	
	$results:=$text_splitter.chunk({file: $file; capacity: "100..200"; overlap: 10; tiktoken: True:C214})
	
	SET TEXT TO PASTEBOARD:C523(JSON Stringify:C1217(JSON Parse:C1218($results[0]); *))
	
	//$text_splitter.chunk({file: $file; capacity: "100..200"; overlap: 50}; Formula(onResponse))
	
	
End if 