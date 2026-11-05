/datum/action/cooldown/spell/projectile/shadowcrash
	button_icon = 'icons/mob/actions/mage_cryomancy.dmi'
	name = "Shadow Crash"
	desc = "Conjure ice and hurl it in one of two forms. Lance drives a single spear straight ahead, punching through up to three foes in a line, leaving two stacks of frost on each. \
	Burst lobs an arcing shard that shatters on impact in a 3x3 area, dealing 66% damage to non primary targets while leaving one stack of frost on all of them. \
	Toggle firing mode (Shift+G) while the spell is active: Lance or Burst."
	button_icon_state = "ice_burst"
	sound = 'sound/spellbooks/icicle.ogg'
	spell_color = GLOW_COLOR_DARK
	glow_intensity = GLOW_INTENSITY_HIGH
	attunement_school = ASPECT_NAME_UMBRAMANCY

	projectile_type = /obj/projectile/magic/ice_lance
	cast_range = SPELL_RANGE_PROJECTILE
	point_cost = 6
	spell_impact_intensity = SPELL_IMPACT_MEDIUM

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE

	invocations = list("Hasta Glaciei!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	charge_swingdelay_type = SWINGDELAY_PENALTY
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_MAJOR
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 16 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 3

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/current_mode = 1
	var/list/modes = list(
		list("name" = "Ice Lance", "tag" = "LANCE", "proj" = /obj/projectile/magic/ice_lance, "sound" = 'sound/spellbooks/icicle.ogg', "invocation" = "Hasta Glaciei!"),
		list("name" = "Ice Burst", "tag" = "BURST", "proj" = /obj/projectile/magic/ice_burst, "sound" = 'sound/spellbooks/crystal.ogg', "invocation" = "Glacies Frangor!"),
	)
