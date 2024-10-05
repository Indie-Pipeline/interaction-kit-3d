class_name Interactable3D extends Area3D

const GroupName = "interactables-3d"

signal interacted()
signal canceled_interaction()
signal focused()
signal unfocused()
signal interaction_limit_reached()

@export var activate_on_start: bool = true
@export var number_of_times_can_be_interacted: int = 0
@export var change_cursor: bool = true
@export var change_screen_pointer: bool = true
@export var lock_player_on_interact: bool = false
@export_group("Information")
@export var title: String = ""
@export var description: String = ""
@export var title_translation_key: String = ""
@export var description_translation_key: String = ""
@export_group("Scan")
@export var scannable: bool = false
@export var can_be_rotated_on_scan: bool = true
@export var target_scannable_object: Node3D
@export_group("Screen pointers")
@export var focus_screen_pointer: CompressedTexture2D
@export var interact_screen_pointer: CompressedTexture2D
@export_group("Cursors")
@export var focus_cursor: CompressedTexture2D
@export var interact_cursor: CompressedTexture2D
@export var scan_rotate_cursor: CompressedTexture2D

var can_be_interacted: bool = true
var times_interacted: int = 0:
	set(value):
		var previous_value = times_interacted
		times_interacted = value
		
		if previous_value != times_interacted && times_interacted >= number_of_times_can_be_interacted:
			interaction_limit_reached.emit()
			deactivate()


func _enter_tree() -> void:
	add_to_group(GroupName)


func _ready() -> void:
	if activate_on_start:
		activate()
	
	
func activate() -> void:
	priority = 3
	collision_layer = ProjectSettings.get_setting(MyPluginSettings.InteractablesCollisionLayerSetting)
	collision_mask = 0
	monitorable = true
	monitoring = false
	
	can_be_interacted = true
	times_interacted = 0
	
	
func deactivate() -> void:
	priority = 0
	collision_layer = 0
	monitorable = false
	
	can_be_interacted = false
