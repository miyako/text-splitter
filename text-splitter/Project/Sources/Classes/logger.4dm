Class extends _Logger

shared singleton Class constructor()
	
	var $folder : 4D:C1709.Folder
	$folder:=Folder:C1567(fk user preferences folder:K87:10).folder("text-splitter")
	$folder.create()
	
	var $file : 4D:C1709.File
	$file:=$folder.file("log.txt")
	
	Super:C1705($file)