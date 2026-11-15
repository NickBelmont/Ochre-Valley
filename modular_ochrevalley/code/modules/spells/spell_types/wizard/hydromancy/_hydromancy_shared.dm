#define ASPECT_NAME_HYDROMANCY "Waves"
#define GLOW_COLOR_WATER "#5b89df"
#define TIDESTACK_FILTER "tideaura"
/datum/magic_aspect/hydromancy
	name = "Hydromancy"
	latin_name = "Maior Aspectus Aqua"
	desc = "A first-order school focused on wielding the air itself as a weapon. \
			Utilizing arcyne force, Magi practicing Aeromancy conjure and shape vicious vicious winds to lacerate and devastate their foes. \
			Historically, Aeromancy has its roots spread far across the eastern reaches of Psydonia, from the deserts of Raneshen to the grass sea of Lingyue — now mainland Kazengun."
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_HYDROMANCY
	school_color = GLOW_COLOR_WATER
	binding_chants = list(
		"Invoco aeternos ventos!",
		"I call upon the winds from on high, descend!",
		"Aero, in me ligare!"
	)
	unbinding_chants = list(
		"Solvo ventos vinctam!",
		"I release the winds that ravage without, be calm.",
		"Aero, a me discede!"
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/hydrosphere,
		/datum/action/cooldown/spell/torrent,
		/datum/action/cooldown/spell/aqueous_barrier,
		/datum/action/cooldown/spell/projectile/waterbolt,
	)
	choice_spells = list(
		/datum/action/cooldown/spell/projectile/aqueous_barrage,
		/datum/action/cooldown/spell/depth_charge,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/cyclone,
		),
	)

/proc/apply_tide_stack(mob/living/target, stacks = 1, zone_override = null)
	if(!isliving(target))
		return
	var/final_tier = 0
	for(var/i in 1 to stacks)
		if(target.has_status_effect(/datum/status_effect/buff/tide5))
			//This is stupid, see if there's a better way later.
			target.remove_status_effect(/datum/status_effect/buff/tide5)
			target.apply_status_effect(/datum/status_effect/buff/tide5)
			final_tier = 5
			break
		if(target.has_status_effect(/datum/status_effect/buff/tide4))
			target.remove_status_effect(/datum/status_effect/buff/tide4)
			target.apply_status_effect(/datum/status_effect/buff/tide5)
			final_tier = 5
			to_chat(target, span_notice("The tide within me waxes! Next non-cantrip will be empowered!"))
			break
		if(target.has_status_effect(/datum/status_effect/buff/tide3))
			target.remove_status_effect(/datum/status_effect/buff/tide3)
			target.apply_status_effect(/datum/status_effect/buff/tide4)
			final_tier = 4
			break
		if(target.has_status_effect(/datum/status_effect/buff/tide2))
			target.remove_status_effect(/datum/status_effect/buff/tide2)
			target.apply_status_effect(/datum/status_effect/buff/tide3)
			final_tier = 3
			continue
		if(target.has_status_effect(/datum/status_effect/buff/tide1))
			target.remove_status_effect(/datum/status_effect/buff/tide1)
			target.apply_status_effect(/datum/status_effect/buff/tide2)
			final_tier = 2
			continue
		target.apply_status_effect(/datum/status_effect/buff/tide1)
		final_tier = max(final_tier, 1)
	switch(final_tier)
		if(1)
			target.balloon_alert_to_viewers("<font color='#5b89df'>tides I</font>")
		if(2)
			target.balloon_alert_to_viewers("<font color='#5b89df'>tides II</font>")
		if(3)
			target.balloon_alert_to_viewers("<font color='#5b89df'>tides III</font>")
		if(4)
			target.balloon_alert_to_viewers("<font color='#5b89df'>tides IV</font>")
		if(5)
			target.balloon_alert_to_viewers("<font color='#5b89df'>tides V</font>")


/proc/remove_all_tide_stacks(mob/living/target)
	if(!isliving(target))
		return
	target.remove_status_effect(/datum/status_effect/buff/tide5)
	target.remove_status_effect(/datum/status_effect/buff/tide4)
	target.remove_status_effect(/datum/status_effect/buff/tide3)
	target.remove_status_effect(/datum/status_effect/buff/tide2)
	target.remove_status_effect(/datum/status_effect/buff/tide1)

/datum/status_effect/buff/tide1
	id = "tide1"
	alert_type = /atom/movable/screen/alert/status_effect/buff/tide1
	duration = 15 SECONDS

/atom/movable/screen/alert/status_effect/buff/tide1
	name = "Tidal Flow"
	desc = "I feel the flow of my spells begin to tug at me."
	icon_state = "buff"

/datum/status_effect/buff/tide2
	id = "tide2"
	alert_type = /atom/movable/screen/alert/status_effect/buff/tide1
	duration = 15 SECONDS

/atom/movable/screen/alert/status_effect/buff/tide2
	name = "Tidal Flow II"
	desc = "The ebb and flow of my spells is beginning to take hold."
	icon_state = "buff"

/datum/status_effect/buff/tide3
	id = "tide3"
	alert_type = /atom/movable/screen/alert/status_effect/buff/tide3
	duration = 15 SECONDS

/atom/movable/screen/alert/status_effect/buff/tide3
	name = "Tidal Flow III"
	desc = "I can feel the arcyne rise and fall with my casting like the tide."
	icon_state = "buff"

/datum/status_effect/buff/tide4
	id = "tide4"
	alert_type = /atom/movable/screen/alert/status_effect/buff/tide4
	duration = 15 SECONDS

/atom/movable/screen/alert/status_effect/buff/tide4
	name = "Tidal Flow IV"
	desc = "The tide within me crecendos, I must release this building wave soon."
	icon_state = "buff"

/datum/status_effect/buff/tide5
	id = "tide5"
	alert_type = /atom/movable/screen/alert/status_effect/buff/tide5
	duration = 15 SECONDS

/atom/movable/screen/alert/status_effect/buff/tide5
	name = "Tidal Flow V"
	desc = "The tides are at their highest, my next non-cantrip spell will be empowered!."
	icon_state = "buff"


/datum/status_effect/buff/tide5/on_apply()
	. = ..()
	var/filter = owner.get_filter(TIDESTACK_FILTER)
	if(!filter)
		owner.add_filter(TIDESTACK_FILTER, 2, list("type" = "outline", "color" = GLOW_COLOR_WATER, "alpha" = 60, "size" = 2))

/datum/status_effect/buff/tide5/on_remove()
	. = ..()
	owner.remove_filter(TIDESTACK_FILTER)


/obj/effect/temp_visual/hydro_burst
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	color = GLOW_COLOR_WATER
	duration = 1 SECONDS

#undef TIDESTACK_FILTER
