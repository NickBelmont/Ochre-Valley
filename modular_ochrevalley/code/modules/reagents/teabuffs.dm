/datum/status_effect/buff/tea/perceptiontea
	id = "pertea"
	alert_type = /atom/movable/screen/alert/status_effect/buff/tea/per
	effectedstats = list(STATKEY_PER = 1)
	duration = 3 SECONDS

/datum/status_effect/buff/tea/constitutiontea
	id = "contea"
	alert_type = /atom/movable/screen/alert/status_effect/buff/tea/con
	effectedstats = list(STATKEY_CON = 1)
	duration = 3 SECONDS

/datum/status_effect/buff/tea/willpowertea
	id = "wiltea"
	alert_type = /atom/movable/screen/alert/status_effect/buff/tea/wil
	effectedstats = list(STATKEY_WIL = 1)
	duration = 3 SECONDS

/atom/movable/screen/alert/status_effect/buff/tea
	desc = "An herbal brew fortifies your body."
	icon_state = "buff"

/atom/movable/screen/alert/status_effect/buff/tea/per
	name = STATKEY_PER

/atom/movable/screen/alert/status_effect/buff/tea/con
	name = STATKEY_CON

/atom/movable/screen/alert/status_effect/buff/tea/wil
	name = STATKEY_WIL
