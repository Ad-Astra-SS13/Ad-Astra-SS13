//skills_required should be formatted as a skill define and a skill level requirement - i.e list(SKILL_ANATOMY = SKILL_ADEPT, SKILL_MEDICAL = SKILL_EXPERT)
//Replace parts of this as required.

/datum/crafting_type
	var/name = "crafting type datum"
	var/skills_required = list() //Skills required to make this thing.
	var/batchable = TRUE //can be made in batches.
	var/required_materials = list(/material/steel = 2500) //required materials / reagents
	var/extra_crafting_time = 0 SECONDS //do we take some more time to make?
	var/obj/item_to_spawn = /obj/item/ammo_casing/shotgun/beanbag //the item we spawn on completion.
	var/obj/item/craftingstation_blueprint/required_blueprint = null//Do we have a required blueprint?

/* unincluding but leaving here for future reference

/datum/crafting_type/test
	name = "test crafting type"
	skills_required = list(SKILL_CONSTRUCTION = SKILL_ADEPT)

/datum/crafting_type/test/skill_check
	name = "skill check test"
	skills_required = list(SKILL_ANATOMY = SKILL_ADEPT, SKILL_MEDICAL = SKILL_EXPERT)

/datum/crafting_type/test/blueprint_check
	name = "blueprint check test"
	required_blueprint = /obj/item/craftingstation_blueprint
*/

