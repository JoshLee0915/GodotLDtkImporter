tool
extends Control

onready var ldtkImportDialog = $LDtkFileImport
onready var outputDirDialog = $OutputDir
onready var outputDirTxt = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/HBoxContainer/OutputDirText

var outputDir = "res://"

class LDtkTileset:
	var uid
	var name
	var grid_size
	var texture
	var tileset
	
class LDtkLayer:
	var uid
	var grid_size
	var tileset_uid
	var auto_tileset_uid

# Called when the node enters the scene tree for the first time.
func _ready():
	outputDirTxt.text = outputDir
	outputDirDialog.current_dir = outputDir

func _create_assets(projectName, ldtkDefs, ldtkHomeDirectory):
	var tilesetDirPath = outputDir.plus_file(projectName.plus_file("/tilesets/"))
	
	var tilesetDir = Directory.new()
	if !tilesetDir.dir_exists(tilesetDirPath):
		tilesetDir.make_dir_recursive(tilesetDirPath)
	
	var tilesets = _create_tilesets(ldtkDefs["tilesets"], ldtkHomeDirectory, tilesetDirPath)
	
func _create_tilesets(ldtkTilesets, ldtkHomeDirectory, tilesetDirPath):
	var tilesetDict = {}
	for tilesetData in ldtkTilesets:
		var ldtkTileset = LDtkTileset.new()
		ldtkTileset.uid = tilesetData["uid"]
		ldtkTileset.name = tilesetData["identifier"]
		ldtkTileset.grid_size = tilesetData["tileGridSize"]
		ldtkTileset.texture = load(ldtkHomeDirectory.plus_file(tilesetData["relPath"]))
		
		var tilesetPath = tilesetDirPath.plus_file(tilesetData["identifier"]+".tres")
		if ResourceLoader.exists(tilesetPath):
			ldtkTileset.tileset = ResourceLoader.load(tilesetPath)
		else:
			ldtkTileset.tileset = TileSet.new()
		
		tilesetDict[ldtkTileset.uid] = ldtkTileset
		
	return tilesetDict
	
func _load_layer_defs(ldtkLayerDef):
	layerDict = {}
	for layer in ldtkLayerDef:
		pass
	
func _create_levels(levels, layersDef, tilesets):
	for level in levels:
		pass
	
func _create_layer(layer, layersDef, tilesets):
	pass

func _on_SelectDir_pressed():
	outputDirDialog.popup_centered()


func _on_Import_pressed():
	ldtkImportDialog.popup_centered()


func _on_OutputDir_dir_selected(dir):
	outputDir = dir
	outputDirTxt.text = outputDir
	outputDirDialog.current_dir = outputDir


func _on_LDtkFileImport_file_selected(path):
	var ldtkFile = File.new()
	ldtkFile.open(path, File.READ)
	var parsedLDtk = JSON.parse(ldtkFile.get_as_text())
	ldtkFile.close()
	
	if parsedLDtk.error == OK:
		_create_assets(path.get_file().split(".")[0], parsedLDtk.result["defs"], path.get_base_dir())
