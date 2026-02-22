extends RefCounted

const MUTATIONS: Dictionary = {
	"proto_pulse": {
		"id": "proto_pulse",
		"name": "Proto Pulse",
		"description": "A weak starter pulse that keeps the first minute playable.",
		"short": "weak radial pulse",
		"tags": ["burst", "pulse", "universal"],
		"variant": "universal",
		"tier": "base",
		"lineages": ["lytic", "pandemic", "parasitic"],
		"lineage_affinity": {"lytic": 0.8, "pandemic": 0.8, "parasitic": 0.8},
		"icon_id": "proto_pulse",
		"max_level": 5,
		"levels": {
			1: {"short": "small pulse", "description": "Emit a weak pulse every few seconds."},
			2: {"short": "faster pulse", "description": "Pulse cooldown is reduced and radius increases."},
			3: {"short": "charged pulse", "description": "Pulse damage and radius improve further."},
			4: {"short": "amplified pulse", "description": "Pulse becomes noticeably stronger and quicker."},
			5: {"short": "overcharged pulse", "description": "Pulse reaches peak damage, range, and cadence."}
		}
	},
	"razor_halo": {
		"id": "razor_halo",
		"name": "Razor Halo",
		"description": "Rotating blades orbit your core and shred close enemies.",
		"short": "spinning blade ring",
		"tags": ["contact", "orbit", "lytic", "lytic_starter"],
		"variant": "lytic",
		"tier": "starter",
		"lineages": ["lytic"],
		"lineage_affinity": {"lytic": 2.8, "pandemic": 0.25, "parasitic": 0.20},
		"icon_id": "razor_halo",
		"max_level": 5,
		"levels": {
			1: {"short": "4 blades", "description": "Spawn 4 rotating blades for close-range pressure."},
			2: {"short": "6 blades + sustain", "description": "Increase to 6 blades and unlock sustain (heal 1 per enemy hit)."},
			3: {"short": "8 blades + sustain", "description": "Increase to 8 blades, faster spin, and heal 2 per enemy hit."},
			4: {"short": "10 blades + sustain", "description": "Increase to 10 blades with stronger rotation pressure and heal 3 per enemy hit."},
			5: {"short": "12 blades + sustain", "description": "Max razor ring density, top rotation speed, and heal 4 per enemy hit."}
		}
	},
	"puncture_lance": {
		"id": "puncture_lance",
		"name": "Puncture Lance",
		"description": "Auto-launch piercing lances toward high-priority targets.",
		"short": "auto-piercing lance",
		"tags": ["burst", "lytic", "lytic_core"],
		"variant": "lytic",
		"tier": "core",
		"required_mutations": ["razor_halo"],
		"lineages": ["lytic"],
		"lineage_affinity": {"lytic": 3.0, "pandemic": 0.20, "parasitic": 0.20},
		"icon_id": "puncture_lance",
		"max_level": 5,
		"levels": {
			1: {"short": "single lance", "description": "Fire one lance on a short cooldown."},
			2: {"short": "double lance", "description": "Launch extra lances each volley."},
			3: {"short": "triple lance", "description": "Volley size grows and puncture pressure spikes."},
			4: {"short": "quad lance", "description": "Fire faster volleys with more lances per cast."},
			5: {"short": "spear storm", "description": "Maximum lance barrage and high burst cadence."}
		}
	},
	"lytic_burst": {
		"id": "lytic_burst",
		"name": "Lytic Burst",
		"description": "Periodic close-range burst that clears space around you.",
		"short": "cone burst pulse",
		"tags": ["burst", "lytic", "lytic_capstone"],
		"variant": "lytic",
		"tier": "capstone",
		"required_mutations": ["razor_halo", "puncture_lance"],
		"lineages": ["lytic"],
		"lineage_affinity": {"lytic": 3.1, "pandemic": 0.15, "parasitic": 0.15},
		"icon_id": "lytic_burst",
		"max_level": 5,
		"levels": {
			1: {"short": "burst + guard", "description": "Emit periodic bursts and gain 12% block chance."},
			2: {"short": "wider guard burst", "description": "Burst area and damage increase. Block chance rises to 20%."},
			3: {"short": "reinforced burst", "description": "Burst cadence improves and block chance rises to 29%."},
			4: {"short": "hardened burst", "description": "Burst gets stronger and block chance rises to 37%."},
			5: {"short": "fortress burst", "description": "Peak burst pressure and 45% block chance."}
		}
	},
	"infective_secretion": {
		"id": "infective_secretion",
		"name": "Infective Secretion",
		"description": "Leave infectious fluid trails that apply infection over time.",
		"short": "infectious trail",
		"tags": ["infection", "spread", "pandemic", "pandemic_starter"],
		"variant": "pandemic",
		"tier": "starter",
		"lineages": ["pandemic"],
		"lineage_affinity": {"pandemic": 2.8, "lytic": 0.30, "parasitic": 0.25},
		"icon_id": "infective_secretion",
		"max_level": 5,
		"levels": {
			1: {"short": "trail unlock", "description": "Spawn short infectious trails while moving."},
			2: {"short": "longer trail", "description": "Trail life and area increase."},
			3: {"short": "stronger infection", "description": "Infection pressure increases significantly."},
			4: {"short": "dense residue", "description": "Trails spawn faster and linger longer."},
			5: {"short": "viral haze", "description": "Maximum trail uptime and strong infection damage."}
		}
	},
	"virion_orbit": {
		"id": "virion_orbit",
		"name": "Virion Orbit",
		"description": "Orbiting virions apply and refresh infection on contact.",
		"short": "infective orbiters",
		"tags": ["orbit", "infection", "pandemic", "pandemic_core"],
		"variant": "pandemic",
		"tier": "core",
		"required_mutations": ["infective_secretion"],
		"lineages": ["pandemic"],
		"lineage_affinity": {"pandemic": 3.0, "lytic": 0.20, "parasitic": 0.20},
		"icon_id": "virion_orbit",
		"max_level": 5,
		"levels": {
			1: {"short": "1 virion", "description": "Spawn one infective orbiter."},
			2: {"short": "2 virions", "description": "Increase orbiter count."},
			3: {"short": "infected bonus", "description": "Orbiters gain stronger pressure on infected targets."},
			4: {"short": "3 virions", "description": "Add another virion and increase orbit pressure."},
			5: {"short": "4 virions", "description": "Maximum virion count and orbital dominance."}
		}
	},
	"chain_bloom": {
		"id": "chain_bloom",
		"name": "Chain Bloom",
		"description": "Infected enemies explode contagion bursts on death.",
		"short": "infection death chains",
		"tags": ["infection", "burst", "spread", "pandemic", "pandemic_capstone"],
		"variant": "pandemic",
		"tier": "capstone",
		"required_mutations": ["infective_secretion", "virion_orbit"],
		"lineages": ["pandemic"],
		"lineage_affinity": {"pandemic": 3.1, "lytic": 0.10, "parasitic": 0.15},
		"icon_id": "chain_bloom",
		"max_level": 5,
		"levels": {
			1: {"short": "death burst", "description": "Infected deaths trigger local contagion burst."},
			2: {"short": "wider spread", "description": "Bloom radius increases."},
			3: {"short": "extra chain", "description": "Bloom damage and spread strength increase."},
			4: {"short": "chain surge", "description": "Blooms become larger and carry stronger infection."},
			5: {"short": "plague cascade", "description": "Maximum bloom radius and chain pressure."}
		}
	},
	"leech_tendril": {
		"id": "leech_tendril",
		"name": "Leech Tendril",
		"description": "Latch to nearby enemies, draining life and healing you.",
		"short": "drain tether",
		"tags": ["sustain", "drain", "parasitic", "parasitic_starter"],
		"variant": "parasitic",
		"tier": "starter",
		"lineages": ["parasitic"],
		"lineage_affinity": {"parasitic": 2.8, "pandemic": 0.25, "lytic": 0.20},
		"icon_id": "leech_tendril",
		"max_level": 5,
		"levels": {
			1: {"short": "single drain", "description": "Drain and heal from one nearby enemy."},
			2: {"short": "stronger drain", "description": "Drain strength and range increase."},
			3: {"short": "multi tether", "description": "Tendril can sustain pressure more often."},
			4: {"short": "deep siphon", "description": "Drain/heal output scales up sharply."},
			5: {"short": "parasitic web", "description": "Add an extra tether and maximize sustain."}
		}
	},
	"protein_shell": {
		"id": "protein_shell",
		"name": "Protein Shell",
		"description": "Harden your outer shell to reduce incoming damage and reflect part of it.",
		"short": "damage reduction + reflect shell",
		"tags": ["sustain", "defense", "parasitic", "parasitic_core"],
		"variant": "parasitic",
		"tier": "core",
		"required_mutations": ["leech_tendril"],
		"lineages": ["parasitic"],
		"lineage_affinity": {"parasitic": 3.0, "pandemic": 0.15, "lytic": 0.10},
		"icon_id": "protein_shell",
		"max_level": 5,
		"levels": {
			1: {"short": "-12% dmg +4% reflect", "description": "Reduce incoming damage and reflect a small part to attackers."},
			2: {"short": "-22% dmg +6% reflect", "description": "Stronger shell reduction with improved reflect."},
			3: {"short": "-32% dmg +8% reflect", "description": "Strong shell sustain and noticeable damage reflect."},
			4: {"short": "-40% dmg +10% reflect", "description": "Heavy shell reinforcement with strong reflect response."},
			5: {"short": "-48% dmg +12% reflect", "description": "Maximum shell fortification and peak reflect."}
		}
	},
	"host_override": {
		"id": "host_override",
		"name": "Host Override",
		"description": "Convert weakened enemies into temporary allied hosts.",
		"short": "temporary host conversion",
		"tags": ["control", "sustain", "parasitic", "parasitic_capstone"],
		"variant": "parasitic",
		"tier": "capstone",
		"required_mutations": ["leech_tendril", "protein_shell"],
		"lineages": ["parasitic"],
		"lineage_affinity": {"parasitic": 3.1, "pandemic": 0.10, "lytic": 0.10},
		"icon_id": "host_override",
		"max_level": 5,
		"levels": {
			1: {"short": "convert weak", "description": "Convert very weak enemies into allies."},
			2: {"short": "higher threshold", "description": "Can convert healthier targets."},
			3: {"short": "longer hosts", "description": "Converted hosts survive longer."},
			4: {"short": "expanded control", "description": "Increase range and host control capacity."},
			5: {"short": "override swarm", "description": "High threshold conversion and larger host cap."}
		}
	}
}

static func get_all() -> Dictionary:
	return MUTATIONS.duplicate(true)
