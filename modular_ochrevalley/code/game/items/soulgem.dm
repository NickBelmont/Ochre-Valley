/obj/item/soulgem
	name = "Luxseal gem"
	desc = "A strange arcyne construct, either designed to preserve the souls of the dying, or entrap enemies of the Lady of Bones, depending on who's believed."
	icon = 'icons/roguetown/items/gems.dmi'
	icon_state = "necro_crystal_dormant"
	drop_sound = 'modular_ochrevalley/sounds/capture_crystal/drop_ring.ogg'
	pickup_sound = 'modular_ochrevalley/sounds/capture_crystal/pickup_ring.ogg'
	throwforce = 0
	force = 0
	w_class = WEIGHT_CLASS_TINY

	var/datum/weakref/body_tracker
	var/mob/living/carbon/human/trapped

/obj/item/soulgem/attack(mob/living/M, mob/living/user)
	if(trapped && body_tracker.resolve() == M)
		if(tgui_alert(user, "Release the [trapped] back into their body?", "Release Soul",list("No","Yes")) == "Yes")
			var/datum/beam/transfer_beam = M.Beam(user, icon_state = "drain_life", time = 5 SECONDS)
			user.visible_message(span_warning("The light within [src] begins to fade, filtering back into [M]"), vision_distance = 1)
			if(!do_after(user, 5 SECONDS, target = M))
				qdel(transfer_beam)
				return
			user.visible_message(span_warning("[src]'s ominous light fades, as [M] begins to stir..."), vision_distance = 1)
			M.key = trapped.key
			qdel(trapped)
			body_tracker = null
			icon_state = "necro_crystal_dormant"
	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(tgui_alert(M, "Are you certain you'd like your soul trapped by [user]? You will be unable to return to your body by yourself without OOC escape", "Become Entrapped",list("No","Yes")) == "Yes")
			user.visible_message(span_warning("[user]'s [src] begins drawing in [H]'s lyfeforce..."), span_warning("The [src] begins to siphon [H]'s soul into itself..."), vision_distance = 1)
			var/datum/beam/transfer_beam = user.Beam(H, icon_state = "drain_life", time = 5 SECONDS)
			if(!do_after(user, 5 SECONDS, target = H))
				qdel(transfer_beam)
				return
			user.visible_message(span_warning("[user]'s [src] glows ominously as [H] falls still."), span_warning("The [src] glows brilliantly as [H]'s soul fills it"), vision_distance = 1)
			log_admin("[key_name(M)] has had their soul trapped by [key_name(user)].")
			H.set_resting(TRUE, FALSE)
			H.eyesclosed = 1
			body_tracker = WEAKREF(M)
			trapped = new /mob/living/carbon/human(src)
			trapped.copy_physical_features(H)
			trapped.real_name = "Soul of [H.real_name]"
			trapped.key = H.key
			icon_state = "necro_crystal"
			if(M == user)
				user.dropItemToGround(src)

/obj/item/soulgem/pickup(mob/user)
	if(user == trapped)
		return
	. = ..()

	
	
	
