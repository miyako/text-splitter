Class extends _CLI

shared Class constructor($executableName : Text; $controller : 4D:C1709.Class)
	
	Super:C1705($executableName; $controller)
	
	var $instanceName : Text
	$instanceName:=OB Class:C1730(This:C1470).name
	
	cs:C1710.logger.new().log([$instanceName; "Create"; "*"; "*"])