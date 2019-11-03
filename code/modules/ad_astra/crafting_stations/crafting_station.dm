/obj/machinery/crafting_station
	name = "crafting station"
	desc = "A crafting station of some kind."
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	density = 1

	var/active_state //active icon state

	var/required_skill = SKILL_HAULING //what skill do we require - athletics used as a base type.
	var/min_skill_level = SKILL_NONE //minimum skill level to use this crafting station.
	var/base_work_speed = 10 SECONDS //how long it takes to do something, modified by amount and skill and the thing we're working on.
	var/skill_time_modifier = 1.5 //How much does being skilled decrease the time required to do an operation?
	var/work_sound //what sound do we play when someone starts working with us?
	var/maximum_material = 30000 //how much material can we hold?
	var/skill_level_insufficent_message = "You have no idea how to use this."
	var/working = FALSE //are we doing something, right now?

	var/crafting_type = /datum/crafting_type

	var/list/craftables = list() //Generated on Init from crafting_type var.
	var/list/materials = list() //our materials.
	var/list/known_blueprint_packages = list() //What blueprints do we know?

	var/global/list/stored_substances_to_names = list()
	var/list/storage_capacity = list()
	var/list/base_storage_capacity = list(
		/material/steel =     30000,
		/material/aluminium = 30000,
		/material/glass =     30000,
		/material/plastic =   30000
	)

/obj/machinery/crafting_station/Initialize()
	create_reagents(120)

	materials = list()
	for(var/mat in base_storage_capacity)
		materials[mat] = 0

		// Update global type to string cache.
		if(!stored_substances_to_names[mat])
			if(ispath(mat, /material))
				var/material/mat_instance = mat
				mat_instance = SSmaterials.get_material_by_name(initial(mat_instance.name))
				if(istype(mat_instance))
					stored_substances_to_names[mat] = mat_instance.display_name
			else if(ispath(mat, /datum/reagent))
				var/datum/reagent/reg = mat
				stored_substances_to_names[mat] = initial(reg.name)

	storage_capacity = list()
	for(var/mat in base_storage_capacity)
		storage_capacity[mat] = base_storage_capacity[mat]

	for(var/type in subtypesof(crafting_type))
		craftables += new type
	..()

/obj/machinery/crafting_station/attack_hand(var/mob/user)
	var/user_skill_level = user.get_skill_value(required_skill)
	if(user_skill_level < min_skill_level)
		to_chat(user, SPAN_NOTICE("[skill_level_insufficent_message]"))
		return
	ui_interact(user)

/obj/machinery/crafting_station/proc/CheckBlueprintPackage(var/datum/crafting_type/C)
	if(!C.required_blueprint) // no required blueprint - return true.
		return TRUE
	var/req_blueprint_package = C.required_blueprint

	if(!req_blueprint_package in known_blueprint_packages)
		return FALSE
	else
		return TRUE

/obj/machinery/crafting_station/proc/is_functioning()
	. = use_power != POWER_USE_OFF && !(stat & NOPOWER) && !(stat & BROKEN)

/obj/machinery/crafting_station/proc/DoMake(var/datum/crafting_type/recipe, mob/user)
	var/multiplier = 1
	var/multicrafting
	var/multicraft_amount
	if(working)
		to_chat(user, SPAN_NOTICE("The station is already working on something!"))
		return
	working = TRUE //we're doing something, right now.
	var/list/answers = list("Yes", "No")
	var/multicraft = input("Do you wish to make more than one item?", "Multicrafting") as null|anything in answers
	if(multicraft == "Yes")
		multicraft_amount = input("How many do you wish to make? (Max: 10)", "Multicrafting") as null|num
		multicrafting = TRUE
	//fun times begin now.
	var/crafting_time = (base_work_speed + recipe.extra_crafting_time) / (skill_time_modifier * user.get_skill_value(required_skill))
	if(multicrafting)
		crafting_time = (crafting_time * multicraft_amount) * 0.8 //multicrafting gets slight speed bonus.
		multiplier = multicraft_amount
		multicraft_amount = Clamp(multicraft_amount, 1, 10)
	if(!do_after(user, crafting_time, src))
		to_chat(user, SPAN_NOTICE("You decide not to work on [src]."))
		return
	else
		//sanity checks, first.
		for(var/material in recipe.required_materials)
			if(materials[material] < round((recipe.required_materials[material] * multiplier)))
				to_chat(user, SPAN_WARNING("It seems you are out of [stored_substances_to_names[material]]."))
				working = FALSE
				return
		//we have the materials - at this point, skills and schematics have already been checked by the ui code - subtract resources and actually spit the damn thing out.
		for(var/material in recipe.required_materials)
			var/removed_mat = round((recipe.required_materials[material] * multiplier))
			materials[material] = max(0, materials[material] - removed_mat)
		if(multicrafting)
			for(var/A = 0 to multicraft_amount)
				new recipe.item_to_spawn(get_turf(src))
		if(!multicrafting)
			new recipe.item_to_spawn(get_turf(src))
		to_chat(user, SPAN_NOTICE("You finish crafting ["a" ? "a few of" : multicrafting] [recipe.name]."))
		working = FALSE

/obj/machinery/crafting_station/ui_interact(mob/user, ui_key = "rcon", datum/nanoui/ui=null, force_open=1)
	var/list/data = list()

	data["functional"] = is_functioning()

	if(is_functioning())
		var/current_storage =  list()
		data["material_storage"] =  current_storage
		for(var/material in materials)
			var/list/material_data = list()
			var/mat_name = capitalize(stored_substances_to_names[material])
			material_data["name"] =        mat_name
			material_data["stored"] =      materials[material]
			material_data["max"] =         storage_capacity[material]
			material_data["eject_key"] = stored_substances_to_names[material]
			material_data["eject_label"] =   ispath(material, /material) ? "Remove" : "Flush"
			data["material_storage"] |= list(material_data)

		data["build_options"] = list()
		data["build_options"][++data["build_options"].len] = get_buildable(user)
	if (!ui)
		ui = new(user, src, ui_key, "crafting_station.tmpl", "[capitalize(name)]", 480, 410, state = GLOB.physical_state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/crafting_station/proc/get_buildable(mob/user)
	var/list/build_options = list()
	for(var/datum/crafting_type/R in craftables)
		var/list/build_option = list()
		var/max_sheets = 0
		build_option["name"] = R.name
		build_option["reference"] = "\ref[R]"
		if(!CheckBlueprintPackage(R))
			build_option["noschematic"] = 1
			build_option["cantbuild"] = 1
		if(!user.skill_check_multiple(R.skills_required))
			build_option["missingskills"] = 1
			build_option["cantbuild"] = 1
		var/list/material_components = list()
		for(var/material in R.required_materials)
			var/sheets = round(materials[material]/round(R.required_materials[material]))
			if(isnull(max_sheets) || max_sheets > sheets)
				max_sheets = sheets
			if(materials[material] < round(R.required_materials[material]))
				build_option["unavailable"] = 1
				build_option["cantbuild"] = 1
			var/matcomps = stored_substances_to_names[material]
			material_components += "[R.required_materials[material]] [matcomps]"
			build_option["cost"] = "[capitalize(jointext(material_components, ", "))]."
		build_options += build_option
	return build_options