property _complete; hideWindow : Boolean
property dataType; encoding : Text
property variables : Object
property _commands; _messages; _contexts : Collection
property timeout : Variant
property onResponse; _onResponse; onTerminate; _onTerminate : 4D:C1709.Function
property _instance : cs:C1710._CLI
property currentDirectory : 4D:C1709.Folder

shared Class constructor($CLI : cs:C1710._CLI)
	
	var __SYSTEM_WORKERS__ : Object
	
	//use default event handler if not defined in subclass definition
	For each ($event; ["onData"; "onDataError"; "onError"; "onResponse"; "onTerminate"])
		If (Not:C34(OB Instance of:C1731(This:C1470[$event]; 4D:C1709.Function)))
			This:C1470[$event]:=This:C1470._onEvent
		End if 
	End for each 
	
	//define callbacks
	This:C1470.onResponse:=This:C1470._onExecute
	
	This:C1470.timeout:=Null:C1517
	This:C1470.dataType:="text"
	This:C1470.encoding:="UTF-8"
	This:C1470.variables:=New shared object:C1526
	This:C1470.currentDirectory:=$CLI.currentDirectory
	This:C1470.hideWindow:=True:C214
	
	This:C1470._instance:=$CLI
	This:C1470._commands:=New shared collection:C1527
	This:C1470._messages:=New shared collection:C1527
	This:C1470._contexts:=New shared collection:C1527
	This:C1470._complete:=False:C215  //flag to indicate whether we have queued commands
	
Function get commands()->$commands : Collection
	
	$commands:=This:C1470._commands
	
Function get complete()->$complete : Boolean
	
	$complete:=This:C1470._complete
	
Function get instance()->$instance : cs:C1710._CLI
	
	$instance:=This:C1470._instance
	
Function get worker() : 4D:C1709.SystemWorker
	
	return This:C1470.workers.first()
	
Function get workers() : Collection
	
	var $instanceName : Text
	$instanceName:=OB Class:C1730(This:C1470.instance).name
	
	If (__SYSTEM_WORKERS__=Null:C1517)
		__SYSTEM_WORKERS__:={}
	End if 
	
	If (__SYSTEM_WORKERS__[$instanceName]=Null:C1517)
		__SYSTEM_WORKERS__[$instanceName]:=[]
	End if 
	
	return __SYSTEM_WORKERS__[$instanceName]  //shared class can't retain system worker
	
	//MARK:-public methods
	
Function execute($command : Variant; $message : Variant; $context : Variant) : cs:C1710._CLI_Controller
	
	var $commands : Collection
	var $messages : Collection
	var $contexts : Collection
	
	Case of 
		: (Value type:C1509($command)=Is text:K8:3)
			$commands:=[$command]
			$messages:=[$message]
			$contexts:=[$context]
		: (Value type:C1509($command)=Is collection:K8:32)
			$commands:=$command
			If (Value type:C1509($message)=Is collection:K8:32) && ($message.length=$commands.length)
				$messages:=$message
			Else 
				$messages[$commands.length-1]:=Null:C1517
			End if 
			If (Value type:C1509($context)=Is collection:K8:32) && ($context.length=$commands.length)
				$contexts:=$context
			Else 
				$contexts[$commands.length-1]:=Null:C1517
			End if 
	End case 
	
	If ($commands#Null:C1517) && ($commands.length#0)
		
		This:C1470._commands.combine($commands)
		This:C1470._messages.combine($messages)
		This:C1470._contexts.combine($contexts.copy(ck shared:K85:29; This:C1470._contexts))
		
		var $workers : Collection
		$workers:=This:C1470.workers
		
		$terminated:=$workers.countValues(True:C214; "terminated")=$workers.length
		
		This:C1470._execute($terminated)
		
	End if 
	
	return This:C1470
	
Function terminate()
	
	This:C1470._abort()
	
	var $worker : 4D:C1709.SystemWorker
	$worker:=This:C1470.worker
	
	If ($worker#Null:C1517)
		$worker.terminate()
	End if 
	
	//This._terminate()
	
	//MARK:-private methods
	
Function _onEvent($worker : 4D:C1709.SystemWorker; $params : Object)
	
	Case of 
		: ($params.type="data") && ($worker.dataType="text")
			
		: ($params.type="data") && ($worker.dataType="blob")
			
		: ($params.type="error")
			
		: ($params.type="termination")
			
		: ($params.type="response")
			
	End case 
	
Function _onExecute($worker : 4D:C1709.SystemWorker; $params : Object)
	
	var $instanceName : Text
	$instanceName:=OB Class:C1730(This:C1470.instance).name
	
	cs:C1710.logger.new().log([$instanceName; "End"; $worker.pid; This:C1470._commands.length])
	
	If (This:C1470._commands.length=0)
		This:C1470._abort()
	Else 
		This:C1470._execute(True:C214)
	End if 
	
	If (OB Instance of:C1731(This:C1470._onResponse; 4D:C1709.Function))
		$params.context:=This:C1470._contexts.shift()
		This:C1470._onResponse.call(This:C1470; $worker; $params)
	End if 
	
Function _countRunningWorkers() : Integer
	
	return This:C1470.workers.countValues(False:C215; "terminated")
	
Function _execute($start : Boolean)
	
	var $instanceName : Text
	$instanceName:=OB Class:C1730(This:C1470.instance).name
	
	If ($start)
		var $command : Text
		var $i; $length; $runningWorkers; $count : Integer
		$length:=This:C1470._commands.length
		$threads:=This:C1470.instance.system.threads
		$runningWorkers:=This:C1470._countRunningWorkers()
		
		$count:=$threads<$length ? $threads : $length
		$count:=$runningWorkers<$count ? ($count-$runningWorkers) : 1
		
		For ($i; 1; $count)
			$command:=This:C1470._commands.shift()
			$worker:=4D:C1709.SystemWorker.new($command; This:C1470)
			cs:C1710.logger.new().log([$instanceName; "Start"; $worker.pid; This:C1470._commands.length])
			__SYSTEM_WORKERS__[$instanceName].push($worker)
			Use (This:C1470)
				This:C1470._complete:=False:C215
			End use 
			var $message : Variant
			$message:=This:C1470._messages.shift()
			var $vt : Integer
			$vt:=Value type:C1509($message)
			If ($vt=Is object:K8:27) && (OB Instance of:C1731($message; 4D:C1709.Blob))
				$vt:=Is BLOB:K8:12
			End if 
			Case of 
				: ($vt=Is object:K8:27) || ($vt=Is collection:K8:32)
					$worker.postMessage(JSON Stringify:C1217($message))
					$worker.closeInput()
				: ($vt=Is BLOB:K8:12) || ($vt=Is text:K8:3)
					$worker.postMessage($message)
					$worker.closeInput()
				: ($vt=Is real:K8:4) || ($vt=Is integer:K8:5) || ($vt=Is boolean:K8:9) || ($vt=Is date:K8:7) || ($vt=Is time:K8:8)
					$worker.postMessage(String:C10($message))
					$worker.closeInput()
			End case 
		End for 
	Else 
		cs:C1710.logger.new().log([$instanceName; "Wait"; "*"; This:C1470._commands.length])
	End if 
	
Function _abort()
	
	Use (This:C1470)
		This:C1470._complete:=True:C214
	End use 