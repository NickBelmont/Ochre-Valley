/datum/action/cooldown/spell/projectile/tempest
	button_icon = 'icons/mob/actions/classuniquespells/spellblade.dmi'
	name = "Tempest"
	desc = "Project an unstable sphere of air, which erupts into a mighty tempest when it hits a target. \
	The tempest persists for 10 seconds, slashing anyone who remains in the area.\n\n\
	Targets your aimed zone, with reduced accuracy for precise zones. \
	Each strike done every second deals 20 damage."
	button_icon_state = "blade_storm"
	sound = 'sound/magic/scrapeblade.ogg'
	spell_color = GLOW_COLOR_WIND
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_AEROMANCY

	projectile_type = /obj/projectile/magic/tempest_seed
	cast_range = SPELL_RANGE_PROJECTILE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MAJOR_AOE

	invocations = list("Tempestas mordax!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_MAJOR
	charge_slowdown = CHARGING_SLOWDOWN_MEDIUM
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 20 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_MEDIUM
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_SAME_Z // Projectile that spawns persistent AOE - same-Z to prevent cross-floor cheese

	/// How long the tempest persists
	var/tempest_duration = 10 SECONDS
	/// Damage per tick
	var/tempest_damage = 20
	/// Radius of the damage ring (center tile is safe)
	var/tempest_radius = 1

/datum/action/cooldown/spell/projectile/tempest/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	var/obj/projectile/magic/tempest_seed/seed = to_fire
	if(istype(seed))
		seed.spell_ref = src

// --- Seed projectile — detonates into the cloud on impact ---

/obj/projectile/magic/tempest_seed
	name = "condensed tempest"
	icon_state = "declone"
	damage = 0
	nodamage = TRUE
	arcshot = TRUE
	speed = 3
	range = 7
	guard_deflectable = TRUE
	hitsound = 'sound/combat/hits/bladed/genstab (1).ogg'
	var/datum/action/cooldown/spell/spell_ref

/obj/projectile/magic/tempest_seed/on_hit(atom/target)
	. = ..()
	var/turf/impact = get_turf(target)
	if(impact)
		new /obj/effect/tempest(impact, firer, spell_ref)
	qdel(src)
	return BULLET_ACT_HIT

/obj/projectile/magic/tempest_seed/Range()
	. = ..()
	if(QDELETED(src))
		return
	if(range <= 0)
		var/turf/T = get_turf(src)
		if(T)
			new /obj/effect/tempest(T, firer, spell_ref)
		qdel(src)

// --- The persistent cloud effect ---

/obj/effect/tempest
	name = "tempest"
	desc = "A whirling storm of slicing winds!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparks"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_MOB_LAYER
	light_outer_range = 2
	light_color = GLOW_COLOR_AIR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/mob/living/caster
	var/datum/action/cooldown/spell/source_spell
	var/ticks_remaining
	var/tick_damage = 20
	var/effect_radius = 1
	var/list/daggers = list()

/obj/effect/tempest/Initialize(mapload, mob/living/summoner, datum/action/cooldown/spell/spell_ref)
	. = ..()
	caster = summoner
	source_spell = spell_ref

	// Pull values from the spell if available
	var/tempest_duration = 10 SECONDS
	if(istype(spell_ref, /datum/action/cooldown/spell/projectile/tempest))
		var/datum/action/cooldown/spell/projectile/tempest/IT = spell_ref
		tempest_duration = IT.tempest_duration
		tick_damage = IT.tempest_damage
		effect_radius = IT.tempest_radius

	ticks_remaining = tempest_duration / (1 SECONDS)

	// Spawn daggers at center then burst outward to surrounding tiles
	var/turf/center = get_turf(src)
	for(var/turf/T in range(effect_radius, center))
		if(T == center)
			continue
		// Spawn on center tile
		var/obj/effect/temp_visual/tempest/D = new(center, tempest_duration + 2 SECONDS, FALSE)
		daggers += D
		// Calculate pixel offset to destination tile
		var/dx = (T.x - center.x) * 32
		var/dy = (T.y - center.y) * 32
		// Slide outward over 3 ticks then start spinning
		animate(D, pixel_x = dx, pixel_y = dy, time = 3, easing = EASE_OUT)

	playsound(src, 'sound/magic/scrapeblade.ogg', 80, TRUE)
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, tempest_duration + 1 SECONDS)

/obj/effect/tempest/Destroy()
	caster = null
	source_spell = null
	QDEL_LIST(daggers)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/effect/tempest/process(delta_time)
	if(ticks_remaining <= 0)
		qdel(src)
		return

	ticks_remaining--
	playsound(src, pick('sound/combat/hits/bladed/genstab (1).ogg', 'sound/combat/hits/bladed/genstab (2).ogg', 'sound/combat/hits/bladed/genstab (3).ogg'), 60, TRUE)

	var/turf/center = get_turf(src)
	for(var/turf/T in range(effect_radius, center))
		if(T == center)
			continue
		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				continue
			if(source_spell?.spell_guard_check(L))
				ticks_remaining = max(0, ticks_remaining - 1)
				continue
			if(ishuman(L) && ishuman(caster))
				var/mob/living/carbon/human/HC = caster
				var/target_zone = HC.zone_selected || BODY_ZONE_CHEST
				arcyne_strike(HC, L, null, tick_damage, target_zone, \
					BCLASS_CUT, spell_name = "Tempest", \
					damage_type = BRUTE, \
					skip_animation = TRUE, skip_message = TRUE, \
					allow_shield_check = TRUE)
			else
				L.adjustBruteLoss(tick_damage)
			new /obj/effect/temp_visual/spell_impact(get_turf(L), GLOW_COLOR_METAL, SPELL_IMPACT_MEDIUM)

// --- Spinning dagger visual effect ---

/obj/effect/temp_visual/tempest
	name = "tempestous air"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	color = "#8CDD8C"
	duration = 1 SECONDS
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	randomdir = FALSE

/obj/effect/temp_visual/tempest/Initialize(mapload, custom_duration, start_spin = FALSE)
	if(custom_duration)
		duration = custom_duration
	. = ..()
	if(start_spin)
		SpinAnimation(5, -1, pick(TRUE, FALSE))

/obj/effect/temp_visual/tempest/proc/start_spinning()
	SpinAnimation(5, -1, pick(TRUE, FALSE))
