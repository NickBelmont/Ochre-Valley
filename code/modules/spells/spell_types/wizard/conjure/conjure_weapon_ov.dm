/obj/effect/proc_holder/spell/invoked/conjure_weapon/cast(list/targets, mob/living/user = usr)
	// Ochre Valley - Modified to add 'UNCONJURE.'
	var/list/choices = list()
	if(src.conjured_weapon)
		choices["-- Unconjure Current Weapon --"] = "UNCONJURE"
	for(var/name in weapons)
		choices[name] = weapons[name]
	var/selection = input(user, "Choose a weapon", "Conjure Weapon") as anything in choices
	if(!selection)
		return
	if(choices[selection] == "UNCONJURE")
		if(src.conjured_weapon)
			src.conjured_weapon.visible_message(span_warning("[src.conjured_weapon] shimmers and fades away."))
			qdel(src.conjured_weapon)
			src.conjured_weapon = null
		return TRUE
	var/weapon_path = choices[selection]
	if(src.conjured_weapon)
		src.conjured_weapon.visible_message(span_warning("[src.conjured_weapon] shimmers and fades away."))
		qdel(src.conjured_weapon)
		src.conjured_weapon = null
	var/obj/item/rogueweapon/R = new weapon_path(user.drop_location())
	R.blade_dulling = DULLING_SHAFT_CONJURED
	if(!QDELETED(R))
		R.AddComponent(/datum/component/conjured_item, GLOW_COLOR_ARCANE, user)
	user.put_in_hands(R)
	user.visible_message(span_warning("[R] forms in [user]'s hands!"))
	src.conjured_weapon = R
	return TRUE

/obj/effect/proc_holder/spell/invoked/conjure_weapon/Destroy()
	if(src.conjured_weapon)
		conjured_weapon.visible_message(span_warning("[conjured_weapon]'s borders begin to shimmer and fade, before it vanishes entirely!"))
		qdel(src.conjured_weapon)
	return ..()