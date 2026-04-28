/obj/item/reagent_containers/food/snacks/grown/cocoa
	name = "cocoa beans"
	desc = "A sizable pod that contains the gooey precursor to chocolate. Must be roasted to properly prepare it."
	icon_state = "coffee"
	seed = /obj/item/seeds/cocoa
	tastes = list("intense bitterness" = 1, "a hint of sweetness" = 1)
	bitesize = 1
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	cooked_type = /obj/item/reagent_containers/food/snacks/grown/roastedcocoa
	rotprocess = null

/obj/item/reagent_containers/food/snacks/grown/roastedcocoa
	name = "roasted cocoa beans"
	desc = "Cocoa beans that have been roasted until the shell has become papery and pliable, now the butter and nibs must be sorted from each other"
	icon = 'modular/Neu_Food/icons/drinks.dmi'
	icon_state = "coffeebeans"
	tastes = list("roasted bitterness" = 1)
	bitesize = 1
	seed = /obj/item/seeds/coffee
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	rotprocess = null
	w_class = WEIGHT_CLASS_TINY
/obj/item/reagent_containers/food/snacks/grown/roastedcocoa/attack_hand(mob/living/user)
	var/found_table = locate(/obj/structure/table) in (loc)
	update_cooktime(user)
	if(isturf(loc)&& (found_table))
		playsound(get_turf(user), 'modular/Neu_Food/sound/kneading_alt.ogg', 90, TRUE, -1)
		if(do_after(user, short_cooktime, target = src))
			add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
			new /obj/item/reagent_containers/food/snacks/tallow/cocoabutter(loc)
			new /obj/item/reagent_containers/food/snacks/grown/cocoanibs(loc)
			qdel(src)
	else
		return ..()
	
/obj/item/reagent_containers/food/snacks/tallow/cocoabutter
	name = "cocoa butter"
	desc = "An oily substance extracted from a cocoa bean, useful as a substitute for tallow, or for making proper chocolate"
	icon = 'modular/Neu_Food/icons/others/fat.dmi'
	icon_state = "tallow"
	tastes = list("grease" = 1, "oil" = 1, "nuttiness" = 1)
	obj_flags = CAN_BE_HIT
	list_reagents = list(/datum/reagent/consumable/nutriment = SNACK_POOR)
	eat_effect = /datum/status_effect/debuff/uncookedfood
	bitesize = 1
	dropshrink = 0.75

/obj/item/reagent_containers/food/snacks/grown/cocoanibs
	name = "cocoa nibs"
	desc = "Bits of separated cocoa bean, fat and shell removed to let just somewhat bitter, chocolately goodness to remain. Can be ground down further into powder."
	icon = 'modular/Neu_Food/icons/drinks.dmi'
	icon_state = "coffeebeans"
	tastes = list("chocolatey bitterness" = 1)
	bitesize = 1
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	mill_result = /obj/item/reagent_containers/food/snacks/grown/cocoapowder
	rotprocess = null
	w_class = WEIGHT_CLASS_TINY

/obj/item/reagent_containers/food/snacks/grown/cocoapowder
	name = "cocoa powder"
	desc = "Powdered cocoa nibs, still requiring additonal fats and sweetening until it can be made into proper chocolate"
	icon = 'modular/Neu_Food/icons/drinks.dmi'
	icon_state = "coffeebeans"
	tastes = list("chocolatey bitterness" = 1)
	bitesize = 1
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	rotprocess = null
	w_class = WEIGHT_CLASS_TINY

/obj/item/reagent_containers/food/snacks/grown/cocoapowder/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/sugar))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'modular/Neu_Food/sound/kneading.ogg', 100, TRUE, -1)
			to_chat(user, span_notice("Mixing in sugar..."))
			if(do_after(user,short_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/grown/sweetcocoapowder(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to work it."))
	else
		return ..()

/obj/item/reagent_containers/food/snacks/grown/sweetcocoapowder
	name = "sweetened cocoa powder"
	desc = "A mix of cocoa and sugar, still needing cocoa butter to properly come together into chocolate"
	icon = 'modular/Neu_Food/icons/drinks.dmi'
	icon_state = "coffeebeans"
	tastes = list("powdery chocolate" = 1)
	bitesize = 1
	list_reagents = list(/datum/reagent/consumable/nutriment = 1)
	rotprocess = null
	w_class = WEIGHT_CLASS_TINY

/obj/item/reagent_containers/food/snacks/grown/sweetcocoapowder/attackby(obj/item/I, mob/living/user, params)
	var/found_table = locate(/obj/structure/table) in (loc)
	update_cooktime(user)
	if(istype(I, /obj/item/reagent_containers/food/snacks/tallow/cocoabutter))
		if(isturf(loc)&& (found_table))
			playsound(get_turf(user), 'modular/Neu_Food/sound/kneading.ogg', 100, TRUE, -1)
			to_chat(user, span_notice("Working in cocoa butter..."))
			if(do_after(user,short_cooktime, target = src))
				add_sleep_experience(user, /datum/skill/craft/cooking, user.STAINT)
				new /obj/item/reagent_containers/food/snacks/chocolate(loc)
				qdel(I)
				qdel(src)
		else
			to_chat(user, span_warning("You need to put [src] on a table to work it."))
	else
		return ..()
