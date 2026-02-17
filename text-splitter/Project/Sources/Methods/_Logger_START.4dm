//%attributes = {"invisible":true,"preemptive":"capable"}
#DECLARE($file : 4D:C1709.File)

var LoggerInstance : cs:C1710._LoggerInstance
If (LoggerInstance=Null:C1517)
	LoggerInstance:=cs:C1710._LoggerInstance.new($file)
End if 