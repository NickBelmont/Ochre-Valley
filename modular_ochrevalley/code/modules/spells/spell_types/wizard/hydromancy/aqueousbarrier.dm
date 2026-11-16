#define BARRIER_GRACE (2 SECONDS)
/datum/action/cooldown/spell/aqueous_barrier
	button_icon = 'icons/mob/actions/mage_telomancy.dmi'
	name = "Aqueous Barrier"
	desc = "Surrounds an ally with warding orbs instantly. Each reduce an incoming blow's integrity damage by 25% before disintegrating."
	button_icon_state = "circumdatum"
	sound = 'sound/magic/vlightning.ogg'
	spell_color = GLOW_COLOR_WATER
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_HYDROMANCY

	click_to_activate = TRUE
	cast_range = 7

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Aegis Aquae!")
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	cooldown_time = 15 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	supports_fellowship_snap = TRUE

	var/orb_count = 3

/datum/action/cooldown/spell/aqueous_barrier/cast(atom/cast_on)
	. = ..()
	if(!ishuman(cast_on))
		to_chat(owner, span_warning("I can only ward another person!"))
		return FALSE
	var/mob/living/carbon/human/target = cast_on
	target.apply_status_effect(/datum/status_effect/buff/aqueous_barrier, owner, orb_count)
	return TRUE

/datum/action/cooldown/spell/aqueous_barrier/get_spell_statistics(mob/living/user)
	var/list/stats = ..()
	stats += span_info("Fellowship Mode (toggle with Shift+G): An off-target cast snaps the ward to your nearest fellowship member in range.")
	return stats

/atom/movable/screen/alert/status_effect/buff/aqueous_barrier
	name = "Aqueous Barrier"
	desc = "Arcyne orbs circle me,ready to blunt a blow before it lands."
	icon_state = "buff"

/datum/status_effect/buff/aqueous_barrier
	id = "aqueous_barrier"
	duration = 30 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/buff/aqueous_barrier
	var/orbs = 3
	var/list/orb_visuals
	var/datum/weakref/caster_ref
	var/last_struck_time = 0
	var/damage = SPELL_DMG(60)

/datum/status_effect/buff/aqueous_barrier/on_creation(mob/living/new_owner, mob/living/caster, count = 3)
	orbs = count
	caster_ref = WEAKREF(caster)
	return ..()

/datum/status_effect/buff/aqueous_barrier/on_apply()
	. = ..()
	if(!.)
		return
	orb_visuals = list()
	RegisterSignals(owner, list(COMSIG_MOB_ITEM_BEING_ATTACKED, COMSIG_MOB_ATTACKED_BY_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_WAS_ATTACKED), PROC_REF(on_struck))
	for(var/i in 1 to orbs)
		var/obj/effect/aqueous_barrier_orb/orb = new()
		orb_visuals += orb
		owner.vis_contents += orb
		spin_orb(orb, (i - 1) * (360 / orbs))
	owner.balloon_alert_to_viewers("<font color='[GLOW_COLOR_ARCANE]'>warded!</font>")

/datum/status_effect/buff/aqueous_barrier/proc/spin_orb(obj/effect/orb, phase)
	var/radius = 16
	var/segments = 12
	var/seg_time = 1.2
	orb.pixel_x = round(radius * cos(phase))
	orb.pixel_y = round(radius * sin(phase))
	for(var/s in 1 to segments)
		var/a = phase + (s * (360 / segments))
		if(s == 1)
			animate(orb, pixel_x = round(radius * cos(a)), pixel_y = round(radius * sin(a)), time = seg_time, loop = -1, flags = ANIMATION_PARALLEL)
		else
			animate(pixel_x = round(radius * cos(a)), pixel_y = round(radius * sin(a)), time = seg_time)

/datum/status_effect/buff/aqueous_barrier/proc/on_struck(datum/source, mob/living/struck, mob/living/attacker, obj/item/weapon)
	SIGNAL_HANDLER
	if(world.time < last_struck_time + BARRIER_GRACE)
		return
	last_struck_time = world.time
	deplete_orb()

/datum/status_effect/buff/aqueous_barrier/proc/deplete_orb()
	orbs = max(0, orbs - 1)
	if(length(orb_visuals))
		var/obj/effect/spent = orb_visuals[length(orb_visuals)]
		orb_visuals -= spent
		if(owner)
			owner.vis_contents -= spent
		if(!QDELETED(spent))
			qdel(spent)
	var/mob/living/caster = caster_ref.resolve()
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(aqueous_detonation), owner, caster, damage)
	if(orbs <= 0)
		owner.remove_status_effect(/datum/status_effect/buff/aqueous_barrier)

/datum/status_effect/buff/aqueous_barrier/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOB_ITEM_BEING_ATTACKED, COMSIG_MOB_ATTACKED_BY_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_WAS_ATTACKED))
	for(var/obj/effect/orb in orb_visuals)
		if(owner)
			owner.vis_contents -= orb
		if(!QDELETED(orb))
			qdel(orb)
	orb_visuals = null
	. = ..()

/obj/effect/aqueous_barrier_orb
	name = "water orb"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "gumball"
	color = GLOW_COLOR_WATER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER
	vis_flags = VIS_INHERIT_PLANE

/proc/aqueous_detonation(mob/living/source, mob/living/caster, damage = 60)
	var/list/indicator = list()
	var/turf/last_turf
	var/locked_facing = telegraph_cardinal(source.dir)
	for(var/i in 1 to 5)
		if(QDELETED(source) || source.stat != CONSCIOUS)
			break
		if(get_turf(source) != last_turf)
			last_turf = get_turf(source)
			telegraph_draw(last_turf, locked_facing, indicator, get_aqueous_offsets(), /obj/effect/temp_visual/telegraph/pillar, TRUE)
		sleep(2)
	telegraph_clear(indicator)
	if(QDELETED(source) || source.stat != CONSCIOUS)
		return
	var/turf/epicenter = get_turf(source)
	playsound(epicenter, 'sound/foley/water_land1.ogg', 100, TRUE, soundping = FALSE)
	for(var/turf/T in range(1, epicenter))
		if(T == epicenter)
			continue
		new /obj/effect/temp_visual/hydro_burst(T)
		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				L.visible_message(span_warning("The water splashed harmlessly against [L]!"))
				playsound(get_turf(L), 'sound/magic/magic_nulled.ogg', 100)
				continue
			if(L.guard_deflect_spell("Aqueous Detonation", TRUE, caster, punish_caster = FALSE))
				continue
			if(arcyne_strike(caster, L, null, damage, BODY_ZONE_CHEST, BCLASS_BLUNT, \
				spell_name = "Aqueous Detonation", damage_type = BRUTE, \
				skip_animation = TRUE, SPELL_STRIKE_SCALING) == ARCYNE_STRIKE_WARDED)
				continue
			new /obj/effect/temp_visual/spell_impact(get_turf(L), GLOW_COLOR_WATER, GLOW_INTENSITY_MEDIUM)

/proc/get_aqueous_offsets()
	var/list/offs = list()
	for(var/i in -1 to 1)
		if(i == 0)
			offs += list(list(-1, 0), list(1, 0))
		else
			offs += list(list(-1, i), list(0, i), list(1, i))
	return offs

#undef BARRIER_GRACE
