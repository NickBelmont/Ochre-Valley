#define MT_WIND "wind"
#define WIND_DR_DURATION 1 SECONDS

/datum/action/cooldown/spell/projectile/wind_blade
	button_icon = 'icons/mob/actions/classuniquespells/spellblade.dmi'
	name = "Wind blade"
	desc = "Whip up the air into three blades of cutting wind \
	Toggle arc mode (Shift+G) to lob over obstacles at reduced damage."
	button_icon_state = "air_strike"
	sound = 'sound/combat/hits/whipgrab.ogg'
	spell_color = GLOW_COLOR_WIND
	glow_intensity = GLOW_INTENSITY_LOW

	projectile_type = /obj/projectile/magic/wind_blade
	projectile_type_arc = /obj/projectile/magic/wind_blade/arc
	cast_range = SPELL_RANGE_PROJECTILE
	projectiles_per_fire = 3

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Ventis secare!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_swingdelay_type = SWINGDELAY_PENALTY
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 6 SECONDS
	attunement_school = ASPECT_NAME_AEROMANCY
	var/spread_step = 4

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_LOW

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

/datum/action/cooldown/spell/projectile/wind_blade/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	var/base_angle = to_fire.Angle
	if(isnull(base_angle))
		base_angle = Get_Angle(user, target)
	var/center_index = (projectiles_per_fire + 1) / 2
	to_fire.Angle = base_angle + ((iteration - center_index) * spread_step)
	// Only the center stone can roll for blunt crit/knockout
	if(iteration != center_index)
		to_fire.woundclass = null

/obj/projectile/magic/wind_blade
	name = "wind blade"
	guard_deflectable = TRUE
	expose_caster_on_deflect = TRUE
	range = 7 // Let you pressure a whole screen, in theory
	icon_state = "chronobolt"
	max_range = MAGE_LONG_PROJ_RANGE // Effective range is lower than its maximal range
	damage = 30
	damage_type = BRUTE
	woundclass = BCLASS_CUT
	armor_penetration = PEN_LIGHT
	speed = MAGE_PROJ_FAST
	flag = "slash"
	color = "#8CDD8C"
	hitsound = 'sound/combat/hits/bladed/genslash (1).ogg'
	var/reduced_damage = 7 // 34 + 7 * 4 = 62. A point blank is gonna be as much damage as most of your melee Ferramantic attack, on purpose as a ranged pressure tool as not as a replacement to compete with your fancy NotSpecial

/obj/projectile/magic/wind_blade/arc
	name = "arced wind blade"
	damage = 25
	arcshot = TRUE

/obj/projectile/magic/wind_blade/prehit(atom/target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.mob_timers[MT_WIND] && world.time < M.mob_timers[MT_WIND] + WIND_DR_DURATION)
			damage = reduced_damage
			no_crit = TRUE
		else
			M.mob_timers[MT_WIND] = world.time
	return ..()

/obj/projectile/magic/wind_blade/on_hit(target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.anti_magic_check())
			visible_message(span_warning("[src] shatters harmlessly against [target]!"))
			playsound(get_turf(target), 'sound/magic/magic_nulled.ogg', 100)
			qdel(src)
			return BULLET_ACT_BLOCK
	. = ..()

#undef MT_WIND
#undef WIND_DR_DURATION
