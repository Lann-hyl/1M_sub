extends Node2D

@onready var anim_in: AnimationPlayer = $AnimationPlayerIn
@onready var anim_out: AnimationPlayer = $AnimationPlayerOut
@onready var name_role_label: Label = $Background/CenterContainer/Label
@onready var black_overlay: TextureRect = $BlackOverlay

const CENTER_SCREEN_TIME: float = 2
const TEXT_FADE_IN_DURATION: float = 0.2
const TEXT_FADE_OUT_DURATION: float = 0.2
const COLOR_FADE_OUT: Color = Color(0,0,0,0)
const COLOR_FADE_IN: Color = Color(0,0,0,1)
const TIME_SCALING_TEXT_LENGTH: float = 0.05

signal animation_ended

## All the possible team roles
enum Roles {
	Art,
	Design,
	Music,
	Programming,
	Testing,
	Writing,
	Special_thanks,
	Team_lead_design,
	Team_lead_music,
	Team_lead_programming,
	Team_lead_writing,
	Project_lead,
}

## Re-export of the global enum variable to type a shorter name
const sapling_type: GlobalEnums.SaplingType = GlobalEnums.SaplingType

## All the team members, their roles and their avatar
const TEAM_MEMBERS: Dictionary = {
	"Adrian": [[Roles.Team_lead_music], sapling_type.Old],
	"Ago": [[Roles.Art], sapling_type.Maid],
	"Akatsukin": [[Roles.Design], sapling_type.Nerd],
	"Amamii": [[Roles.Art], sapling_type.Maid],
	"Arkhand": [[Roles.Music], sapling_type.Nerd],
	"Atmama": [[Roles.Art], sapling_type.None],
	"Biosquid": [[Roles.Programming], sapling_type.None],
	"Bishop": [[Roles.Programming], sapling_type.None],
	"Cheesyfrycook": [[Roles.Programming], sapling_type.None],
	"Dat": [[Roles.Art], sapling_type.None],
	"Dio": [[Roles.Art], sapling_type.Sleepy],
	"EndyStarBoy": [[Roles.Art], sapling_type.Milf],
	"Hakase": [[Roles.Art], sapling_type.None],
	"Jimance": [[Roles.Team_lead_writing, Roles.Design], sapling_type.Old],
	"Jona": [[Roles.Programming], sapling_type.Gamer],
	"Jusagi": [[Roles.Art], sapling_type.Cool],
	"Kebbie": [[Roles.Special_thanks], sapling_type.None],
	"Kotoschneep": [[Roles.Art], sapling_type.None],
	"Lann": [[Roles.Programming], sapling_type.Nerd],
	"Lunar": [[Roles.Art], sapling_type.Gamer],
	"Mikotey": [[Roles.Design], sapling_type.Maid],
	"Minik": [[Roles.Design], sapling_type.Emo],
	"Multi-arm": [[Roles.Programming], sapling_type.None],
	"nára": [[Roles.Art], sapling_type.Emo],
	"Palenque": [[Roles.Design], sapling_type.Nerd],
	"Papier": [[Roles.Programming], sapling_type.Milf],
	"Pterion": [[Roles.Art, Roles.Design], sapling_type.Maid],
	"ROBBERGON": [[Roles.Team_lead_design], sapling_type.Snow],
	"Saphu": [[Roles.Art, Roles.Design], sapling_type.Sleepy],
	"Sappysque": [[Roles.Art], sapling_type.Emo],
	"Tomzkk": [[Roles.Programming, Roles.Design], sapling_type.Old],
	"Tradgore": [[Roles.Writing, Roles.Design], sapling_type.Sleepy],
	"Turtyo": [[Roles.Project_lead, Roles.Team_lead_programming, Roles.Design], sapling_type.Gamer],
	"TyTy": [[Roles.Programming], sapling_type.Old],
	"Vyto (Vytonium)": [[Roles.Music], sapling_type.Old],
	"Walles": [[Roles.Design], sapling_type.Sleepy],
	"Zannmaster": [[Roles.Design], sapling_type.Milf],
}

## The time needed for an animation to reach the center of the screen [br]
## This is especially useful for animations that are very fast and we need to delay them [br]
## This lets the previous animation time to get out of the screen center
const ANIMATION_TIME_TO_SCREEN_CENTER: Dictionary = {
	"In/cool_in_1": 2.3,
	"In/emo_in_1": 0, #enters by the left, will need to wait for previous out animation to completely finish
	"In/gamer_in_1": 1.5,
	"In/maid_in_1": 0.7,
	"In/milf_in_1": 2.6,
	"In/nerd_in_1": 1.7,
	"In/old_in_1": 1.5,
	"In/sleepy_in_1": 0.4,
	"In/snow_in_1": 0.4,
}

## Time needed for an animation to free the space at the center of the screen [br]
## Delay the previous animation by this duration if the time it takes to reach the center is smaller
## than the time it takes the "out" animation to free the screen center
const ANIMATION_TIME_OUT_SCREEN_CENTER: Dictionary = {
	"Out/cool_out_1": 1,
	"Out/emo_out_1": 2.1,
	"Out/gamer_out_1": 1.3,
	"Out/maid_out_1": 0.5,
	"Out/milf_out_1": 0.6,
	"Out/nerd_out_1": 0.7,
	"Out/old_out_1": 0.9,
	"Out/sleepy_out_1": 2.2,
	"Out/snow_out_1": 1.1,
}

## Launch the loop of the scene
func _ready() -> void:
	# start by setting up various things
	black_overlay.modulate.a = 0
	name_role_label.text = ""
	name_role_label.add_theme_color_override("font_color", COLOR_FADE_OUT)
	_animation_loop()
	
	await animation_ended
	
	# fade to black and go to next scene
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(black_overlay, "modulate:a", 1, 3)
	
	await tween.finished
	
	SceneManager.goto_scene("res://#Scenes/credits_extra.tscn")
	
	

## The main animation loop, controls the entry timing of all the saplings [br]
## This is done by controling the two animation player of the scene
func _animation_loop() -> void:
	# a little timer to start the scene
	var timer: SceneTreeTimer = get_tree().create_timer(1)
	var team_members_names: Array = _choose_member_order()

	await timer.timeout
	
	# play first animation with animation player in
	# this is needed since the loop also plays the out animation of the previous avatar
	# but there is no previous avatar before the first one
	var first_member_name: String = team_members_names[0]
	var roles_and_avatar: Array = TEAM_MEMBERS[first_member_name]
	var roles: Array = roles_and_avatar[0]
	var roles_string: String = _role_array_to_string(roles)
	var previous_avatar: GlobalEnums.SaplingType = roles_and_avatar[1]
	# randomly select an avatar type for those that don't have one
	# change to defaulting to MILF later
	if previous_avatar == sapling_type.None :
		previous_avatar = _default_avatar()
	var animation_name: String = _choose_animation(previous_avatar, true)
	anim_in.play(animation_name)
	await anim_in.animation_finished
	# member is now at the center of the screen, display their name + roles with a fade in of the text
	name_role_label.text = first_member_name + "\n" + roles_string
	var text_time_on_screen: float = _get_text_time_on_screen(name_role_label.text)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(name_role_label, "theme_override_colors/font_color", COLOR_FADE_IN, TEXT_FADE_IN_DURATION)
	await get_tree().create_timer(text_time_on_screen).timeout
	
	var out_animation: String
	
	# now loop on all the remaining members
	for member_name: String in team_members_names.slice(1):
		out_animation = _choose_animation(previous_avatar, false)
		var in_tween: Tween = get_tree().create_tween()
		# fade out the text above avatar head
		in_tween.tween_property(name_role_label, "theme_override_colors/font_color", COLOR_FADE_OUT, TEXT_FADE_OUT_DURATION)
		await in_tween.finished
		anim_out.play(out_animation)
		name_role_label.text = ""
		# reset position of the IN avatar
		# the sprite for the out animation is different from the sprite of the IN
		# when starting the out animation, if we don't reset the IN sprite it would stay at the center of the screen
		anim_in.play("RESET")
		# prepare for the next member to go in
		roles_and_avatar = TEAM_MEMBERS[member_name]
		var new_roles: Array = roles_and_avatar[0]
		var new_avatar: GlobalEnums.SaplingType = roles_and_avatar[1]
		var new_roles_string: String = _role_array_to_string(new_roles)
		if new_avatar == sapling_type.None :
			new_avatar = _default_avatar()
		var in_animation: String = _choose_animation(new_avatar, true)
		# the signal to wait before launching the next IN animation
		# depends on the type of the previous / next avatar
		var in_signal: Signal
		# special rule for the emo sapling since it enters from the left
		# so we need to wait for the out animation to finish
		if new_avatar == sapling_type.Emo or previous_avatar == sapling_type.Emo:
			in_signal = anim_out.animation_finished
		else:
			# the time it takes for the sprite in the center of the screen to leave it
			var time_center_out: float = ANIMATION_TIME_OUT_SCREEN_CENTER[out_animation]
			# the time it takes for the animation going in to reach the center of the screen
			var time_center_in: float = ANIMATION_TIME_TO_SCREEN_CENTER[in_animation]
			# calculate the time to leave between entry and exit to prevent sprites going into each other
			# if the animation going in is slower than the animation going out, it can start directly (thus 0)
			var time_difference: float = max (0, time_center_out - time_center_in)
			in_signal = get_tree().create_timer(time_difference).timeout
		await in_signal
		anim_in.play(in_animation)
		
		await anim_in.animation_finished
		# display the name + roles of the sprite that just got to the center of the screen
		var out_tween: Tween = get_tree().create_tween()
		name_role_label.text = member_name + "\n" + new_roles_string
		text_time_on_screen = _get_text_time_on_screen(name_role_label.text)
		out_tween.tween_property(name_role_label, "theme_override_colors/font_color", COLOR_FADE_IN, TEXT_FADE_IN_DURATION)
		await get_tree().create_timer(text_time_on_screen).timeout
		# the one at the center of the screen is now the one going out for the next loop (thus becoming the previous_avatar)
		previous_avatar = new_avatar
		
	# play the last out animation separately (since unlike the loop, there is no other IN to play after)
	out_animation = _choose_animation(previous_avatar, false)
	var last_tween: Tween = get_tree().create_tween()
	last_tween.tween_property(name_role_label, "theme_override_colors/font_color", COLOR_FADE_OUT, TEXT_FADE_OUT_DURATION)
	await last_tween.finished
	name_role_label.text = ""
	anim_out.play(out_animation)
	# put back the sprite for the animation going in, out of the screen
	anim_in.play("RESET")
	
	await anim_out.animation_finished
	animation_ended.emit()
		


## What to give the people that don't have an avatar
func _default_avatar() -> GlobalEnums.SaplingType:
	#var avatar: GlobalEnums.SaplingType
	#var sapling_type_values: Array = GlobalEnums.SaplingType.values()
	#while avatar == sapling_type.None :
			#avatar = sapling_type_values[randi() % sapling_type_values.size()]
	return GlobalEnums.SaplingType.Milf
	

## Choose the order in which the members should appear [br]
## The order is the following: [br]
## - each category in alphabetical order [br]
## - order inside a given category is random
func _choose_member_order() -> Array:
	var team_members_names: Array = TEAM_MEMBERS.keys()
	var teams: Dictionary = {
		Roles.Art: [],
		Roles.Design: [],
		Roles.Music: [],
		Roles.Programming: [],
		Roles.Testing: [],
		Roles.Writing: [],
		Roles.Special_thanks: [],
	}
	for member_name: String in team_members_names:
		var member_roles: Array = TEAM_MEMBERS[member_name][0]
		
		var team_to_add: Roles
		# check if each role is one of the member role
		# doing it this way instead of iterating over member roles ensures that the order for roles is always the same
		# even if the order is different for individual members
		for role: Roles in Roles.values():
			if role in member_roles:
				match role:
					Roles.Design:
						# only add to team Design if it's the only role
						if member_roles.size() == 1:
							team_to_add = role
							break
					Roles.Team_lead_design:
						team_to_add = Roles.Design
						break
					Roles.Team_lead_music:
						team_to_add = Roles.Music
						break
					Roles.Team_lead_programming:
						team_to_add = Roles.Programming
						break
					Roles.Team_lead_writing:
						team_to_add = Roles.Writing
						break
					_:
						# for everyone else, their respective roles
							team_to_add = role
							break
		teams[team_to_add].append(member_name)
	# shuffle inside each team
	for team: Roles in teams:
		teams[team].shuffle()
	var final_list: Array = []
	for sub_team: Array in teams.values():
		final_list.append_array(sub_team)
	return final_list
		
## Choose the animation for a given sapling type [br]
## Mainly useful if there are multiple possible animations
func _choose_animation(avatar: GlobalEnums.SaplingType, is_in: bool) -> String:
	var avatar_name: String = GlobalEnums.SaplingType.keys()[avatar].to_lower()
	var animations_list: Array
	if is_in:
		animations_list = ANIMATION_TIME_TO_SCREEN_CENTER.keys()
	else:
		animations_list = ANIMATION_TIME_OUT_SCREEN_CENTER.keys()
	var animation_for_avatar: Array = animations_list.filter(
			func(list_name: String) -> bool: 
				return avatar_name in list_name
	)
	var chosen_animation: String = animation_for_avatar[randi() % animation_for_avatar.size()]
	return chosen_animation
	
## Convert the list of roles of a member to the screen to be displayed for those roles
func _role_array_to_string(roles: Array) -> String:
	var all_roles_string: PackedStringArray = []
	for role: Roles in roles:
		all_roles_string.append(_role_to_string(role))
	if roles.size() <= 2:
		return ", ".join(all_roles_string)
	else:
		return ", ".join(all_roles_string.slice(0, 2)) + "\n" + ", ".join(all_roles_string.slice(2))


## Convert a role to a string
func _role_to_string(role: Roles) -> String:
	return Roles.keys()[role].replace("_", " ") 
	

## Calculate the time a string should be displayed on screen
func _get_text_time_on_screen(text: String) -> float:
	return CENTER_SCREEN_TIME + text.length() * TIME_SCALING_TEXT_LENGTH
