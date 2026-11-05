//Using this so we don't need to touch upstream defines.
#define ASPECT_NAME_UMBRAMANCY "Darkness"
#define GLOW_COLOR_DARK "#582858"
#define DARKNESS_OVERLAY_COLOR rgb(88, 40, 88)

/proc/apply_darkness_stack(mob/living/target, stacks = 1, zone_override = null)
	if(!isliving(target))
		return
	//new /obj/effect/temp_visual/scorch_flash(get_turf(target))
	var/final_tier = 0
	for(var/i in 1 to stacks)
		if(target.has_status_effect(/datum/status_effect/debuff/darkness2))
			target.remove_status_effect(/datum/status_effect/debuff/darkness2)
			target.apply_status_effect(/datum/status_effect/debuff/darkness3)
			final_tier = 3
			continue
		if(target.has_status_effect(/datum/status_effect/debuff/darkness1))
			target.remove_status_effect(/datum/status_effect/debuff/darkness1)
			target.apply_status_effect(/datum/status_effect/debuff/darkness2)
			final_tier = 2
			continue
		target.apply_status_effect(/datum/status_effect/debuff/darkness1)
		final_tier = max(final_tier, 1)
	switch(final_tier)
		if(1)
			target.balloon_alert_to_viewers("<font color='#B050B0'>Pervasive Darkness I</font>")
		if(2)
			target.balloon_alert_to_viewers("<font color='#B050B0'>Pervasive Darkness II</font>")
		if(3)
			target.balloon_alert_to_viewers("<font color='#B050B0'>Pervasive Darkness III</font>")

/proc/remove_darkness_stack(mob/living/target)
	if(!isliving(target))
		return FALSE
	if(target.has_status_effect(/datum/status_effect/debuff/darkness3))
		target.remove_status_effect(/datum/status_effect/debuff/darkness3)
		target.apply_status_effect(/datum/status_effect/debuff/darkness2)
		return TRUE
	if(target.has_status_effect(/datum/status_effect/debuff/darkness2))
		target.remove_status_effect(/datum/status_effect/debuff/darkness2)
		target.apply_status_effect(/datum/status_effect/debuff/darkness1)
		return TRUE
	if(target.has_status_effect(/datum/status_effect/debuff/darkness1))
		target.remove_status_effect(/datum/status_effect/debuff/darkness1)
		return TRUE
	return FALSE

/proc/has_darkness_stacks(mob/living/target)
	if(!isliving(target))
		return FALSE
	return get_darkness_stacks(target) > 0

/proc/get_darkness_stacks(mob/living/target)
	if(!isliving(target))
		return 0
	if(target.has_status_effect(/datum/status_effect/debuff/darkness3))
		return 3
	if(target.has_status_effect(/datum/status_effect/debuff/darkness2))
		return 2
	if(target.has_status_effect(/datum/status_effect/debuff/darkness1))
		return 1
	return 0

/proc/remove_all_darkness_stacks(mob/living/target)
	if(!isliving(target))
		return
	target.remove_status_effect(/datum/status_effect/debuff/darkness3)
	target.remove_status_effect(/datum/status_effect/debuff/darkness2)
	target.remove_status_effect(/datum/status_effect/debuff/darkness1)

/datum/status_effect/debuff/darkness1
	id = "darkness1"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/darkness1
	duration = 15 SECONDS

/atom/movable/screen/alert/status_effect/debuff/darkness1
	name = "Pervasive Darkness"
	desc = "An umbral veil settles over me."
	icon_state = "debuff"

/datum/status_effect/debuff/darkness1/on_apply()
	. = ..()
	owner.add_atom_colour(DARKNESS_OVERLAY_COLOR, TEMPORARY_COLOUR_PRIORITY)

/datum/status_effect/debuff/darkness1/on_remove()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, DARKNESS_OVERLAY_COLOR)
	. = ..()

/datum/status_effect/debuff/darkness2
	id = "darkness2"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/darkness2
	duration = 15 SECONDS

/atom/movable/screen/alert/status_effect/debuff/darkness2
	name = "Pervasive Darkness II"
	desc = "Dread creeps into my heart as darkness overtakes me."
	icon_state = "debuff"

/datum/status_effect/debuff/darkness2/on_apply()
	. = ..()
	owner.add_atom_colour(DARKNESS_OVERLAY_COLOR, TEMPORARY_COLOUR_PRIORITY)

/datum/status_effect/debuff/darkness2/on_remove()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, DARKNESS_OVERLAY_COLOR)
	. = ..()

/datum/status_effect/debuff/darkness3
	id = "darkness3"
	alert_type = /atom/movable/screen/alert/status_effect/debuff/darkness3
	duration = 15 SECONDS

/atom/movable/screen/alert/status_effect/debuff/darkness3
	name = "Pervasive Darkness III"
	desc = "The darkness weighs heavy on me like a sheet of mail."
	icon_state = "debuff"

/datum/status_effect/debuff/darkness3/on_apply()
	. = ..()
	owner.add_atom_colour(DARKNESS_OVERLAY_COLOR, TEMPORARY_COLOUR_PRIORITY)

/datum/status_effect/debuff/darkness3/on_remove()
	owner.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, DARKNESS_OVERLAY_COLOR)
	. = ..()

/obj/effect/temp_visual/umbral
	name = "umbral cloud"
	icon = 'icons/effects/effects.dmi'
	icon_state = "curseblob"
	duration = 1 SECONDS
