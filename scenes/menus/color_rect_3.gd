# Put this script onto the ColorRect you're using to display the CRT effect
extends Control

# The SubViewport that will be rendered onto the CRT
@export var subviewport_node: SubViewport

# The default mouse filter for a ColorRect (stop) will stop this script from
# working, and it needs to be set to pass or ignore (both work).
# You can also just set this yourself and remove this function.
func _ready():
	var mat := material as ShaderMaterial   # or get_active_material(0), material_override, etc.
	mat.set_shader_parameter("tex", $"../SubViewport".get_texture())
	$"../SubViewport".render_target_update_mode = SubViewport.UPDATE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_PASS

func _process(_delta: float) -> void:
	var mat := material as ShaderMaterial
	mat.set_shader_parameter("tex", $"../SubViewport".get_texture())

func _unhandled_input(event: InputEvent):
	
	if event is InputEventMouse:
		
		# Remap the coorinates of a mouse event to be at an apropriate point
		event.position -= position
		event.position *= Vector2(Vector2(subviewport_node.size) / size)
	
	subviewport_node.push_input(event)
