/datum/action/cooldown/spell/torrent
button_icon = 'icons/mob/actions/mage_telomancy.dmi'
	name = "Void Beam"
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
	var/beam_damage = SPELL_DMG(100)
	var/push_dist = 1
	var/expose_duration = 6 SECONDS
	var/beam_slowdown = 2
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

/datum/action/cooldown/spell/torrent/proc/do_flood()
	var/dir_facing = owner.dir

/datum/action/cooldown/spell/torrent/get_flood_bands(empowered)
	var/list/bands = list()
	for(var/i in 1 to (empowered ? 6 : 4))
		bands += list(list(list(-1, i),list(0, i), list(1, i)))
	return bands

/datum/action/cooldown/spell/torrent/proc/get_flood_offsets(empowered)
	var/list/offs = list()
	for(var/i in 1 to (empowered ? 6 : 4))
		offs += list(list(-1, i),list(0, i), list(1, i))
	return offs
