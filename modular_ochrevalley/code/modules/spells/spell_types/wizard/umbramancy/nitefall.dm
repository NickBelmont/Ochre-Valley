/datum/action/cooldown/spell/nitefall
	name = "Nitefall"
	desc = "Summon an unstable crystal of umbral energies, which will periodically release a burst that damages all nearby."
	button_icon = 'icons/mob/actions/classuniquespells/spellblade.dmi'
	button_icon_state = "leyline_anchor"
	sound = 'sound/misc/portalactivate.ogg'
	spell_color = GLOW_COLOR_DARK
	glow_intensity = GLOW_INTENSITY_HIGH
	attunement_school = ASPECT_NAME_UMBRAMANCY

	cast_range = SPELL_RANGE_GROUND

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_ULTIMATE

	invocations = list("Ventorum Letalium, Respondete Mihi!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_HEAVY
	charge_swingdelay_type = SWINGDELAY_CANCEL
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_HEAVY
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 90 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_HIGH

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z | SPELL_REQUIRES_NO_MOVE

/datum/action/cooldown/spell/nitefall/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/turf/aimed = get_turf(cast_on)
	if(!aimed)
		return FALSE
	new /obj/effect/umbralfount(aimed, owner, 2)
	for(var/x in 0 to 1)
		for(var/y in 0 to 1)
			var/target_x = aimed.x - 2 + (4*x)
			var/target_y = aimed.y - 2 + (4*y)
			var/turf/fountLoc = locate(target_x, target_y, aimed.z)
			if(fountLoc && !fountLoc.density)
				new /obj/effect/umbralfount(fountLoc, owner, 2)
