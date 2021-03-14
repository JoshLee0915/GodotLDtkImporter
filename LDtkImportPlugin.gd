tool
extends EditorImportPlugin

var importEngine

func get_importer_name():
	return "ldtk.mapimporter"

func get_visible_name():
	return "LDtk Map"
	
func get_recognized_extensions():
	return ["ldtk"]
	
func get_save_extension():
	return ""
	
func get_resource_type():
	return "TextFile"
	
func get_import_options(preset):
	return []
	
func import(source_file, save_path, options, r_platform_variants, r_gen_files):
	importEngine = preload("ImportEngine.gd").new()
	var ldtkFile = importEngine.load_ldtk_file(source_file)
	if ldtkFile.error != OK:
		return ldtkFile.error

	save_path = source_file.get_basename()
	var tilsetPath = save_path.plus_file("tilesets")
	
	var directory = Directory.new()
	if !directory.dir_exists(tilsetPath):
		var error = directory.make_dir_recursive(tilsetPath)
		if error != OK:
			return error

	var layerDefs = importEngine.load_layer_defs(ldtkFile.defs)
	var tilesets = importEngine.load_tilesets(ldtkFile.defs, source_file.get_base_dir(), tilsetPath)
	
	for level in ldtkFile.levels:
		var scenePath = importEngine.generate_level(level, layerDefs, tilesets, save_path)
		if scenePath:
			r_gen_files.append(scenePath)

	for tileset in tilesets.values():
		if ResourceSaver.save(tileset.path, tileset.tileset) == OK:
			r_gen_files.append(tileset.path)
		else:
			print_debug("error saving tileset file")

	return OK
