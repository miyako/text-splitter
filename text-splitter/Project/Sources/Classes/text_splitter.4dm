Class extends _CLI

Class constructor($controller : 4D:C1709.Class)
	
	If (Not:C34(OB Instance of:C1731($controller; cs:C1710._text_splitter_Controller)))
		$controller:=cs:C1710._text_splitter_Controller
	End if 
	
	Super:C1705("text-splitter"; $controller)
	
Function get worker() : 4D:C1709.SystemWorker
	
	return This:C1470.controller.worker
	
Function terminate()
	
	This:C1470.controller.terminate()
	
Function chunk($option : Variant; $formula : 4D:C1709.Function) : Collection
	
	var $stdOut; $isStream; $isAsync : Boolean
	var $options : Collection
	var $results : Collection
	$results:=[]
	
	Case of 
		: (Value type:C1509($option)=Is object:K8:27)
			$options:=[$option]
		: (Value type:C1509($option)=Is collection:K8:32)
			$options:=$option
		Else 
			$options:=[]
	End case 
	
	var $commands : Collection
	$commands:=[]
	
	If (OB Instance of:C1731($formula; 4D:C1709.Function))
		$isAsync:=True:C214
		This:C1470.controller.onResponse:=$formula
	End if 
	
	For each ($option; $options)
		
		If ($option=Null:C1517) || (Value type:C1509($option)#Is object:K8:27)
			continue
		End if 
		
		$stdOut:=Not:C34(OB Instance of:C1731($option.output; 4D:C1709.File))
		
		$command:=This:C1470.escape(This:C1470.executablePath)
		
		Case of 
			: (OB Instance of:C1731($option.file; 4D:C1709.File)) && ($option.file.exists)
				$command+=" --input "
				$command+=This:C1470.escape(This:C1470.expand($option.file).path)
			: (OB Instance of:C1731($option.file; 4D:C1709.Blob)) || (Value type:C1509($option.file)=Is BLOB:K8:12) || (Value type:C1509($option.file)=Is text:K8:3)
				$command+=" "
				$isStream:=True:C214
		End case 
		
		Case of 
			: ($option.capacity#Null:C1517) && (Value type:C1509($option.capacity)=Is text:K8:3) && (Match regex:C1019("\\d+\\.\\.\\d+"; $option.capacity; 1))
				$command+=" --capacity "
				$command+=$option.capacity
			: ($option.capacity#Null:C1517) && ((Value type:C1509($option.capacity)=Is real:K8:4) || (Value type:C1509($option.capacity)=Is integer:K8:5)) && ($option.capacity>0)
				$command+=" --capacity "
				$command+=String:C10(Int:C8($option.capacity))
		End case 
		
		If ($option.overlap#Null:C1517) && ((Value type:C1509($option.overlap)=Is real:K8:4) || (Value type:C1509($option.overlap)=Is integer:K8:5)) && ($option.overlap>0)
			$command+=" --overlap "
			$command+=String:C10(Int:C8($option.overlap))
		End if 
		
		If ($option.tiktoken#Null:C1517) && (Value type:C1509($option.tiktoken)=Is boolean:K8:9)
			$command+=" --tiktoken "
		End if 
		
		If ($option.markdown#Null:C1517) && (Value type:C1509($option.markdown)=Is boolean:K8:9)
			$command+=" --markdown "
		End if 
		
		var $worker : 4D:C1709.SystemWorker
		$worker:=This:C1470.controller.execute($command; $isStream ? $option.file : $option.context; $option.data).worker
		
		If (Not:C34($isAsync))
			$worker.wait()
		End if 
		
		If ($stdOut) && (Not:C34($isAsync))
			//%W-550.26
			//%W-550.2
			$results.push(This:C1470.controller.stdOut)
			This:C1470.controller.clear()
			//%W+550.2
			//%W+550.26
		End if 
		
	End for each 
	
	If ($stdOut) && (Not:C34($isAsync))
		return $results
	End if 