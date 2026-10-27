//Using this so we don't need to touch upstream defines.
#define ASPECT_NAME_AEROMANCY "Winds"
#define GLOW_COLOR_WIND "#8CDD8C"

/datum/magic_aspect/aeromancy
	name = "Aeromancy"
	latin_name = "Maior Aspectus Venti"
	desc = "Telomancers consider themselves just a sub branch of Kinesis, and similarly deserving of the title 'Origin School'. \ Indeed, shaping Pure Arcana into ball of magick was probably one of the first spell cast in humenity's history. \
	Compared to Kinesis, which focuses on both shaping mana and the power of force, Telomancers focuses almost entirely on shaping mana into deadly projectiles"
	aspect_type = ASPECT_MAJOR
	attuned_name = ASPECT_NAME_AEROMANCY
	school_color = GLOW_COLOR_WIND
	binding_chants = list(
		"Invoco telum destinatum!",
		"I send my purpose toward its mark, let it arrive.",
		"Telum, in me ligare!",
	)
	unbinding_chants = list(
		"Solvo telum vinctum!",
		"I release the mark I had chosen, go free.",
		"Telum, a me discedere!",
	)
	fixed_spells = list(
		/datum/action/cooldown/spell/projectile/wind_blade,
		/datum/action/cooldown/spell/projectile/windblade_volley,
		/datum/action/cooldown/spell/tempest,
		/datum/action/cooldown/spell/tailwind,
		/datum/action/cooldown/spell/levitation,
		/datum/action/cooldown/spell/featherfall,
	)
	variants = list(
		"mastery" = list(
			VARIANT_ADDITIVE = /datum/action/cooldown/spell/cyclone,
		),
	)
