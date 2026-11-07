/datum/action/cooldown/spell/shadowbreach
	name = "Shadowbreach"
	desc = ""
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

/datum/action/cooldown/spell/shadowbreach/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/turf/aimed = get_turf(cast_on)
	if(!aimed)
		return FALSE
	active_fount = new /obj/effect/umbralfount(aimed, owner)



// --- Tether object ---

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
