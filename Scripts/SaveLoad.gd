extends Node

static func saveData(savePath : String, data):
	var file = File.new()
		
	file.open(savePath, file.WRITE)
	file.store_var(data)
	file.close()
	
	print("file saved successfully")
	
static func loadData(savePath : String):
	var file : File = File.new()
	if !file.file_exists(savePath):
		print_debug('file [%s] does not exist...' % savePath)
		return
	
	var error = file.open(savePath, file.READ)
	#var data_parse = JSON.parse(file.get_as_text())
	#var data = data_parse.result
	var dataDict = []
	if error == OK:
		dataDict = file.get_var()
		file.close()
	
	return dataDict
