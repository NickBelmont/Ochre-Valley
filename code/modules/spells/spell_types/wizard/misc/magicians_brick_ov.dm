/obj/effect/proc_holder/spell/self/magicians_brick/cast(list/targets, mob/living/user = usr)
	if(src.conjured_brick)
		src.conjured_brick.visible_message(span_warning("[src.conjured_brick] shimmers and fades away."))
		qdel(conjured_brick)
	var/obj/item/rogueweapon/R = new /obj/item/rogueweapon/magicbrick(user.drop_location())
	if(!QDELETED(R))
		R.AddComponent(/datum/component/conjured_item, GLOW_COLOR_ARCANE, user)
	
	if(user.STAINT > 10)
		var/int_scaling = user.STAINT - 10
		R.force = R.force + int_scaling
		R.throwforce = R.throwforce + int_scaling * 2 // 2x scaling for throwing. Let's go.
		R.name = "magician's brick +[int_scaling]"
	user.put_in_hands(R)
	src.conjured_brick = R
	return TRUE

/obj/effect/proc_holder/spell/self/magicians_brick/Destroy()
	if(src.conjured_brick)
		conjured_brick.visible_message(span_warning("[conjured_brick]'s borders begin to shimmer and fade, before it vanishes entirely!"))
		qdel(conjured_brick)
	return ..()