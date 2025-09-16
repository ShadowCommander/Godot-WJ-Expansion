@tool
extends EditorScript

## Creates a mesh library from the children in tileset_mesh_library.tscn
## 1. Delete mesh_library.tres
## 2. Open tileset_mesh_library.tscn
## 3. Click File -> Run
## 4. Drag mesh_library into the 

const TILESET_MESH_LIBRARY = preload("res://scenes/grid/tileset_mesh_library.tscn")
var destination = "res://scenes/grid/mesh_library.tres" 

func _run() -> void:
	create_library()

func create_library() -> void:
	if not Engine.is_editor_hint():
		return
	
	var library = MeshLibrary.new()
	
	if ResourceLoader.exists(destination):
		print("Loading existing MeshLibrary [b]%s[/b]" % [destination])
		library = ResourceLoader.load(destination, "MeshLibrary")
	else:
		print_rich("Creating new MeshLibrary [b]%s[/b]" % [destination])
		library = MeshLibrary.new()
	
	var mesh_library_scene = TILESET_MESH_LIBRARY.instantiate()
	var root = mesh_library_scene
	var children = root.get_children()
	print(children)
	for c: Node in children:
		if c is not MeshInstance3D:
			continue
		var child: MeshInstance3D = c
		var id = library.find_item_by_name(child.name)
		if id == -1:
			id = library.get_last_unused_item_id()
		library.create_item(id)
		library.set_item_name(id, child.name)
		var mesh: QuadMesh = child.mesh.duplicate(true)
		print("Surfaces: ", mesh.get_surface_count())
		mesh.surface_set_material(0, child.get_surface_override_material(0).duplicate())
		print("material: ", mesh.material)
		library.set_item_mesh(id, mesh)
		var transform: Transform3D = Transform3D.IDENTITY
		library.set_item_mesh_transform(id, transform)
		library.set_item_navigation_mesh_transform(id, transform)
		library.set_item_shapes(id, [child.mesh.create_convex_shape(), Transform3D.IDENTITY])
		library.set_item_preview(id, EditorInterface.make_mesh_previews([child.mesh], 50)[0])
	var err = ResourceSaver.save(library, destination, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
	
	if err != OK:
		printerr("Error saving MeshLibrary: " + str(err))
	else:
		print("Saved MeshLibrary: " + destination)
