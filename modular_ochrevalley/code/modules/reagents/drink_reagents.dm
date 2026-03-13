/datum/reagent/water/bufftea
	description = ""
	reagent_state = LIQUID

/datum/reagent/water/bufftea/on_mob_life(mob/living/carbon/M) 
	//These may only give +1, but we still don't want stacking, especially since they stack with buff potions.
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(istype(R, /datum/reagent/water/bufftea) && R != src)
			holder.remove_reagent(R.type, 10)
			// Rapidly purge stacking buffs
	..()

/datum/reagent/water/bogtea
	name = "Bog Tea"
	description = "Before the bog guard was dissolved, this was their unoffical drink of choice. Doesn't get you high"
	reagent_state = LIQUID
	color = "#addfad" 
	taste_description = "resinous herbaceousness"
	overdose_threshold = 0
	metabolization_rate = REAGENTS_METABOLISM
	alpha = 173

/datum/reagent/water/minttea
    name = "Mint Tea"
    description = "Steeped minthra. Etruscans love this stuff before going out for courting."
    reagent_state = LIQUID
    color = "#e5ffe5"
    taste_description = "peppermint"
    overdose_threshold = 0
    metabolization_rate = REAGENTS_METABOLISM
    alpha = 173

/datum/reagent/water/wormwoodtea
    name = "Wormwood Tea"
    description = "Usually this is used as an intense bittering agent. Why would you drink this pure?"
    reagent_state = LIQUID
    color = "#2f4f4f"
    taste_description = "extreme bitterness"
    overdose_threshold = 0
    metabolization_rate = REAGENTS_METABOLISM
    alpha = 173

/datum/reagent/water/wormwoodtea/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/HM = M
		if(HM.culinary_preferences[CULINARY_FAVOURITE_DRINK] != type) //You shouldn't hate the bitterness if you love the drink!
			M.add_stress(/datum/stressevent/bittertea)

/datum/reagent/water/sagetea
    name = "Sage Tea"
    description = "A pungent flavour, but favoured by Grenzelhoftian grandmothers to cure the sniffles."
    reagent_state = LIQUID
    color = "#c2b280"
    taste_description = "herbal pepperiness"
    overdose_threshold = 0
    metabolization_rate = REAGENTS_METABOLISM
    alpha = 173

/datum/reagent/water/valeriantea
    name = "Valerian Tea"
    description = "Most people don’t drink this for its taste, but because it is reputed to ward off nightmares."
    reagent_state = LIQUID
    color = "#967117"
    taste_description = "musky bitterness"
    overdose_threshold = 0
    metabolization_rate = REAGENTS_METABOLISM
    alpha = 173

/datum/reagent/water/baothatea
    name = "Baothan Tea"
    description = "Those with little regard for their lyfe or Baothans drink this."
    reagent_state = LIQUID
    color = "#ba55d3"
    taste_description = "sweet oblivion"
    overdose_threshold = 0
    metabolization_rate = REAGENTS_METABOLISM

/datum/reagent/water/baothatea/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(!HAS_TRAIT(M, TRAIT_DEPRAVED) && volume > 0.09) //Baothans are immune, for culty reasons.
		if(isdwarf(M))
			M.add_nausea(1)
			M.adjustToxLoss(1) 
		else
			M.add_nausea(3) 
			M.adjustToxLoss(2.5) //A bit stronger than berry poison. Will put you into crit with a sip. 

/datum/reagent/water/bufftea/eyebrighttea
    name = "Euphrasia Tea"
    description = "Old people drink this to keep their eyes sharp. Some say elves distill its oil for a better effect."
    reagent_state = LIQUID
    color = "#f3e5ab"
    taste_description = "astringent, herbal bitterness"
    overdose_threshold = 0
    metabolization_rate = REAGENTS_METABOLISM

/datum/reagent/water/bufftea/eyebrighttea/on_mob_life(mob/living/carbon/M)
	M.apply_status_effect(/datum/status_effect/buff/tea/perceptiontea)
	return ..()

/datum/reagent/water/bloomtea
    name = "Bloom Tea"
    description = "The drink of choice of the Celestial Academy, reputed to recover magical fatigue. Everyone knows they just like the pretty, deep blue colour."
    reagent_state = LIQUID
    color = "#000080"
    taste_description = "tingling electricity"
    overdose_threshold = 0
    metabolization_rate = REAGENTS_METABOLISM

/datum/reagent/water/bloomtea/on_mob_life(mob/living/carbon/M)
	. = ..()
	if(!HAS_TRAIT(M,TRAIT_INFINITE_STAMINA))
		M.energy_add(10) //Twice as strong as coffee/tea, but no stat buff.

/datum/reagent/water/eorantea
    name = "Eoran Tea"
    description = "Every child from Gronn to Naledi knows - if you are sick, drink this. You will feel better. At least that is what parents insist on."
    reagent_state = LIQUID
    color = "#e9d66b"
    taste_description = "citric earthiness"
    overdose_threshold = 0
    metabolization_rate = REAGENTS_METABOLISM

/datum/reagent/water/eorantea/on_mob_life(mob/living/carbon/M) //Just the same as rose tea. Both herb-based, and calendula's the health one.
	. = ..()
	if (M.mob_biotypes & MOB_BEAST)
		M.adjustFireLoss(0.5  * REAGENTS_EFFECT_MULTIPLIER)
	else
		M.adjustBruteLoss(-0.1  * REAGENTS_EFFECT_MULTIPLIER)
		M.adjustFireLoss(-0.1  * REAGENTS_EFFECT_MULTIPLIER)
		M.adjustOxyLoss(-0.1, 0)
		var/list/our_wounds = M.get_wounds()
		if (LAZYLEN(our_wounds))
			var/upd = M.heal_wounds(1)
			if (upd)
				M.update_damage_overlays()

/datum/reagent/water/ashtea
    name = "Ashtray Tea"
    description = "This is like zig butts steeped in hot water. Yummy."
    reagent_state = LIQUID
    color = "#4b5320"
    taste_description = "zig roaches"
    overdose_threshold = 0

/datum/reagent/water/ashtea/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.add_nausea(1) //Makes you sort of sick.

/datum/reagent/water/bufftea/psytea
    name = "Pilgrim Tea"
    description = "A favourite among psydonic pilgrims, the hardy plant makes for a surprisingly palatable tea."
    reagent_state = LIQUID
    color = "#87a96b"
    taste_description = "nostalgic herbaceousness"
    overdose_threshold = 0

/datum/reagent/water/bufftea/psytea/on_mob_life(mob/living/carbon/M)
	M.apply_status_effect(/datum/status_effect/buff/tea/willpowertea)
	return ..()

/datum/reagent/water/bufftea/dandelioncoffee
    name = "Dandelion Coffee"
    description = "Ravoxians and Graggarites alike drink this when not feasting, for it's reputed to give you a lion’s heart."
    reagent_state = LIQUID
    color = "#fdee00"
    taste_description = "dark, nutty bitterness"
    overdose_threshold = 0

/datum/reagent/water/bufftea/dandelioncoffee/on_mob_life(mob/living/carbon/M)
	M.apply_status_effect(/datum/status_effect/buff/tea/constitutiontea)
	return ..()

/datum/reagent/water/nettletea
    name = "Nettle Tea"
    description = "Drunk by soldiers who want to freshen up their water rations in the field."
    reagent_state = LIQUID
    color = "#87a96b"
    taste_description = "mild herbaceousness"
    overdose_threshold = 0

/datum/reagent/water/chamomiletea
    name = "Chamomile Tea"
    description = "9 out of 10 barber-surgeons prescribe this for tooth aches. The last one just pulls it out."
    reagent_state = LIQUID
    color = "#b8860b"
    taste_description = "herbaceous grassiness"
    overdose_threshold = 0
