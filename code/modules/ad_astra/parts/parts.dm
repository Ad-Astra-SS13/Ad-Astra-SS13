/obj/item/weapon/stock_parts/machine_parts
	name = "machinery parts"
	desc = "Generic, standardized replacement or initial parts for machinery."
	icon = 'icons/obj/ad_astra/crafting/machine_parts.dmi'
	var/desc_add_text

/obj/item/weapon/stock_parts/machine_parts/examine(mob/user, distance)
	. = ..()
	to_chat(user, SPAN_NOTICE(desc_add_text))

/obj/item/weapon/stock_parts/machine_parts/basic_mech
	name = "basic mechanical parts"
	desc_add_text = "These are simple mechanical parts, used for basic machinery functions. They are very simple in construction and very robust."
	icon_state = "bmechanical"

/obj/item/weapon/stock_parts/machine_parts/basic_electrical
	name = "basic electronic componenets"
	desc_add_text = "These are simple electronic components, used for basic logic functions. They are simple in design and construction, but might be prone to burning out."
	icon_state = "belectical"

/obj/item/weapon/stock_parts/machine_parts/adv_mechanical
	name = "advanced mechanical parts"
	desc_add_text = "These are more advanced, complicated machinery parts, used for more demanding applications. They are somewhat more delicate and expensive."
	icon_state = "amechanical"

/obj/item/weapon/stock_parts/machine_parts/adv_electrical
	name = "advanced electrical componenets"
	desc_add_text = "These are more advanced and intricate electronic componenets, used for logic functions. They're delicate and pricy to replace."
	icon_state = "aelectrical"