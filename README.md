# GodotLDtkImporter
## Overview
The GodotLDtkImporter is a plugin for the [Godot] Game Engine that allows levels created by the [LDtk] level editor to be imported as standard scenes into Godot.

**!!!WARNING THIS PLUGIN IS NOT YET FEATURE COMPLETE AND HAS NOT BEEN FULLY TESTED. IT SHOULD BE CONSIDERED IN ALPHA!!!**

The readme is also fairly complete but should be expected to be missing some information.

Currently supports [LDtk] 0.6 and [Godot] 3.0 and only supports the `.ldtk` extension.

## Install
This plugin can be installed manually or through the [Godot] asset lib. See the below link for details on how to install plugins in [Godot].

https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html

## Import Directory Structure
The LDtk Importer creates a relatively simple directory structure for each LDtk file it imports. When importing a `.ldtk` file it first creates a root directory with the same name as the `.ldtk` file within the same directory the `.ldtk` file is located. From there it creates one subdirectory called `tilesets` where it will store any generated tileset resources from the `.ldtk` file. These generated tileset resources will use the same name as the name specified for the respective tileset within the [LDtk] editor with `.tres` appended to the end of the name.

Each level is then generated as a standard `.tscn` scene and saved in the root directory that was created for that `.ldtk` file. The name of each scene is the same as the name specified for that level with the [LDtk] editor.

Later versions of the importer will create an optional `assets` directory where the tileset images will be copied to if the copy option is selected. 

## Scene Generation
For each level within a `.ldtk` file the importer will create a new scene for each level if it does not exist or open the scene and update it if a file for it already exists. When a scene is updated the importer does not usually fully clear or recreate nodes but instead will attempt to only update what it needs to, to keep the scene in sync with the `.ldtk` file. It should be noted that the importer always assumes the `.ldtk` file is the source of truth and will choose to use the values from the `.ldtk` over values set within the [Godot] editor.

### Scene Structure
Generated scenes contain a root `Node2D` node that has its display name set to the name of the level being imported. The importer then creates two additional `Node2D` nodes, one for `Layers` and one for `Entities`. The `Layers` node holds one `TileMap` node for each layer within the imported `.ldtk` file. 

### Issues
There seems to be some issues with keeping the scene in sync after the initial import. This mainly comes from the fact that I attempted to ensure the importer only updates what it needs to in order to allow for these scenes to be directly modified by the dev. For the most part the tilemaps work fine though they do not clear themselves so it will sometimes leave removed tiles behind. Entities also have the least amount of testing around them and seem to have import issues sometimes.

## Tileset Generation
The importer creates a tileset resource for each defined tileset within the imported `.ldtk` file. This happens even if the tileset is not in use yet due to an issue with saving changes to the resource files. The tiles of each tileset are created lazily though and will only be created when the importer first encounters it within the level it is importing. Each tile created is given the tileId that is defined within the `.ldtk` file.

## Entities
The importer will attempt to import Entities placed in a level with the `.ldtk` file. It does this through a best effort import that will try to setup what it can or skip the entity if it can not create it.

### Generation
All entity nodes are created under the `Entities` node in the generated scene. In order for the importer to create an entity the entity must have at least a `_Node` or `_Scene` property to tell the importer what node or prebuilt scene should be used for the Entity. If the node or scene can not be found or created the generation of the entity is skipped.

### Reserved Keywords
- `_Node` - The name of a node or node class to instantiate for that entity. `String`, `Enum`, or any other data type that is stored as a string can be used. If specified with `_Scene` the node will become the root node and the specified scene will become a child of that node.
- `_Scene` - The name or path of an existing scene to instantiate for that entity. The importer will search for the first instance that matches the name or path given. `String`, `Enum`, or any other data type that is stored as a string can be used. If `_Node` is not specified the scene will be used as the root node for that Entity.

### Setting Propeties
The importer will make an best effort attempt to set top level properties of a node if it finds a matching property defined on the [LDtk] entity. If it fails to set the property it will skip setting it.

## Panned & Missing Features
1. Offsets in general are not yet supported
2. World layout not yet supported
3. Add option to allow the importer to copy the tileset images to a directory within `res://` instead of relying on them being in the `res://` directory durning import

[Godot]: https://godotengine.org/
[LDtk]: https://deepnight.net/tools/ldtk-2d-level-editor/