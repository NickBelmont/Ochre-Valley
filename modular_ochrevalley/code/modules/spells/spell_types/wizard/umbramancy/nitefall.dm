/datum/action/cooldown/spell/nitefall
	name = "Nitefall"
	desc = "Summon an unstable crystal of umbral energies, which will periodically release a burst that damages all nearby."
	button_icon = 'icons/mob/actions/zizomiracles.dmi'
	button_icon_state = "cataclysm"
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

	var/fount_size = 2

/datum/action/cooldown/spell/nitefall/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/turf/aimed = get_turf(cast_on)
	if(!aimed)
		return FALSE
	new /obj/effect/umbralfount(aimed, owner, 3)
	addtimer(CALLBACK(src, PROC_REF(do_ring), aimed), 1.5 SECONDS, fount_size)
	return TRUE


/datum/action/cooldown/spell/nitefall/proc/do_ring(turf/aimed, size = 2)
	if(!aimed)
		return
	for(var/i in 0 to 3)
		var/turf/fountLoc = locate(aimed.x - 2 + (4*(i%2)), aimed.y - 2 + (4*round(i/2)), aimed.z)
		if(fountLoc && !fountLoc.density)
			var/obj/effect/umbralfount/U = new /obj/effect/umbralfount(fountLoc, owner, 3)
			var/original_x = U.pixel_x
			var/original_y = U.pixel_y
			U.pixel_x = U.pixel_x + 64 - (128 * (i%2))
			U.pixel_y = U.pixel_y + 64 - (128 * round(i/2))

			if(i%2)
				animate(U, pixel_x = original_x, time = 5, easing = SINE_EASING | EASE_IN)
				animate(pixel_y = original_y, time = 5, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
			else
				animate(U, pixel_y = original_y, time = 5, easing = SINE_EASING | EASE_IN)
				animate(pixel_x = original_x, time = 5, easing = SINE_EASING | EASE_OUT, flags = ANIMATION_PARALLEL)
