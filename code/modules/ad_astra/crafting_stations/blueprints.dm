/obj/item/craftingstation_blueprint
	name = "Blueprint package"
	desc = "A set of schematics, practical examples, and technical resources."
	icon = 'icons/obj/ad_astra/crafting/blueprints.dmi'
	var/blueprint_tier = TIER_BASIC
	var/list/relevant_skills = list() //used for fluff, right now.

/obj/item/craftingstation_blueprint/examine(mob/user, distance)
	. = ..()
	var/blueprint_desc
	switch(blueprint_tier)
		if(TIER_BASIC)
			blueprint_desc = "This is a set of basic blueprints, simple in theory and pratical application, even with limited or secondhand knowledge of a subject, you can more or less grasp the concepts."
		if(TIER_INTERMEDIATE)
			blueprint_desc = "This is a set of intermediate blueprints, slightly more difficult to understand in theory and practical application without the knowledge in it's specific field. With time, you could probably figure them out."
		if(TIER_ADVANCED)
			blueprint_desc = "This is a set of advanced blueprints, bewildering to anyone without a decent knowledge within it's related field. You could understand this, but it would take weeks, if not months without the prerequisite knowledge."
		if(TIER_EXCEPTIONAL)
			blueprint_desc = "This is a set of exceptional blueprints, utterly incomprehensible to anyone without in-depth knowledge within it's related fields. There is no way you could possibly understand the secrets that lay within without significant experience in it's related fields."
	to_chat(user, SPAN_NOTICE(blueprint_desc))

/obj/item/craftingstation_blueprint/basic
	name = "basic blueprint package"
	icon_state = "basic_blueprints"

/obj/item/craftingstation_blueprint/intermediate
	name = "intermediate blueprint package"
	blueprint_tier = TIER_INTERMEDIATE
	icon_state = "norm_blueprints"

/obj/item/craftingstation_blueprint/advanced
	name = "advanced blueprint package"
	blueprint_tier = TIER_ADVANCED
	icon_state = "adv_blueprints"

/obj/item/craftingstation_blueprint/exceptional
	name = "exceptional blueprint package"
	blueprint_tier = TIER_EXCEPTIONAL
	icon_state = "except_blueprints"