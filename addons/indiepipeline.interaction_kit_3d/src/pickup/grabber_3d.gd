class_name Grabber3D extends Node3D

class ActiveGrabbable extends RefCounted:
	func _init(_grabbable: Grabbable3D, _slot: Node3D):
		body = _grabbable
		slot = _slot
		
	var body: Grabbable3D
	var slot: Node3D
	
	
signal pulled_grabbable(body: Grabbable3D)
signal throwed_grabbable(body: Grabbable3D)
signal dropped_grabbable(body: Grabbable3D)

## The available slots to put the grabbables when pulled
@export var available_slots: Array[Marker3D] = []
## The maximum mass from bodies this grabber can hold
@export var mass_lift_force: float = 10.0
## The maximum number of grabbables this grabber can hold at the same time, this takes priority over available_slots
@export var max_number_of_grabbables: int = 1
@export_group("Input Actions")
@export var pull_input_action: String = "pull"
@export var pull_area_input_action: String = "pull_area"
@export var drop_input_action: String = "drop"
@export var throw_input_action: String = "throw"
@export var push_wave_input_action: String = "push_wave"
@export_group("Abilities")
@export var pull_individual_ability: bool = true
@export var pull_area_ability: bool = false
@export var push_wave_ability: bool = false
@export_group("Interactor")
## The raycast that interacts with grabbables to detect them
@export var grabbable_interactor: GrabbableRayCastInteractor
## The current distance applied to the interactor instead of manually change it on raycast properties
@export_range(0.1, 100.0, 0.01) var grabbable_interactor_distance = 6.0:
	set(value):
		if grabbable_interactor is GrabbableRayCastInteractor and grabbable_interactor_distance != value:
			grabbable_interactor_distance = clamp(value, 0.1, 1000.0)
			_prepare_grabbable_interactor(grabbable_interactor, grabbable_interactor_distance)
			
@export_group("Area detector")
@export var grabbable_area_detector: Area3D:
	set(value):
		grabbable_area_detector = value
		
		if grabbable_area_detector is Area3D:
			_prepare_grabbable_area_detector(grabbable_area_detector)
			
	
var active_grabbables: Array[ActiveGrabbable] = []



#region Slot related
func slots_available() -> bool:
	return available_slots.size() > 0 and active_grabbables.size() != available_slots.size()
	

func get_random_free_slot() -> Marker3D:
	if not slots_available():
		return null
	
	var busy_slots := active_grabbables.map(
			func(active_grabbable: ActiveGrabbable): return active_grabbable.slot
		)
	
	return available_slots.filter(func(slot: Marker3D): return not slot in busy_slots ).pick_random()


func _prepare_available_slots():
	if available_slots.is_empty():
		for child in get_children():
			if child is Marker3D:
				available_slots.append(child)

#endregion	


func _prepare_grabbable_interactor(interactor: GrabbableRayCastInteractor, distance: float = grabbable_interactor_distance):
	interactor.target_position = Vector3.FORWARD * distance


func _prepare_grabbable_area_detector(area_detector: GrabbableAreaDetector3D):
	area_detector.monitorable = false
	area_detector.monitoring = true
	area_detector.priority = 2
	area_detector.collision_layer = 0
	area_detector.collision_mask = ProjectSettings.get_setting(MyPluginSettings.GrabbablesCollisionLayerSetting)
