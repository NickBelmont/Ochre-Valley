/obj/effect/proc_holder/spell/self/conjure_armor/conjure_dragonhide/Destroy()
	if(src.conjured_armor)
		conjured_armor.visible_message(span_warning("[conjured_armor]'s borders begin to shimmer and fade, before it vanishes entirely!"))
		qdel(conjured_armor)
	return ..()



