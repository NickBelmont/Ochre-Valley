/obj/effect/proc_holder/spell/self/conjure_armor/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/H = user
	var/targetac = H.highest_ac_worn()
	if(targetac > 1)
		to_chat(user, span_warning("I must be wearing lighter armor!"))
		revert_cast()
		return FALSE
	if(user.get_num_arms() <= 0)
		to_chat(user, span_warning("I don't have any usable hands!"))
		revert_cast()
		return FALSE
	if(src.conjured_armor)
		qdel(src.conjured_armor)
	switch(checkspot)
		if("ring")
			if(user.get_num_arms() <= 0)
				to_chat(user, span_warning("I don't have any usable hands!"))
				revert_cast()
				return FALSE
			if(H.wear_ring)
				to_chat(user, span_warning("My ring finger must be free!"))
				revert_cast()
				return FALSE
		if("armor")
			if(H.wear_armor)
				to_chat(user, span_warning("I cannot wear this while wearing armor over my chest!"))
				revert_cast()
				return FALSE

	user.visible_message("[user]'s existence briefly jitters, conjuring protection from doomed fates!")
	var/item = objtoequip
	conjured_armor = new item(user)
	user.equip_to_slot_or_del(conjured_armor, slottoequip)
	if(!QDELETED(conjured_armor))
		conjured_armor.AddComponent(/datum/component/conjured_item, GLOW_COLOR_ARCANE, user)
	return TRUE

/obj/effect/proc_holder/spell/self/conjure_armor/Destroy()
	if(src.conjured_armor)
		conjured_armor.visible_message(span_warning("[conjured_armor]'s borders begin to shimmer and fade, before it vanishes entirely!"))
		qdel(conjured_armor)
	return ..()
