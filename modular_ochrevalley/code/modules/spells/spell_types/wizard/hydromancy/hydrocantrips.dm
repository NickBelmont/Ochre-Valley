#define STACK_COOLDOWN (2 SECONDS)
#define STACK_KEY "tide_cooldown"
/datum/action/cooldown/spell/projectile/aqueous_barrage
	button_icon = 'icons/mob/actions/mage_telomancy.dmi'
	name = "Aqueous Barrage"
	desc = "Advanced Offensive Magyck, refined over millennium and turned into a true Telomancer's ultimate thesis! Toggle firing mode (Shift+G) while the spell is active: \
	Cascade looses a rapid stream of bolts at a single foe, Seeker sends homing orbs that pass harmlessly through all but their mark, and Soulshot fires a piercing beam through several foes."
	button_icon_state = "arcyne_bolt"
	sound = 'sound/magic/vlightning.ogg'
	spell_color = GLOW_COLOR_WATER
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_HYDROMANCY

	projectile_type = /obj/projectile/magic/bubble
	cast_range = SPELL_RANGE_PROJECTILE
	point_cost = 3

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Impetus Aqua!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_swingdelay_type = SWINGDELAY_NORMAL
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 5.5 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_MEDIUM

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/flurry_shots = 3
	var/flurry_shot_delay = 2
	var/flurry_spread = 10

/datum/action/cooldown/spell/projectile/aqueous_barrage/fire_projectile(atom/target)
	INVOKE_ASYNC(src, PROC_REF(fire_stream), target)
	return TRUE

/datum/action/cooldown/spell/projectile/aqueous_barrage/proc/fire_stream(atom/target)
	for(var/i in 1 to flurry_shots)
		if(QDELETED(src) || QDELETED(owner) || !isturf(owner.loc))
			return
		var/obj/projectile/to_fire = new projectile_type(owner.loc)
		ready_projectile(to_fire, target, owner, i)
		if(flurry_spread)
			var/base_angle = to_fire.Angle
			if(isnull(base_angle))
				base_angle = Get_Angle(owner, target)
			to_fire.setAngle(base_angle + rand(-flurry_spread, flurry_spread))
		to_fire.fire()
		if(i < flurry_shots)
			sleep(flurry_shot_delay)

/obj/projectile/magic/bubble
	name = "bubble"
	icon_state = "gumball"
	color = GLOW_COLOR_WATER
	damage = SPELL_DMG(20)
	nodamage = FALSE
	damage_type = BRUTE
	woundclass = BCLASS_BLUNT
	speed = MAGE_PROJ_MEDIUM
	hitsound = 'sound/combat/hits/blunt/bluntsmall (1).ogg'

/obj/projectile/magic/bubble/on_hit(atom/target, blocked)
	..()
	if(ismob(target) && isliving(firer))
		var/mob/living/caster = firer
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] fizzles on contact with [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
		if(out_of_effective_range())
			return
		if(blocked >= 100)
			return
		if(!istype(caster))
			return
		if(!caster.mob_timers[STACK_KEY] || world.time > caster.mob_timers[STACK_KEY])
			apply_tide_stack(caster, 1)
		caster.mob_timers[STACK_KEY] = world.time + STACK_COOLDOWN

/datum/action/cooldown/spell/depth_charge
	button_icon = 'icons/mob/actions/mage_kinesis.dmi'
	name = "Depth Charge"
	desc = "Compress gravitational force onto a single point, crushing the aimed body part. It is telegraphed and can be walked out of. \
	Crushes through armor with exceptional force. Slows struck targets briefly."
	button_icon_state = "crush"
	sound = 'sound/magic/repulse.ogg'
	spell_color = GLOW_COLOR_WATER
	glow_intensity = GLOW_INTENSITY_MEDIUM
	attunement_school = ASPECT_NAME_HYDROMANCY

	click_to_activate = TRUE
	cast_range = SPELL_RANGE_GROUND

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Vis Aquae!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_MINOR
	charge_swingdelay_type = SWINGDELAY_NORMAL
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 8 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 2
	spell_impact_intensity = SPELL_IMPACT_HIGH
	displayed_damage = SPELL_DMG(60)

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z

	var/telegraph_delay = TELEGRAPH_SKILLSHOT
	var/charge_damage = SPELL_DMG(60)
	var/got_stack = FALSE //With how I did this, has to be an object variable to avoid more than 1 stack

/datum/action/cooldown/spell/depth_charge/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/turf/T = get_turf(cast_on)
	if(!T)
		return FALSE

	var/turf/source_turf = get_turf(H)
	if(T.z > H.z)
		source_turf = get_step_multiz(source_turf, UP)
	if(T.z < H.z)
		source_turf = get_step_multiz(source_turf, DOWN)
	if(!(T in get_hear(cast_range, source_turf)))
		to_chat(H, span_warning("I can't cast where I can't see!"))
		return FALSE

	new /obj/effect/temp_visual/telegraph(T, telegraph_delay)
	got_stack = FALSE
	playsound(T, 'sound/foley/water_land3.ogg', 60, TRUE, soundping = FALSE)
	addtimer(CALLBACK(src, PROC_REF(charge_strike), T, H), telegraph_delay)
	addtimer(CALLBACK(src, PROC_REF(telegraph_strike), T, 1), telegraph_delay)
	addtimer(CALLBACK(src, PROC_REF(charge_strike), T, H, 1), telegraph_delay*2)
	return TRUE

/datum/action/cooldown/spell/depth_charge/proc/telegraph_strike(turf/epicenter, radius = 0)
	for(var/turf/T in range(radius, epicenter))
		if(radius > 0 && T == epicenter)
			continue
		new /obj/effect/temp_visual/telegraph(T, telegraph_delay)

/datum/action/cooldown/spell/depth_charge/proc/charge_strike(turf/epicenter, mob/living/carbon/human/caster, radius = 0)
	playsound(epicenter, 'sound/foley/water_land1.ogg', 100, TRUE, soundping = FALSE)
	for(var/turf/T in range(radius, epicenter))
		if(radius > 0 && T == epicenter)
			continue
		new /obj/effect/temp_visual/hydro_burst(T)
		for(var/mob/living/L in T.contents)
			if(L.anti_magic_check())
				L.visible_message(span_warning("The water splashed harmlessly against [L]!"))
				playsound(get_turf(L), 'sound/magic/magic_nulled.ogg', 100)
				continue
			if(spell_guard_check(L, TRUE))
				L.visible_message(span_warning("[L] stands firm against the tide!"))
				continue

			var/target_zone = caster?.zone_selected || pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST)
			if(arcyne_strike(caster, L, null, charge_damage, target_zone, BCLASS_BLUNT, \
				spell_name = "Depth Charge", damage_type = BRUTE, \
				skip_animation = TRUE, SPELL_STRIKE_SCALING) == ARCYNE_STRIKE_WARDED)
				continue
			if(!got_stack) // Make sure you can't pile up a bunch of dying mobs to farm stacks
				apply_tide_stack(caster, 1)
				got_stack = TRUE
			new /obj/effect/temp_visual/spell_impact(get_turf(L), spell_color, spell_impact_intensity)

