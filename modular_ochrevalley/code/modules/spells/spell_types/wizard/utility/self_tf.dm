/datum/action/cooldown/spell/self_tf
	name = "Self-Transmutation"
	desc = "Seal yourself within your currently held item. Note: You will not be able to free yourself without OOC escape"

	invocations = list("Unita Materia!")
	invocation_type = INVOCATION_SHOUT
	//To prevent whatever chees you could somehow pull off, make it like casting a ward, no moving, easily canceled
	charge_required = TRUE
	charge_swingdelay_type = SWINGDELAY_CANCEL
	charge_time = 6 SECONDS
	charge_slowdown = 3
	charge_sound = 'sound/magic/charging.ogg'
	cooldown_time = 1 MINUTES
	blocks_defense_while_channeling = TRUE

	associated_skill = /datum/skill/magic/arcane
	spell_tier = 1
	spell_impact_intensity = SPELL_IMPACT_NONE

	point_cost = 0

	charge_swingdelay_type = SWINGDELAY_CANCEL
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_SAME_Z | SPELL_REQUIRES_NO_MOVE

/datum/action/cooldown/spell/self_tf/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/H = owner
	if(!istype(H))
		return FALSE
	var/obj/item/the_item = H.get_active_held_item()
	if(!the_item)
		return FALSE
	if(tgui_alert(H, "Are you certain you'd like to transform into [the_item]? You will be unable to return by yourself without OOC escape", "Become Entrapped",list("No","Yes")) == "No")
		return FALSE
	H.dropItemToGround(the_item)
	the_item.mob_possession = H
	H.forceMove(the_item)
	the_item.visible_message(src, span_warning("[H] is merged into [the_item]!"))

/obj/item/book/granter/spell/bonechill/self_tf
	name = "Scroll of Self-Transmutation"
	spell = /datum/action/cooldown/spell/self_tf
	spellname = "Self-Transmutation"
	icon_state ="scrolldarkred"
	oneuse = TRUE
	remarks = list()

/obj/item/book/granter/spell/bonechill/self_tf/loadout
	needLit = FALSE
	pages_to_mastery = 0

/datum/loadout_item/self_tf_scroll //I'd have this even further up the list if I could, but I don't want to needlessly edit the Azure loadouts
	name = "Scroll of Self-Transmutation"
	path = /obj/item/book/granter/spell/bonechill/self_tf/loadout
