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
		"max_level": 2,
		"levels": {
			1: {"short": "small pulse", "description": "Emit a weak pulse every few seconds."},
			2: {"short": "faster pulse", "description": "Pulse cooldown is reduced and radius increases."}
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
		"max_level": 3,
		"levels": {
			1: {"short": "4 blades", "description": "Spawn 4 rotating blades."},
			2: {"short": "6 blades", "description": "Increase to 6 blades."},
			3: {"short": "8 blades", "description": "Increase to 8 blades and faster spin."}
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
		"max_level": 3,
		"levels": {
			1: {"short": "single lance", "description": "Fire one lance on a short cooldown."},
			2: {"short": "double lance", "description": "Launch extra lances each volley."},
			3: {"short": "bleed mark", "description": "Lances apply heavier puncture pressure."}
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
		"max_level": 3,
		"levels": {
			1: {"short": "tight burst", "description": "Emit a periodic short-range burst."},
			2: {"short": "wider burst", "description": "Burst area and damage increase."},
			3: {"short": "multi-hit", "description": "Burst cadence improves and pressure spikes."}
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
		"max_level": 3,
		"levels": {
			1: {"short": "trail unlock", "description": "Spawn short infectious trails while moving."},
			2: {"short": "longer trail", "description": "Trail life and area increase."},
			3: {"short": "stronger infection", "description": "Infection pressure increases significantly."}
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
		"max_level": 3,
		"levels": {
			1: {"short": "1 virion", "description": "Spawn one infective orbiter."},
			2: {"short": "2 virions", "description": "Increase orbiter count."},
			3: {"short": "infected bonus", "description": "Orbiters gain stronger pressure on infected targets."}
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
		"max_level": 3,
		"levels": {
			1: {"short": "death burst", "description": "Infected deaths trigger local contagion burst."},
			2: {"short": "wider spread", "description": "Bloom radius increases."},
			3: {"short": "extra chain", "description": "Bloom damage and spread strength increase."}
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
		"max_level": 3,
		"levels": {
			1: {"short": "single drain", "description": "Drain and heal from one nearby enemy."},
			2: {"short": "stronger drain", "description": "Drain strength and range increase."},
			3: {"short": "multi tether", "description": "Tendril can sustain pressure more often."}
		}
	},
	"protein_shell": {
		"id": "protein_shell",
		"name": "Protein Shell",
		"description": "Harden your outer shell to reduce incoming damage.",
		"short": "damage reduction shell",
		"tags": ["sustain", "defense", "parasitic", "parasitic_core"],
		"variant": "parasitic",
		"tier": "core",
		"required_mutations": ["leech_tendril"],
		"lineages": ["parasitic"],
		"lineage_affinity": {"parasitic": 3.0, "pandemic": 0.15, "lytic": 0.10},
		"icon_id": "protein_shell",
		"max_level": 3,
		"levels": {
			1: {"short": "-12% dmg", "description": "Reduce incoming damage."},
			2: {"short": "-22% dmg", "description": "Further reduce incoming damage."},
			3: {"short": "-32% dmg", "description": "Strong shell sustain."}
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
		"max_level": 3,
		"levels": {
			1: {"short": "convert weak", "description": "Convert very weak enemies into allies."},
			2: {"short": "higher threshold", "description": "Can convert healthier targets."},
			3: {"short": "longer hosts", "description": "Converted hosts survive longer."}
		}
	}
}

static func get_all() -> Dictionary:
	return MUTATIONS.duplicate(true)
