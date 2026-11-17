/datum/advclass/mercenary/magoespada
	name = "Mago de le Espada"
	tutorial = "Originating from the tempestous shores of Etrusca, Magos de le Espada, or 'Mages of the Blade' in imperial utilise a unique blend of aeromancy, fulgurmancy, and swordplay to strike down their foes."
	outfit = /datum/outfit/job/roguetown/mercenary/magoespada
	class_select_category = CLASS_CAT_ETRUSCA
	cmode_music = 'sound/music/combat_vaquero.ogg'
	category_tags = list(CTAG_MERCENARY, CTAG_MERCPARTY_BRAVO)
	subclass_languages = list(/datum/language/etruscan)
	subclass_mage_aspects = list("mastery" = FALSE, "major" = 0, "minor" = 1, "utilities" = 5)
	subclass_virtues = list(
		/datum/virtue/combat/guarded
	)
	subclass_stats = list(
		STATKEY_SPD = 2,
		STATKEY_INT = 3,
		STATKEY_WIL = 1,
		STATKEY_PER = 1,
	)
	subclass_skills = list(
		/datum/skill/combat/swords = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/climbing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/stealing = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/magic/arcane = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/music = SKILL_LEVEL_EXPERT,
	)


/datum/outfit/job/roguetown/mercenary/magoespada/pre_equip(mob/living/carbon/human/H)
	..()
	head = /obj/item/clothing/head/roguetown/bardhat
	mouth = /obj/item/alch/rosa
	shoes = /obj/item/clothing/shoes/roguetown/boots
	neck = /obj/item/clothing/neck/roguetown/gorget
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
	belt = /obj/item/storage/belt/rogue/leather
	gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather/heavy/coat
	cloak = /obj/item/clothing/cloak/half/rider/red
	backl = /obj/item/storage/backpack/rogue/satchel
	beltl = /obj/item/rogueweapon/scabbard/sword
	l_hand = /obj/item/rogueweapon/sword/rapier
	backpack_contents = list(
					/obj/item/storage/belt/rogue/pouch/coins/poor = 1,
					/obj/item/rogueweapon/huntingknife/idagger/navaja = 1,
					/obj/item/flashlight/flare/torch/lantern = 1,
					/obj/item/roguekey/mercenary = 1,
					/obj/item/rogueweapon/scabbard/sheath = 1
					)
	if(H.mind)
		H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/swiftcast/airmagic)
		H.mind.AddSpell(new /datum/action/cooldown/spell/projectile/swiftcast/fulgurmagic)
		H.mind.AddSpell(new /datum/action/cooldown/spell/bind_espada)

	H.merctype = 13
