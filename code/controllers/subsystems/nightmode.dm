SUBSYSTEM_DEF(nightshift)
	name = "Night Shift"
	wait = 600
	flags = SS_NO_TICK_CHECK
	init_order = SS_INIT_MISC_LATE

	var/nightshift_active = FALSE
	var/nightshift_start_time = 702000		//7:30 PM, station time
	var/nightshift_end_time = 270000		//7:30 AM, station time
	var/nightshift_first_check = 30 SECONDS
	var/decl/security_level/lowest_security_level
	var/decl/security_level/current_security_level
	var/last_check_aborted_by_security_state = FALSE

/datum/controller/subsystem/nightshift/Initialize()
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	lowest_security_level = security_state.current_security_level //lowest security level is assumed to be whatever the security level is at roundstart.
	. = ..()

/datum/controller/subsystem/nightshift/fire(resumed = FALSE)
	if(world.time - readglobal(round_start_time) < nightshift_first_check)
		return
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	current_security_level = security_state.current_security_level
	check_nightshift()

/datum/controller/subsystem/nightshift/proc/check_security_level() //used to nudge the controller about the security state by the alert levels.
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	current_security_level = security_state.current_security_level
	if(security_state.current_security_level != lowest_security_level)
		last_check_aborted_by_security_state = TRUE

/datum/controller/subsystem/nightshift/proc/announce(message)
	priority_announcement.Announce(message, "Automated Lighting System Announcement")

/datum/controller/subsystem/nightshift/proc/check_nightshift()
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	var/announce = TRUE

	var/time = station_time_in_ticks
	var/night_time = (time < nightshift_end_time) || (time > nightshift_start_time)
	if(security_state.current_security_level.name != lowest_security_level.name)
		nightshift_active = FALSE
		last_check_aborted_by_security_state = TRUE
		return //we're not at code green, so logically we don't really give a shit about nightmode lighting.

	if(last_check_aborted_by_security_state) //going back to nightmode lighting after the alert has gone down.
		announce("Restoring nightmode lighting after alert de-escalation.")
		last_check_aborted_by_security_state = FALSE
		announce = FALSE //we don't announce this.

	if(!nightshift_active)
		update_nightshift(night_time, announce)

/datum/controller/subsystem/nightshift/proc/update_nightshift(active, var/announce)
	nightshift_active = active
	if(announce)
		if (active)
			announce("Good evening, crew. To reduce power consumption and stimulate the circadian rhythms of some species, all of the lights aboard the station have been dimmed for the night.")
		else
			announce("Good morning, crew. As it is now day time, all of the lights aboard the station have been restored to their former brightness.")
	var/engage
	switch(active)
		if(TRUE)
			engage = "nightmode"
		if(FALSE)
			engage = "reset"
	for(var/obj/machinery/power/apc/A in global_apc_list)
		if(!A.z in GLOB.using_map.station_levels)
			continue
		A.set_light_color(engage)
		CHECK_TICK