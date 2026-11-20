/datum/action/cooldown/spell/projectile/hydrosphere
	name = "Hydrosphere"
	desc = "Pending"
	sound = 'sound/foley/water_land1.ogg'
	spell_color = GLOW_COLOR_WATER
	glow_intensity = GLOW_INTENSITY_HIGH
	attunement_school = ASPECT_NAME_HYDROMANCY


	projectile_type = /obj/projectile/magic/hydrosphere
	cast_range = SPELL_RANGE_PROJECTILE
	point_cost = 6
	spell_impact_intensity = SPELL_IMPACT_MEDIUM

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_PROJECTILE

	invocations = list("Sphaera Aqua!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_MAJOR
	charge_swingdelay_type = SWINGDELAY_PENALTY
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = SPELL_COOLDOWN_BIG_WHOOPER

	var/current_mode = 1
	var/waterfall_damage = SPELL_DMG(60)
	var/waterfall_delay = 1.5 SECONDS
	var/list/modes = list(
		list("name" = "Hydrosphere", "tag" = "BALL", "invocation" = "Sphaera Aqua!"),
		list("name" = "Waterfall", "tag" = "FALL", "ground" = TRUE, "invocation" = "Cataracta!"),
	)

/datum/action/cooldown/spell/projectile/hydrosphere/Grant(mob/grant_to)
	. = ..()
	apply_mode(current_mode)

/datum/action/cooldown/spell/projectile/hydrosphere/proc/apply_mode(index)
	var/list/mode = modes[index]
	invocations = list(mode["invocation"])
	build_all_button_icons()
	update_mode_maptext(mode["tag"])

/datum/action/cooldown/spell/projectile/hydrosphere/toggle_arc_mode(mob/user)
	current_mode = (current_mode % length(modes)) + 1
	apply_mode(current_mode)
	var/list/mode = modes[current_mode]
	to_chat(user, span_notice("[name]: [mode["name"]] mode."))

/datum/action/cooldown/spell/projectile/hydrosphere/proc/update_mode_maptext(tag)
	for(var/datum/hud/hud as anything in viewers)
		var/atom/movable/screen/movable/action_button/B = viewers[hud]
		var/atom/movable/screen/arc_maptext_holder/holder
		for(var/atom/movable/screen/arc_maptext_holder/existing in B.vis_contents)
			holder = existing
			break
		if(!holder)
			holder = new(B)
			B.vis_contents.Add(holder)
		holder.maptext = MAPTEXT(tag)
		holder.color = "#5b89df"

/datum/action/cooldown/spell/projectile/hydrosphere/fire_projectile(atom/target)
	if(!modes[current_mode]["ground"])
		return ..()
	var/turf/epicenter = get_turf(target)
	if(!epicenter)
		return FALSE
	var/empowered = FALSE
	if(isliving(owner))
		var/mob/living/L = owner
		if(L.has_status_effect(/datum/status_effect/buff/tide5))
			remove_all_tide_stacks(owner)
			to_chat(L, span_notice("My tidal flow empowers the waterfall!"))
			empowered = TRUE
	var/list/turfs = telegraph_resolve_turfs(epicenter, telegraph_cardinal(owner.dir), get_offsets(empowered), TRUE)
	for(var/turf/T in turfs)
		new /obj/effect/temp_visual/telegraph/pillar/fadein(T, waterfall_delay)
	playsound(epicenter, 'sound/magic/charging.ogg', 80, TRUE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(waterfall_erupt), turfs, owner, waterfall_damage, owner.zone_selected), waterfall_delay)
	return TRUE

/datum/action/cooldown/spell/projectile/hydrosphere/proc/get_offsets(empowered)
	var/list/offs = list()
	var/range = empowered ? 2 : 1
	for(var/i in -range to range)
		offs += list(list(i, -1), list(i, 0), list(i, 1))
	return offs

/proc/waterfall_erupt(list/turfs, mob/living/caster, damage, aim_zone)
	for(var/turf/T in turfs)
		new /obj/effect/temp_visual/hydro_burst(T)
		for(var/obj/O in T)
			O.extinguish()
		var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T)
		if(hotspot)
			new /obj/effect/temp_visual/small_smoke(T)
			qdel(hotspot)
		for(var/mob/living/L in T)
			if(L.stat == DEAD)
				continue
			if(L.anti_magic_check())
				continue
			if(L.guard_deflect_spell("Waterfall", TRUE, caster, punish_caster = FALSE))
				continue
			if(istype(caster) && !QDELETED(caster))
				if(arcyne_strike(caster, L, null, damage, aim_zone || BODY_ZONE_CHEST, BCLASS_BLUNT, spell_name = "Waterfall", damage_type = BRUTE, skip_animation = TRUE, exact_zone = TRUE, SPELL_STRIKE_SCALING) == ARCYNE_STRIKE_WARDED)
					continue
			else
				L.adjustBruteLoss(SPELL_DMG_VS(L, damage))
			L.apply_status_effect(/datum/status_effect/debuff/vulnerable, 4 SECONDS)

/obj/projectile/magic/hydrosphere
	name = "hydrosphere"
	expose_caster_on_deflect = TRUE
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "blue_laser"
	speed = MAGE_PROJ_VERY_SLOW
	damage = SPELL_DMG(90)
	damage_type = BRUTE
	woundclass = BCLASS_BLUNT
	nodamage = FALSE
	intdamfactor = SPELL_INTDAM(1)
	spell_damage_scaled = TRUE
	hitsound = 'sound/blank.ogg'
	/// Radius for AOE blast around impact point
	var/aoe_radius = 1
	/// AOE damage as a fraction of the projectile's base damage
	var/aoe_damage_ratio = 0.66


/obj/projectile/magic/hydrosphere/on_hit(atom/target, blocked)
	. = ..()
	var/mob/living/M = ismob(target) ? target : null
	if(M?.anti_magic_check())
		visible_message(span_warning("[src] fizzles on contact with \the [target]!"))
		playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
		qdel(src)
		return BULLET_ACT_BLOCK

	if(out_of_effective_range())
		return

	var/turf/epicenter = get_turf(target)

	if(epicenter)
		playsound(epicenter, 'sound/foley/jumpland/waterland.ogg', 100, TRUE, 6)

	if(aoe_radius > 0 && istype(firer, /mob/living/carbon/human))
		var/mob/living/carbon/human/caster = firer
		var/mob/living/direct_hit = M
		if(caster.has_status_effect(/datum/status_effect/buff/tide5))
			to_chat(caster, span_notice("My tidal flow empowers the hydrosphere!"))
			remove_all_tide_stacks(caster)
			aoe_radius += 1
			damage *= 1.5
		var/aoe_damage = round(damage * aoe_damage_ratio)
		for(var/turf/T in range(aoe_radius, epicenter))
			new /obj/effect/temp_visual/hydro_burst(T)
			// Extinguish burning objects and hotspots in the blast radius
			for(var/obj/O in T)
				O.extinguish()
			var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T)
			if(hotspot)
				new /obj/effect/temp_visual/small_smoke(T)
				qdel(hotspot)
			for(var/mob/living/L in T)
				if(L == direct_hit || L.stat == DEAD)
					continue
				if(L.anti_magic_check())
					continue
				if(L.guard_deflect_spell("Hydrosphere", TRUE, caster, punish_caster = FALSE))
					continue
				if(arcyne_strike(caster, L, null, aoe_damage, BODY_ZONE_CHEST, \
					BCLASS_BLUNT, spell_name = "Hydrosphere", \
					allow_shield_check = TRUE, damage_type = BRUTE, \
					skip_animation = TRUE, SPELL_STRIKE_SCALING) == ARCYNE_STRIKE_WARDED)
					continue
				new /obj/effect/temp_visual/spell_impact(get_turf(L), GLOW_COLOR_WATER, SPELL_IMPACT_MEDIUM)

	if(isliving(target) && blocked < 100)
		var/mob/living/L = target
		if(L.on_fire)
			L.adjust_fire_stacks(-1)
			L.visible_message(span_warning("The water extinguishes the flames on [L]!"))

	qdel(src)
	return TRUE
