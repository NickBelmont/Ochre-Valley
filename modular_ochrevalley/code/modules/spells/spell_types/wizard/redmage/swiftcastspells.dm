#define SWIFTCAST_FILTER "swiftcast_filter"
/datum/action/cooldown/spell/projectile/swiftcast/cast()
	var/mob/living/caster = owner
	var/had_swiftcast = caster.has_status_effect(/datum/status_effect/buff/swiftcast) || null
	..()
	if(!had_swiftcast && istype(caster))
		caster.apply_status_effect(/datum/status_effect/buff/swiftcast)

/datum/action/cooldown/spell/projectile/swiftcast/airmagic
	button_icon = 'icons/mob/actions/classuniquespells/spellblade.dmi'
	name = "Air Magic"
	desc = "Cast forth a gust of wind, bound into the shape of a small blade. Toggle arc mode (Shift+G) while the spell is active to arc it over intervening mobs.\
			 Arced attacks deal 25% less damage. Capable of piercing through up to three targets."
	button_icon_state = "air_strike"
	sound = 'sound/combat/hits/whipgrab.ogg'
	spell_color = GLOW_COLOR_WIND
	glow_intensity = GLOW_INTENSITY_LOW

	projectile_type = /obj/projectile/magic/wind_blade
	projectile_type_arc = /obj/projectile/magic/wind_blade/arc
	cast_range = SPELL_RANGE_PROJECTILE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Venti Secant!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	charge_swingdelay_type = SWINGDELAY_PENALTY
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_sound = 'sound/magic/charging_fire.ogg'
	cooldown_time = 10 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_LOW

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN
	var/current_mode = 1
	var/list/modes = list(
		list("name" = "Windblade", "tag" = "BLD", "proj" = /obj/projectile/magic/wind_blade, "cost" = SPELLCOST_MINOR_PROJECTILE, "charge" = CHARGETIME_POKE, "slowdown" = CHARGING_SLOWDOWN_SMALL, "invocation" = "Venti Secant!"),
		list("name" = "Downburst", "tag" = "BRST", "ground" = TRUE, "proj" = /obj/projectile/magic/wind_blade,  "cost" = SPELLCOST_MAJOR_PROJECTILE, "charge" = CHARGETIME_HEAVY, "slowdown" = CHARGING_SLOWDOWN_HEAVY, "invocation" = "Venti Conterite!"),
	)

/datum/action/cooldown/spell/projectile/swiftcast/airmagic/Grant(mob/grant_to)
	. = ..()
	apply_mode(current_mode)

/datum/action/cooldown/spell/projectile/swiftcast/airmagic/proc/apply_mode(index)
	var/list/mode = modes[index]
	projectile_type = mode["proj"]
	primary_resource_cost = mode["cost"]
	charge_time = mode["charge"]
	charge_slowdown = mode["slowdown"]
	invocations = list(mode["invocation"])
	build_all_button_icons()
	update_mode_maptext(mode["tag"])

/datum/action/cooldown/spell/projectile/swiftcast/airmagic/toggle_arc_mode(mob/user)
	current_mode = (current_mode % length(modes)) + 1
	apply_mode(current_mode)
	var/list/mode = modes[current_mode]
	to_chat(user, span_notice("[name]: [mode["name"]] mode."))

/datum/action/cooldown/spell/projectile/swiftcast/airmagic/proc/update_mode_maptext(tag)
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
		holder.color = "#8CDD8C"

/datum/action/cooldown/spell/projectile/swiftcast/airmagic/fire_projectile(atom/target)
	if(!modes[current_mode]["ground"])
		return ..()
	var/turf/epicenter = get_turf(target)
	if(!epicenter)
		return FALSE
	for(var/turf/T in range(1, epicenter))
		new /obj/effect/temp_visual/telegraph/pillar/fadein(T, 10)
	playsound(epicenter, 'sound/magic/charging_fire.ogg', 80, TRUE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(downdraft_erupt), epicenter, owner, 1, 50, src), 10)
	return TRUE

/datum/action/cooldown/spell/projectile/swiftcast/fulgurmagic
	button_icon = 'icons/mob/actions/mage_fulgurmancy.dmi'
	name = "Fulgur Magic"
	desc = "Harness the power of lightning, in either a quick jolt, or larger fulmination."
	button_icon_state = "shock"
	sound = 'sound/magic/lightning.ogg'
	spell_color = GLOW_COLOR_LIGHTNING
	glow_intensity = GLOW_INTENSITY_LOW

	projectile_type = /obj/projectile/magic/arc_bolt/single
	cast_range = SPELL_RANGE_PROJECTILE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_MINOR_PROJECTILE

	invocations = list("Fulgur!")
	invocation_type = INVOCATION_SHOUT

	charge_required = TRUE
	weapon_cast_penalized = TRUE
	charge_time = CHARGETIME_POKE
	hold_drain = 1
	charge_slowdown = CHARGING_SLOWDOWN_SMALL
	charge_swingdelay_type = SWINGDELAY_NORMAL
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 10 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_impact_intensity = SPELL_IMPACT_LOW

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN

	var/current_mode = 1
	var/list/modes = list(
		list("name" = "Jolt", "tag" = "JOLT", "proj" = /obj/projectile/magic/arc_bolt/single, "cost" = SPELLCOST_MINOR_PROJECTILE, "charge" = CHARGETIME_POKE, "slowdown" = CHARGING_SLOWDOWN_SMALL, "invocation" = "Fulgur!"),
		list("name" = "Fulmination", "tag" = "FULM", "ground" = TRUE, "proj" = /obj/projectile/magic/arc_bolt/single,  "cost" = SPELLCOST_MAJOR_PROJECTILE, "charge" = CHARGETIME_HEAVY, "slowdown" = CHARGING_SLOWDOWN_HEAVY, "invocation" = "Venti Conterite!"),
	)

/datum/action/cooldown/spell/projectile/swiftcast/fulgurmagic/Grant(mob/grant_to)
	. = ..()
	apply_mode(current_mode)

/datum/action/cooldown/spell/projectile/swiftcast/fulgurmagic/proc/apply_mode(index)
	var/list/mode = modes[index]
	projectile_type = mode["proj"]
	primary_resource_cost = mode["cost"]
	charge_time = mode["charge"]
	charge_slowdown = mode["slowdown"]
	invocations = list(mode["invocation"])
	build_all_button_icons()
	update_mode_maptext(mode["tag"])

/datum/action/cooldown/spell/projectile/swiftcast/fulgurmagic/toggle_arc_mode(mob/user)
	current_mode = (current_mode % length(modes)) + 1
	apply_mode(current_mode)
	var/list/mode = modes[current_mode]
	to_chat(user, span_notice("[name]: [mode["name"]] mode."))

/datum/action/cooldown/spell/projectile/swiftcast/fulgurmagic/proc/update_mode_maptext(tag)
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
		holder.color = "#ff00cc"

/datum/action/cooldown/spell/projectile/swiftcast/fulgurmagic/fire_projectile(atom/target)
	if(!modes[current_mode]["ground"])
		return ..()
	var/turf/epicenter = get_turf(target)
	if(!epicenter)
		return FALSE
	for(var/turf/T in range(1, epicenter))
		new /obj/effect/temp_visual/telegraph/pillar/fadein(T, 10)
	playsound(epicenter, 'sound/magic/charging_fire.ogg', 80, TRUE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(thunderstrike_erupt), epicenter, owner, 1, 50, src), 10)
	return TRUE

/datum/status_effect/buff/swiftcast
	id = "swiftcast"
	alert_type = /atom/movable/screen/alert/status_effect/buff/swiftcast
	duration = 15 SECONDS

/atom/movable/screen/alert/status_effect/buff/swiftcast
	name = "Swiftcast"
	desc = "My next spell will be cast instantly!"
	icon_state = "buff"

/datum/status_effect/buff/swiftcast/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SWIFTCAST, TRAIT_STATUS_EFFECT)
	var/filter = owner.get_filter(SWIFTCAST_FILTER)
	RegisterSignal(owner, COMSIG_MOB_CAST_SPELL, PROC_REF(remove_swiftcast))
	owner.balloon_alert_to_viewers("<font color='#ff00cc'>Swiftcast!</font>")
	if (!filter)
		owner.add_filter(SWIFTCAST_FILTER, 2, list("type" = "outline", "color" = "#ff00cc", "size" = 1))

/datum/status_effect/buff/swiftcast/proc/remove_swiftcast()
	owner.remove_status_effect(/datum/status_effect/buff/swiftcast)

/datum/status_effect/buff/swiftcast/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_SWIFTCAST, TRAIT_STATUS_EFFECT)
	UnregisterSignal(owner, COMSIG_MOB_CAST_SPELL)
	owner.remove_filter(SWIFTCAST_FILTER)
