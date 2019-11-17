/obj/item
	var/toolspeed = 5 SECONDS //modified by quality
	var/skill_affects_time = FALSE //does skill affect our usetime?
	var/required_skill //if skill_affects_time = TRUE, then what skill?
	var/toolsound //the sound we make when used.

/obj/item/weapon/tool
	has_item_quality = TRUE

/obj/item/proc/GetUseSpeed(mob/user, var/original_time = 0 SECONDS) //Some items took longer, some items too less to use, notable examples including walls - that's what original_time is for, to increase it again.
	var/new_toolspeed = (toolspeed + original_time) * item_quality

	if(skill_affects_time)
		var/toolspeed_mod = user.skill_delay_mult(required_skill)
		return (new_toolspeed * toolspeed_mod)

	else if(has_item_quality)
		return new_toolspeed

	else
		return toolspeed //Because clustertools and psionics. Bay is special in all the wrong ways.