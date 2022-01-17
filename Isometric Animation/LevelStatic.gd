tool
extends StaticBody

export (Array, Material) var materials = []
export (Array, String) var material_names = []
export (String) var mesh_instance_name = "MeshInstance"
export (String) var collision_shape_name = "CollisionShape"
export (bool) var debug = false

var mesh_instance : MeshInstance
var col_shape : CollisionShape
var surfaces : int

func _ready():
	mesh_instance = get_node(mesh_instance_name)
	col_shape = get_node(collision_shape_name)
	surfaces = mesh_instance.mesh.get_surface_count()
	iterate_set_surfaces()

func iterate_set_surfaces():
	if materials.size() == material_names.size():
		for i in range (0, materials.size()):
			set_material_in_mesh(i)
	else:
		printerr("materials and material_names arrays must be the same size!")

func set_material_in_mesh(idx : int):
	for surface in surfaces:
		var nam := mesh_instance.mesh.surface_get_material(surface).resource_name
		if nam == material_names[idx]:
			mesh_instance.mesh.surface_set_material(surface, materials[idx])
		else:
			if debug:
				if !(nam in material_names):
					print(nam)
