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

/datum/action/cooldown/spell/bind_espada
	name = "Bind Weapon"
	desc = "Bind your held sword as a conduit for your spells."
	button_icon = 'icons/mob/actions/classuniquespells/spellblade.dmi'
	button_icon_state = "bind_weapon"
	sound = 'sound/magic/charged.ogg'
	spell_color = GLOW_COLOR_ARCANE
	glow_intensity = GLOW_INTENSITY_LOW

	click_to_activate = FALSE
	self_cast_possible = TRUE

	primary_resource_type = SPELL_COST_STAMINA
	primary_resource_cost = SPELLCOST_SB_POKE

	invocations = list("Vinculum Arcanum.")
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	cooldown_time = 5 SECONDS

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z
	var/obj/item/bound_blade

/datum/action/cooldown/spell/bind_espada/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE

	var/obj/item/weapon = H.get_active_held_item()
	if(!weapon)
		// Empty hands - unbind current weapon if one exists
		if(bound_blade && !QDELETED(bound_blade))
			var/datum/component/bound_espada/old_conduit = bound_blade.GetComponent(/datum/component/bound_espada)
			if(old_conduit)
				qdel(old_conduit)
			to_chat(H, span_notice("The arcyne bond on [bound_blade] fades. I am unbound."))
			playsound(get_turf(H), 'sound/magic/charging.ogg', 30, TRUE)
			bound_blade = null
			return TRUE
		to_chat(H, span_warning("I have no bound weapon to release!"))
		return FALSE
	if(weapon.associated_skill != /datum/skill/combat/swords)
		to_chat(H, span_warning("My tradition is only compatible with swords!"))
		return FALSE
	if(bound_blade && !QDELETED(bound_blade))
		var/datum/component/bound_espada/old_conduit = bound_blade.GetComponent(/datum/component/bound_espada)
		if(old_conduit)
			qdel(old_conduit)
		to_chat(H, span_notice("The arcyne bond on [bound_blade] fades."))

	weapon.AddComponent(/datum/component/bound_espada, owner = H)
	bound_blade = weapon
	to_chat(H, span_notice("I bind [weapon] as my arcyne conduit. It will no longer interfere with my casting."))
	playsound(get_turf(H), 'sound/magic/charged.ogg', 50, TRUE)
	H.visible_message(span_notice("[H] passes a hand over [weapon], which begins to glow faintly."))
	return TRUE


/datum/component/bound_espada
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/outline_color = "#ff00cc"
	var/datum/weakref/owner_ref

/datum/component/bound_espada/Initialize(outline_color_override, mob/living/owner)
	if(!isweapon(parent))
		return COMPONENT_INCOMPATIBLE
	if(outline_color_override)
		outline_color = outline_color_override
	if(owner)
		owner_ref = WEAKREF(owner)
		RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_owner_death))
	var/obj/item/rogueweapon/W = parent
	W.is_implement = TRUE
	W.add_filter(SWIFTCAST_FILTER, 2, list("type" = "outline", "color" = outline_color, "alpha" = 200, "size" = 1))
	//RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/bound_espada/UnregisterFromParent()
	var/obj/item/rogueweapon/W = parent
	if(istype(W))
		W.remove_filter(SWIFTCAST_FILTER)
	W.is_implement = initial(W.is_implement)
	//UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE))
	var/mob/living/owner = owner_ref?.resolve()
	if(owner)
		UnregisterSignal(owner, COMSIG_LIVING_DEATH)

/datum/component/bound_espada/proc/on_owner_death()
	SIGNAL_HANDLER
	var/mob/living/owner = owner_ref?.resolve()
	if(owner)
		var/datum/status_effect/buff/arcyne_momentum/M = owner.has_status_effect(/datum/status_effect/buff/arcyne_momentum)
		if(M)
			M.bound_weapon = null
	qdel(src)
