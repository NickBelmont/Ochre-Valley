#define TAILWIND_DURATION 2 SECONDS
/datum/action/cooldown/spell/tailwind
	button_icon = 'icons/mob/actions/mage_cryomancy.dmi'
	name = "Tailwind"
	desc = "Allows the caster to move freely as the winds, while hindering those in their wake briefly."
	button_icon_state = "snap_freeze"
	sound = 'sound/spellbooks/crystal.ogg'
	spell_color = GLOW_COLOR_WIND
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_AEROMANCY

	click_to_activate = FALSE
	cast_range = SPELL_RANGE_GROUND

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	invocations = list("Ventus a Tergo!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_swingdelay_type = SWINGDELAY_PENALTY
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 45 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	point_cost = 3

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

/datum/action/cooldown/spell/tailwind/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/turf/turf = get_turf(H)
	playsound(turf, 'sound/spellbooks/crystal.ogg', 80, TRUE)
	var/init = new /obj/effect/tailwind(turf, H)
	if(init)
		H.apply_status_effect(/datum/status_effect/tailwind)
		return TRUE
	return FALSE

/obj/effect/tailwind
	name = "tailwind"
	desc = "Whirling winds left in an aeromancer's wake."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_outer_range = 1
	light_color = GLOW_COLOR_WIND
	var/mob/living/caster

/obj/effect/tailwind/Initialize(mapload, mob/living/owner, lifespan = TAILWIND_DURATION)
	. = ..()
	caster = owner
	RegisterSignal(get_turf(src), COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(get_turf(src), COMSIG_ATOM_EXIT, PROC_REF(on_exit))
	if(lifespan)
		QDEL_IN(src, lifespan)

/obj/effect/tailwind/Destroy()
	UnregisterSignal(get_turf(src), COMSIG_ATOM_ENTERED)
	UnregisterSignal(get_turf(src),	COMSIG_ATOM_EXIT)
	return ..()

/obj/effect/tailwind/proc/on_entered(datum/source, atom/movable/AM, atom/old_loc)
	SIGNAL_HANDLER
	if(!isliving(AM))
		return
	var/mob/living/L = AM
	if(L == caster)
		return
	if(L.force_moving || L.throwing || L.buckled || L.IsImmobilized())
		return
	if(L.has_status_effect(/datum/status_effect/tailwind_slow))
		return
	L.apply_status_effect(/datum/status_effect/tailwind_slow)

/obj/effect/tailwind/proc/on_exit(turf/exited, atom/movable/exiting, atom/newloc)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/H = exiting
	if(ishuman(exiting) && H.has_status_effect(/datum/status_effect/tailwind)) //Don't check caster here so two tailwinding mages don't cancel their tailwinds out
		new /obj/effect/tailwind(get_turf(newloc), H)

/datum/status_effect/tailwind_slow
	id = "tailwind_slow"
	duration = 3 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/tailwind_slow
	effectedstats = list(STATKEY_SPD = -1)

/datum/status_effect/tailwind
	id = "tailwind"
	duration = 6 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/tailwind
	effectedstats = list(STATKEY_SPD = 2)

/datum/status_effect/tailwind/on_apply()
	owner.pass_flags |= PASSMOB
	. = ..()

/datum/status_effect/tailwind/on_remove()
	owner.pass_flags &= ~PASSMOB
	. = ..()

/atom/movable/screen/alert/status_effect/tailwind
	name = "Tailwind"
	desc = "I am one with the winds, bolstering my speed and leaving a turbulent wake in my steps."
	icon_state = "buff"

/atom/movable/screen/alert/status_effect/tailwind_slow
	name = "Tailwind"
	desc = "An unfavorable wind is making movement slightly more difficult."
	icon_state = "debuff"

#undef TAILWIND_DURATION
