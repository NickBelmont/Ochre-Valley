/datum/action/cooldown/spell/shadowbreach
	name = "Shadowbreach"
	desc = "Summon an unstable crystal of umbral energies, which will periodically release a burst that damages all nearby."
	button_icon = 'icons/mob/actions/classuniquespells/spellblade.dmi'
	button_icon_state = "leyline_anchor"
	sound = 'sound/misc/portalactivate.ogg'
	spell_color = GLOW_COLOR_DARK
	glow_intensity = GLOW_INTENSITY_HIGH
	attunement_school = ASPECT_NAME_UMBRAMANCY


	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	invocations = list("Ancora Lineam!")
	invocation_type = INVOCATION_WHISPER
	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_MAJOR
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_swingdelay_type = SWINGDELAY_PENALTY
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 30 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/obj/effect/umbralfount/active_fount
	var/current_mode = 1
	var/list/modes = list(
		list("name" = "Shadow Breach", "tag" = "BREACH",  "invocation" = "Umbra Coeunt!", "cooldown" = 25 SECONDS),
		list("name" = "Umbral Fountain", "tag" = "FOUNT",  "invocation" = "Umbra Coeunt!", "cooldown" = 30 SECONDS),
	)

/datum/action/cooldown/spell/shadowbreach/Grant(mob/grant_to)
	. = ..()
	apply_mode(current_mode)

/datum/action/cooldown/spell/shadowbreach/proc/apply_mode(index)
	var/list/mode = modes[index]
	invocations = list(mode["invocation"])
	cooldown_time = mode["cooldown"]
	update_mode_maptext(mode["tag"])

/datum/action/cooldown/spell/shadowbreach/toggle_alt_mode(mob/user)
	current_mode = (current_mode % length(modes)) + 1
	apply_mode(current_mode)
	to_chat(user, span_notice("[name]: [modes[current_mode]["name"]] mode."))

/datum/action/cooldown/spell/shadowbreach/proc/update_mode_maptext(tag)
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
		holder.color = GLOW_COLOR_DARK

/datum/action/cooldown/spell/shadowbreach/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/turf/aimed = get_turf(cast_on)
	if(!aimed)
		return FALSE
	if(current_mode == 1)
		INVOKE_ASYNC(src, PROC_REF(shadow_breach), aimed, telegraph_cardinal(owner.dir))
	else
		active_fount = new /obj/effect/umbralfount(aimed, owner)

/datum/action/cooldown/spell/shadowbreach/proc/get_pattern_offsets(flanks = 0)
	var/list/offs = list()
	for(var/d in -1 to 1)
		var/list/band = list(list(0, d))
		if(flanks > 0)
			for(var/s in 1 to flanks)
				band += list(list(-s, d), list(s, d))
		offs += band
	return offs

/datum/action/cooldown/spell/shadowbreach/proc/shadow_breach(turf/aimed, dir)
	for(var/i in 0 to 2)
		var/list/target_turfs = telegraph_resolve_turfs(aimed, dir, get_pattern_offsets(i), TRUE)
		for(var/turf/T in target_turfs)
			new /obj/effect/temp_visual/telegraph/pillar/fadein(T, 1 SECONDS)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(umbral_flow), target_turfs, owner, SPELL_DMG(50), owner.zone_selected, (8 - i) SECONDS, TRUE), 1 SECONDS)
		sleep(1 SECONDS)

/*
/datum/action/cooldown/spell/shadowbreach/proc/do_breach(list/target_turfs)
*/
/obj/effect/umbralfount
	name = "umbral fountain"
	desc = "A condensed mass of arcyne darkness which periodically releases its energies in destructive bursts."
	icon = 'icons/effects/32x64.dmi'
	icon_state = "leylinestable"
	color = GLOW_COLOR_DARK
	opacity = 0
	light_outer_range = 1
	var/mob/living/caster
	var/pulses = 0
	var/max_pulses = 5
	var/pulse_period = 3 SECONDS
	var/pulse_warning = 2 SECONDS
	var/last_pulse
	var/damage = SPELL_DMG(50)
	var/aimed_zone = BODY_ZONE_CHEST
	var/intense = FALSE

/obj/effect/umbralfount/Initialize(mapload, mob/living/castby)
	. = ..()
	caster = castby
	if(istype(caster) && caster.zone_selected)
		aimed_zone = caster.zone_selected
	START_PROCESSING(SSobj, src)

/obj/effect/umbralfount/process()
	if(pulses > max_pulses)
		qdel(src) //Just to make sure it can't linger
	if(last_pulse && world.time < last_pulse + pulse_period)
		return
	addtimer(CALLBACK(src, PROC_REF(telegraph_burst)), pulse_period - pulse_warning)
	addtimer(CALLBACK(src, PROC_REF(burst)), pulse_period)
	last_pulse = world.time

/obj/effect/umbralfount/proc/telegraph_burst()
	for(var/turf/T in range(1, get_turf(src)))
		new /obj/effect/temp_visual/telegraph/pillar/fadein(T, pulse_warning)

/obj/effect/umbralfount/proc/burst()
	pulses++
	if(pulses >= max_pulses || intense)
		new /obj/effect/temp_visual/umbral_explosion(get_turf(src))
		playsound(get_turf(src), 'sound/magic/soulshot.ogg', 100, TRUE, 5)
	for(var/turf/T in range(1, get_turf(src)))
		new /obj/effect/temp_visual/umbral(T)
		if(pulses >= max_pulses || intense)
			new /obj/effect/lingering_shadows(T, 3 SECONDS, caster, aimed_zone)
		for(var/mob/living/L in T)
			if(L.stat == DEAD)
				continue
			if(L.anti_magic_check())
				continue
			if(L.guard_deflect_spell("Umbral Fountain", TRUE, caster, punish_caster = FALSE)) //Punish the initial hit, not any riders
				continue
			if(istype(caster) && !QDELETED(caster))
				if(arcyne_strike(caster, L, null, damage * ((pulses < max_pulses || !intense) ? 1 : 1.8), aimed_zone || BODY_ZONE_CHEST, BCLASS_BURN, spell_name = "Umbral Fountain", damage_type = BURN, skip_animation = TRUE, exact_zone = TRUE, SPELL_STRIKE_SCALING) == ARCYNE_STRIKE_WARDED)
					continue
			else
				L.adjustFireLoss(SPELL_DMG_VS(L, damage))
			apply_darkness_stack(L, 1)
	intense = FALSE
	if(pulses >= max_pulses)
		qdel(src)

/obj/effect/umbralfount/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()
