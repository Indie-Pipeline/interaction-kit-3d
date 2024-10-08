class_name PluginUtilities

static func is_mouse_left_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed


static func is_mouse_right_click(event: InputEvent) -> bool:
	return event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed


static func is_mouse_visible() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_VISIBLE || Input.mouse_mode == Input.MOUSE_MODE_CONFINED


static func action_just_pressed_and_exists(action: String) -> bool:
	return InputMap.has_action(action) and Input.is_action_just_pressed(action)


static func action_pressed_and_exists(action: String, event: InputEvent = null) -> bool:
	return InputMap.has_action(action) and event.is_action_pressed(action) if event else Input.is_action_pressed(action)


static func global_distance_to_v3(a: Node3D, b: Node3D) -> float:
	return a.global_position.distance_to(b.global_position)


static func generate_3d_random_fixed_direction() -> Vector3:
	return Vector3(randi_range(-1, 1), randi_range(-1, 1), randi_range(-1, 1)).normalized()


static func rotate_horizontal_random(origin: Vector3 = Vector3.ONE) -> Vector3:
	var arc_direction: Vector3 = [Vector3.DOWN, Vector3.UP].pick_random()
	
	return origin.rotated(arc_direction, randf_range(-PI / 2, PI / 2))


## Only works for native custom class not for GDScriptNativeClass
## Example NodePositioner.find_nodes_of_custom_class(self, MachineState)
static func find_nodes_of_custom_class(node: Node, class_to_find: Variant) -> Array:
	var  result := []
	
	var childrens = node.get_children(true)

	for child in childrens:
		if child.get_script() == class_to_find:
			result.append(child)
		else:
			result.append_array(find_nodes_of_custom_class(child, class_to_find))
	
	return result


static func is_valid_url(url: String) -> bool:
	var regex = RegEx.new()
	var url_pattern = "/(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?\\/[a-zA-Z0-9]{2,}|((https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?)|(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}(\\.[a-zA-Z0-9]{2,})?/g"
	regex.compile(url_pattern)
	
	return regex.search(url) != null


static func filepath_is_valid(path: String):
	return not path.is_empty() and path.is_absolute_path() and ResourceLoader.exists(path)


static func dirpath_is_valid(path: String):
	return not path.is_empty() and path.is_absolute_path() and DirAccess.dir_exists_absolute(path)


static func directory_exist_on_executable_path(directory_path: String) -> Error:
	var real_path = OS.get_executable_path().get_base_dir().path_join(directory_path)
	var directory = DirAccess.open(real_path)
	
	if directory == null:
		return DirAccess.get_open_error()
	
	return OK
	
## Supports RegEx expressions
static func get_files_recursive(path: String, regex: RegEx = null) -> Array:
	var files = []
	var directory = DirAccess.open(path)
	
	if directory:
		directory.list_dir_begin()
		var file := directory.get_next()
		
		while file != "":
			if directory.current_is_dir():
				files += get_files_recursive(directory.get_current_dir().path_join(file), regex)
			else:
				var file_path = directory.get_current_dir().path_join(file)
				
				if regex != null:
					if regex.search(file_path):
						files.append(file_path)
				else:
					files.append(file_path)
					
			file = directory.get_next()
			
		return files
	else:
		push_error("PluginUtilities->get_files_recursive: An error %s occured when trying to open directory: %s" % [DirAccess.get_open_error(), path])
		
		return []


static func copy_directory_recursive(from_dir :String, to_dir :String) -> bool:
	if not DirAccess.dir_exists_absolute(from_dir):
		push_error("PluginUtilities->copy_directory_recursive: directory not found '%s'" % from_dir)
		return false
		
	if not DirAccess.dir_exists_absolute(to_dir):
		
		var err := DirAccess.make_dir_recursive_absolute(to_dir)
		if err != OK:
			push_error("PluginUtilities->copy_directory_recursive: Can't create directory '%s'. Error: %s" % [to_dir, error_string(err)])
			return false
			
	var source_dir := DirAccess.open(from_dir)
	var dest_dir := DirAccess.open(to_dir)
	
	if source_dir != null:
		source_dir.list_dir_begin()
		var next := "."

		while next != "":
			next = source_dir.get_next()
			if next == "" or next == "." or next == "..":
				continue
			var source := source_dir.get_current_dir() + "/" + next
			var dest := dest_dir.get_current_dir() + "/" + next
			
			if source_dir.current_is_dir():
				copy_directory_recursive(source + "/", dest)
				continue
				
			var err := source_dir.copy(source, dest)
			
			if err != OK:
				push_error("PluginUtilities->copy_directory_recursive: Error checked copy file '%s' to '%s'" % [source, dest])
				return false
				
		return true
	else:
		push_error("PluginUtilities->copy_directory_recursive: Directory not found: " + from_dir)
		return false


static func remove_files_recursive(path: String, regex: RegEx = null) -> void:
	var directory = DirAccess.open(path)
	
	if DirAccess.get_open_error() == OK:
		directory.list_dir_begin()
		
		var file_name = directory.get_next()
		
		while file_name != "":
			if directory.current_is_dir():
				remove_files_recursive(directory.get_current_dir().path_join(file_name), regex)
			else:
				if regex != null:
					if regex.search(file_name):
						directory.remove(file_name)
				else:
					directory.remove(file_name)
					
			file_name = directory.get_next()
		
		directory.remove(path)
	else:
		push_error("PluginUtilities->remove_recursive: An error %s happened open directory: %s " % [DirAccess.get_open_error(), path])
