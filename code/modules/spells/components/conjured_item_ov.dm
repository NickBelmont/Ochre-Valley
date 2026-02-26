/* Component for adding a generic magical outline to a component, make it disappear if not held / worn
by Arcyne user after a duration

	Ochre Valley Modified for adding owner on_remove checks. Say if the conjured item is somewhere and 
	the owner object is removed to not leave random forever conjured items.
*/

/datum/component/conjured_item
	var/mob/living/owner

/datum/component/conjured_item/Initialize(outline_color_override, mob/living/owner_mob)
	. = ..(outline_color_override)
	if(. == COMPONENT_INCOMPATIBLE)
		return
	owner = owner_mob
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(on_parent_deleting))
	if(owner)
		RegisterSignal(owner, COMSIG_PARENT_QDELETING, PROC_REF(on_owner_deleted))

/datum/component/conjured_item/proc/on_owner_deleted(datum/source)
	if(!parent || QDELETED(parent))
		return
	var/obj/item/I = parent
	if(!I)
		return
	if(isturf(I.loc))
		var/turf/T = I.loc
		T.visible_message(span_warning("[I]'s borders begin to shimmer and fade, before it vanishes entirely!"))
	qdel(I)

/datum/component/conjured_item/proc/on_parent_deleting(datum/source)
	if(owner)
		UnregisterSignal(owner, COMSIG_PARENT_QDELETING)