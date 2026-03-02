property text_splitter : cs:C1710._text_splitter

Class constructor($class : 4D:C1709.Class)
	
	var $controller : 4D:C1709.Class
	var $superclass : 4D:C1709.Class
	$superclass:=$class.superclass
	$controller:=cs:C1710._CLI_Controller
	
	While ($superclass#Null:C1517)
		If ($superclass.name=$controller.name)
			$controller:=$class
			break
		End if 
		$superclass:=$superclass.superclass
	End while 
	
	This:C1470.text_splitter:=cs:C1710._text_splitter.new("text-splitter"; $controller)
	
Function get worker() : 4D:C1709.SystemWorker
	
	return This:C1470.workers.first()
	
Function get workers() : Collection
	
	If (This:C1470.text_splitter=Null:C1517)
		return 
	End if 
	
	return This:C1470.text_splitter.controller.workers
	
Function terminate()
	
	If (This:C1470.text_splitter=Null:C1517)
		return 
	End if 
	
	This:C1470.text_splitter.controller.terminate()
	
Function chunk($option : Variant; $formula : 4D:C1709.Function) : Collection
	
	If (This:C1470.text_splitter=Null:C1517)
		return 
	End if 
	
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
		//once
		If (This:C1470.text_splitter.controller._onResponse=Null:C1517)
			Use (This:C1470.text_splitter.controller)
				This:C1470.text_splitter.controller._onResponse:=$formula
			End use 
		End if 
	End if 
	
	For each ($option; $options)
		
		If ($option=Null:C1517) || (Value type:C1509($option)#Is object:K8:27)
			continue
		End if 
		
		$stdOut:=Not:C34(OB Instance of:C1731($option.output; 4D:C1709.File))
		
		$command:=This:C1470.text_splitter.escape(This:C1470.text_splitter.executablePath)
		
		Case of 
			: (Value type:C1509($option.file)=Is object:K8:27) && (OB Instance of:C1731($option.file; 4D:C1709.File)) && ($option.file.exists)
				$command+=" --input "
				$command+=This:C1470.text_splitter.escape(This:C1470.text_splitter.expand($option.file).path)
			: (Value type:C1509($option.file)=Is object:K8:27) || (Value type:C1509($option.file)=Is BLOB:K8:12) || (Value type:C1509($option.file)=Is text:K8:3)
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
		
		If ($option.tiktoken#Null:C1517) && (Value type:C1509($option.tiktoken)=Is boolean:K8:9) && ($option.tiktoken)
			$command+=" --tiktoken "
		End if 
		
		If ($option.markdown#Null:C1517) && (Value type:C1509($option.markdown)=Is boolean:K8:9) && ($option.markdown)
			$command+=" --markdown "
		End if 
		
		If ($option.compact#Null:C1517) && (Value type:C1509($option.compact)=Is boolean:K8:9) && ($option.compact)
			$command+=" --compact "
		End if 
		
		If ($option.batch#Null:C1517) && (Value type:C1509($option.batch)=Is boolean:K8:9) && ($option.batch)
			$command+=" --batch "
		End if 
		
		If (Not:C34($stdOut))
			$command+=" --output "
			$command+=This:C1470.text_splitter.escape(This:C1470.text_splitter.expand($option.output).path)
		End if 
		
		var $worker : 4D:C1709.SystemWorker
		$worker:=This:C1470.text_splitter.controller.execute($command; $isStream ? $option.file : Null:C1517; $option.data).worker
		
		If (Not:C34($isAsync))
			$worker.wait()
		End if 
		
		If (Not:C34($isAsync))
			If ($stdOut)
				$results.push($worker.response)
			Else 
				$results.push(Null:C1517)
			End if 
		End if 
		
	End for each 
	
	If (Not:C34($isAsync))
		return $results
	End if 