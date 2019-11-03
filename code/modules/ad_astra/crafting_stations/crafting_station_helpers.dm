//largely yoinked from Fabricator code, because hey, it's there.

#define SUBSTANCE_TAKEN_NONE -1
#define SUBSTANCE_TAKEN_SOME  0
#define SUBSTANCE_TAKEN_FULL  1
#define SUBSTANCE_TAKEN_ALL   2

/obj/machinery/crafting_station/proc/take_reagents(var/obj/item/thing, var/mob/user, var/destructive = FALSE)
	if(!thing.reagents || (!destructive && !thing.is_open_container()))
		return SUBSTANCE_TAKEN_NONE
	for(var/datum/reagent/R in thing.reagents.reagent_list)
		if(!base_storage_capacity[R.type])
			continue
		var/taking_reagent = min(R.volume, storage_capacity[R.type] - materials[R.type])
		if(taking_reagent <= 0)
			continue
		thing.reagents.remove_reagent(R.type, taking_reagent)
		materials[R.type] += taking_reagent
		if(materials[R.type] == storage_capacity[R.type])
			return SUBSTANCE_TAKEN_FULL
		else if(thing.reagents.total_volume > 0)
			return SUBSTANCE_TAKEN_SOME
		else
			return SUBSTANCE_TAKEN_ALL
	return SUBSTANCE_TAKEN_NONE

/obj/machinery/crafting_station/proc/take_materials(var/obj/item/thing, var/mob/user)
	. = SUBSTANCE_TAKEN_NONE
	var/stacks_used = 1
	for(var/mat in thing.matter)
		var/material/material_def = SSmaterials.get_material_by_name(mat)
		if(!material_def || !base_storage_capacity[material_def.type])
			continue
		var/taking_material = min(thing.matter[mat], storage_capacity[material_def.type] - materials[material_def.type])
		if(taking_material <= 0)
			continue
		materials[material_def.type] += taking_material
		stacks_used = max(stacks_used, ceil(taking_material/material_def.units_per_sheet))
		if(storage_capacity[material_def.type] == materials[material_def.type])
			. = SUBSTANCE_TAKEN_FULL
		else if(. != SUBSTANCE_TAKEN_FULL)
			. = SUBSTANCE_TAKEN_ALL
	if(. != SUBSTANCE_TAKEN_NONE)
		if(istype(thing, /obj/item/stack))
			var/obj/item/stack/S = thing
			S.use(stacks_used)
			if(S.amount <= 0 || QDELETED(S))
				. = SUBSTANCE_TAKEN_ALL
			else if(. != SUBSTANCE_TAKEN_FULL)
				. = SUBSTANCE_TAKEN_SOME

/obj/machinery/crafting_station/proc/show_intake_message(var/mob/user, var/value, var/obj/item/thing)
	if(value == SUBSTANCE_TAKEN_FULL)
		to_chat(user, SPAN_NOTICE("You fill \the [src] to capacity with \the [thing]."))
	else if(value == SUBSTANCE_TAKEN_SOME)
		to_chat(user, SPAN_NOTICE("You fill \the [src] from \the [thing]."))
	else if(value == SUBSTANCE_TAKEN_ALL)
		to_chat(user, SPAN_NOTICE("You dump \the [thing] into \the [src]."))
	else
		to_chat(user, SPAN_WARNING("\The [src] cannot process \the [thing]."))

/obj/machinery/crafting_station/attackby(var/obj/item/O, var/mob/user)
	// Take reagents, if any are applicable.
	var/reagents_taken = take_reagents(O, user)
	if(reagents_taken != SUBSTANCE_TAKEN_NONE)
		show_intake_message(user, reagents_taken, O)
		updateUsrDialog()
		return TRUE
	if(!is_robot_module(O) && user.unEquip(O))
		var/result = max(take_materials(O, user), max(reagents_taken, take_reagents(O, user, TRUE)))
		show_intake_message(user, result, O)
		if(result == SUBSTANCE_TAKEN_NONE)
			user.put_in_active_hand(O)
			return TRUE
		if(istype(O, /obj/item/stack))
			var/obj/item/stack/stack = O
			if(!QDELETED(stack) && stack.amount > 0)
				user.put_in_active_hand(stack)
		updateUsrDialog()
		return TRUE
	. = ..()

/obj/machinery/crafting_station/OnTopic(user, href_list, state)
	if(href_list["make"])
		DoMake(locate(href_list["make"]), user)
		. = TOPIC_REFRESH
	else if(href_list["eject_mat"])
		try_dump_material(href_list["eject_mat"])
		. = TOPIC_REFRESH

/obj/machinery/crafting_station/proc/try_dump_material(var/mat_name)
	for(var/mat_path in stored_substances_to_names)
		if(stored_substances_to_names[mat_path] == mat_name)
			if(ispath(mat_path, /material))
				var/material/mat = SSmaterials.get_material_by_name(mat_name)
				if(mat && materials[mat_path] > mat.units_per_sheet && mat.stack_type)
					var/sheet_count = Floor(materials[mat_path]/mat.units_per_sheet)
					materials[mat_path] -= sheet_count * mat.units_per_sheet
					mat.place_sheet(get_turf(src), sheet_count)
			else if(!isnull(materials[mat_path]))
				materials[mat_path] = 0

#undef SUBSTANCE_TAKEN_FULL
#undef SUBSTANCE_TAKEN_NONE
#undef SUBSTANCE_TAKEN_SOME
#undef SUBSTANCE_TAKEN_ALL