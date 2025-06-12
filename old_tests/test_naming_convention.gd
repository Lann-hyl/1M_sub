extends GutTest
## Test that all art files are named following the convention

const ART_DIR_PATH: String = "res://Art/"
var line_regex: String = r'.*;'
var inside_regex: String = r'<([\w?\/]*)>'
# if you don't understand the regex
# check https://regex101.com/r/hJwsib/1 with test string "Background : <area_number>-<number> ;"
var naming_convention_path: String = "res://Art/naming_convention.txt"


func after_each() -> void:
	assert_no_new_orphans("Orphans still exist, please free up test resources.")


func _filter_import(file_list: PackedStringArray) -> PackedStringArray:
	var filtered_files: PackedStringArray = PackedStringArray()
	for file: String in file_list:
		if not file.ends_with(".import"):
			filtered_files.append(file)
	return filtered_files


func _get_filtered_files(sub_dir_name: String) -> PackedStringArray:
	var full_dir_path: String = ART_DIR_PATH + sub_dir_name
	if not DirAccess.dir_exists_absolute(full_dir_path):
		fail_test("Subdirectory " + full_dir_path + " does not exist")
	var sub_dir: DirAccess = DirAccess.open(full_dir_path)
	var all_files: PackedStringArray = sub_dir.get_files()
	return _filter_import(all_files)
	

func _get_associated_convention(directory_name: String, text_to_search: String) -> PackedStringArray:
	var regex: RegEx = RegEx.new()
	regex.compile("(" + directory_name + line_regex + ")")
	var line_text: String = regex.search(text_to_search).get_string()
	regex.compile(inside_regex)
	var inside_match: Array[RegExMatch] = regex.search_all(line_text)
	var inside_match_text: PackedStringArray = PackedStringArray()
	for reg_match: RegExMatch in inside_match:
		inside_match_text.append(reg_match.get_string(1))
	return inside_match_text
	

func _parse_file_name(file_name: String) -> PackedStringArray:
	var file_name_without_extension: String = file_name.split(".")[0]
	var parsed_file_name: PackedStringArray = file_name_without_extension.split("-")
	return parsed_file_name
	

func _test_type_of_field(field: String, convention: String) -> bool:
	if "number" in convention or "frame" == convention:
		return field.is_valid_int()
	elif "type" in convention:
		var possible_types: PackedStringArray = convention.split("?")[1].split("/")
		return field in possible_types
	else:
		var regex: RegEx = RegEx.new()
		regex.compile(r'\w*')
		# ensure that the field is only composed of letters or underscore
		return regex.search(field).get_string() == field
		
		
func _test_type_of_all_fields(parsed_file_name: PackedStringArray, associated_convention: PackedStringArray) -> bool:
	var name_is_correct: bool = true
	# we check previously that we have the expected number of fields so the two lists are the same size
	for i: int in parsed_file_name.size():
		name_is_correct = name_is_correct and _test_type_of_field(parsed_file_name[i], associated_convention[i])
	return name_is_correct
		
		
		

func test_all_dirs() -> void:
	if not DirAccess.dir_exists_absolute(ART_DIR_PATH):
		fail_test("Art directory does not exist")
	
	var convention_file_text: String = FileAccess.open(naming_convention_path, FileAccess.READ).get_as_text()
	var dir: DirAccess = DirAccess.open(ART_DIR_PATH)
	var dir_list: PackedStringArray = dir.get_directories()
	for sub_dir_name: String in dir_list:
		var filtered_files: PackedStringArray = _get_filtered_files(sub_dir_name)
		var associated_convention: PackedStringArray = _get_associated_convention(sub_dir_name, convention_file_text)
		var expected_number_of_fields: int = associated_convention.size()
		for file_name: String in filtered_files:
			assert_false(" " in file_name, file_name + " contains one or more spaces")
			var parsed_file_name: PackedStringArray = _parse_file_name(file_name)
			assert_eq(expected_number_of_fields, parsed_file_name.size(), file_name + " does not have the expected number of fields")
			assert_true(_test_type_of_all_fields(parsed_file_name, associated_convention), file_name + " does not match the naming convention")		

