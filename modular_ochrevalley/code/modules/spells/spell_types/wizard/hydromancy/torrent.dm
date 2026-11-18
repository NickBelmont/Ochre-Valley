#define LOCKDOWN_CAST "usingspell"
/datum/action/cooldown/spell/torrent
	button_icon = 'icons/mob/actions/mage_telomancy.dmi'
	name = "Flood"
	expose_caster_on_deflect = FALSE
	desc = "Fire a lance of raw arcyne force that exposes your foe. It is well telegraphed and does a decent amount of damage."
	button_icon_state = "void_beam"
	sound = 'sound/magic/soulshot.ogg'
	spell_color = GLOW_COLOR_WATER
	glow_intensity = GLOW_INTENSITY_HIGH
	attunement_school = ASPECT_NAME_HYDROMANCY

	click_to_activate = TRUE
	cast_range = 8

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	invocations = list("Scintilla Magistra!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_swingdelay_type = SWINGDELAY_CANCEL
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 20 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 3
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	displayed_damage = SPELL_DMG(100)

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/current_mode = 1
	var/torrent_range = 5
	var/torrent_delay = 1.5 SECONDS
	var/torrent_damage = SPELL_DMG(100)
	var/flood_damage = SPELL_DMG(80)
	var/push_dist = 1
	var/torrent_iterations = 3
	var/list/modes = list(
		list("name" = "Flood", "tag" = "FLOOD", "invocation" = "Diluvium Aquae!"),
		list("name" = "Torrent", "tag" = "TRNT", "invocation" = "Torrens Aquae!"),
	)

/datum/action/cooldown/spell/torrent/Grant(mob/grant_to)
	. = ..()
	apply_mode(current_mode)

/datum/action/cooldown/spell/torrent/proc/apply_mode(index)
	var/list/mode = modes[index]
	invocations = list(mode["invocation"])
	build_all_button_icons()
	update_mode_maptext(mode["tag"])

/datum/action/cooldown/spell/torrent/toggle_alt_mode(mob/user)
	current_mode = (current_mode % length(modes)) + 1
	apply_mode(current_mode)
	var/list/mode = modes[current_mode]
	to_chat(user, span_notice("[name]: [mode["name"]] mode."))

/datum/action/cooldown/spell/torrent/proc/update_mode_maptext(tag)
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

/datum/action/cooldown/spell/torrent/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !get_turf(H))
		return FALSE
	var/empowered = FALSE
	if(H.has_status_effect(/datum/status_effect/buff/tide5))
		to_chat(H, span_notice("My tidal flow empowers the [modes[current_mode]["name"]]!"))
		empowered = TRUE
		remove_all_tide_stacks(H)
	INVOKE_ASYNC(src, PROC_REF(windup_flood), owner, target, current_mode, empowered)

/datum/action/cooldown/spell/torrent/proc/do_flood(list/offsets, turf/origin, dir, mob/living/carbon/human/caster, damage, aim_zone, delay = 2)
	playsound(origin, 'sound/foley/water_land1.ogg', 100, TRUE, 5)
	for(var/list/band in offsets)
		var/list/turfs = telegraph_resolve_turfs(origin, dir, band, TRUE)
		for(var/turf/T in turfs)
			new /obj/effect/temp_visual/hydro_burst(T)
			for(var/obj/machinery/light/rogue/Ls in T)
				if(Ls.on)
					Ls.extinguish()
			for(var/mob/living/L in T)
				if(L.stat == DEAD)
					continue
				if(L.anti_magic_check())
					continue
				if(L.guard_deflect_spell("Flood", TRUE, caster, punish_caster = FALSE)) //Punish the initial hit, not any riders
					continue
				if(istype(caster) && !QDELETED(caster))
					if(arcyne_strike(caster, L, null, damage, aim_zone || BODY_ZONE_CHEST, BCLASS_BLUNT, spell_name = "Flood", damage_type = BRUTE, skip_animation = TRUE, exact_zone = TRUE, SPELL_STRIKE_SCALING) == ARCYNE_STRIKE_WARDED)
						continue
				else
					L.adjustBruteLoss(SPELL_DMG_VS(L, damage))
				var/push_dir = get_dir(origin, L) || dir
				if(push_dir in GLOB.cardinals) //Keeps this spell from being super fucked up and evil
					if(NSCOMPONENT(push_dir))
						push_dir |= pick(EAST, WEST)
					else
						push_dir |= pick(NORTH, SOUTH)
				L.safe_throw_at(get_ranged_target_turf(L, push_dir, push_dist), push_dist + 1, 1, caster, force = MOVE_FORCE_STRONG) //+1 So that we can toss diagonally
		sleep(delay)

/datum/action/cooldown/spell/torrent/proc/do_torrent(list/offsets, turf/origin, dir, mob/living/carbon/human/caster, damage, aim_zone, empowered)
	for(var/i in 0 to (torrent_iterations + empowered - 1) * 5)
		var/list/turfs = telegraph_resolve_turfs(get_turf(caster), dir, offsets, TRUE)
		var/index = 0
		for(var/turf/T in turfs)
			index++
			var/obj/effect/temp_visual/geyser/seg = new(T)
			seg.setDir(dir)
			if(index == 1)
				seg.icon_state = "obeliskbeam_start"
			else if(index == (empowered ? 7 : 5))
				seg.icon_state = "obeliskbeam_end"
			if(i%5 == 0) //Damage every second
				var/has_exploded = FALSE
				for(var/mob/living/L in T)
					if(L.stat == DEAD)
						continue
					if(L.anti_magic_check())
						continue
					if(L.guard_deflect_spell((empowered ? "Geyser" : "Torrent"), TRUE, caster, punish_caster = FALSE)) //Punish the initial hit, not any riders
						continue
					if(istype(caster) && !QDELETED(caster))
						if(arcyne_strike(caster, L, null, damage, aim_zone || BODY_ZONE_CHEST, BCLASS_STAB, spell_name = (empowered ? "Geyser" : "Torrent"), damage_type = BRUTE, skip_animation = TRUE, exact_zone = TRUE, SPELL_STRIKE_SCALING) == ARCYNE_STRIKE_WARDED)
							continue
					else
						L.adjustBruteLoss(SPELL_DMG_VS(L, damage))
					if(empowered && !has_exploded && i%10 == 0)
						has_exploded = TRUE
						for(var/turf/E in range(1, T))
							new /obj/effect/temp_visual/hydro_burst(E)
							for(var/mob/living/Le in E)
								if(Le.stat == DEAD)
									continue
								if(Le.anti_magic_check())
									continue
								if(Le.guard_deflect_spell("Geyser", TRUE, caster, punish_caster = FALSE)) //Punish the initial hit, not any riders
									continue
								if(istype(caster) && !QDELETED(caster))
									if(arcyne_strike(caster, Le, null, damage, aim_zone || BODY_ZONE_CHEST, BCLASS_BLUNT, spell_name = "Geyser", damage_type = BRUTE, skip_animation = TRUE, exact_zone = TRUE, SPELL_STRIKE_SCALING) == ARCYNE_STRIKE_WARDED)
										continue
								else
									L.adjustBruteLoss(SPELL_DMG_VS(L, damage))
		sleep(2)

/datum/action/cooldown/spell/torrent/proc/windup_flood(mob/living/H, atom/cast_on, mode, empowered)
	var/list/indicator = list()
	var/turf/last_turf
	var/list/offsets = (mode == 1 ? get_flood_offsets(empowered) : get_torrent_offsets(empowered))
	var/locked_facing = telegraph_cardinal(H.dir)
	if(charge_slowdown)
		H.add_movespeed_modifier(MOVESPEED_ID_SPELL_CASTING, TRUE, 100, override = TRUE, multiplicative_slowdown = charge_slowdown)
	announce_telegraph(H)
	apply_cast_freeze(H, 1 SECONDS)
	ADD_TRAIT(H, TRAIT_SPELLBLOCK, LOCKDOWN_CAST)
	show_cast_effect(H)
	for(var/i in 1 to 5)
		if(QDELETED(H) || H.stat != CONSCIOUS)
			break
		if(get_turf(H) != last_turf)
			last_turf = get_turf(H)
			telegraph_draw(last_turf, locked_facing, indicator, offsets, /obj/effect/temp_visual/telegraph/pillar, TRUE)
		sleep(2)
	clear_cast_effect(H)
	telegraph_clear(indicator)
	if(QDELETED(H) || H.stat != CONSCIOUS)
		clear_cast_freeze(H)
		REMOVE_TRAIT(H, TRAIT_SPELLBLOCK, LOCKDOWN_CAST)
		H.remove_movespeed_modifier(MOVESPEED_ID_SPELL_CASTING)
		return
	if(mode == 1)
		do_flood(get_flood_bands(empowered), get_turf(owner), locked_facing, owner, flood_damage, owner.zone_selected, (empowered ? 2 : 3))
	else
		do_torrent(offsets, get_turf(owner), locked_facing, owner, torrent_damage, owner.zone_selected, empowered)
	clear_cast_freeze(H)
	REMOVE_TRAIT(H, TRAIT_SPELLBLOCK, LOCKDOWN_CAST) //We don't want you casting during the big aoes
	if(charge_slowdown && !QDELETED(H))
		H.remove_movespeed_modifier(MOVESPEED_ID_SPELL_CASTING)

/datum/action/cooldown/spell/torrent/proc/get_flood_bands(empowered)
	var/list/bands = list()
	for(var/i in 1 to (empowered ? 6 : 4))
		bands += list(list(list(-1, i),list(0, i), list(1, i)))
	return bands

/datum/action/cooldown/spell/torrent/proc/get_flood_offsets(empowered)
	var/list/offs = list()
	for(var/i in 1 to (empowered ? 6 : 4))
		offs += list(list(-1, i),list(0, i), list(1, i))
	return offs

/datum/action/cooldown/spell/torrent/proc/get_torrent_offsets(empowered)
	var/list/offs = list()
	for(var/i in 1 to (empowered ? 7 : 5))
		offs += list(list(0, i))
	return offs

/obj/effect/temp_visual/geyser
	name = "geyser"
	icon = 'icons/effects/effects.dmi'
	icon_state = "obeliskbeam_mid"
	color = GLOW_COLOR_WATER
	layer = ABOVE_MOB_LAYER
	plane = GAME_PLANE_UPPER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_color = GLOW_COLOR_WATER
	light_power = 4
	light_outer_range = 3
	duration = 2

#undef LOCKDOWN_CAST
