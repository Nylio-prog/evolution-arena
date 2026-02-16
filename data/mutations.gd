extends RefCounted

const MUTATIONS: Dictionary = {
	"spikes": {
		"id": "spikes",
		"name": "Spikes",
		"description": "Grow defensive spikes around your organism.",
		"lineages": ["predator", "bulwark"],
		"lineage_affinity": {"predator": 2.0, "bulwark": 1.6},
		"max_level": 3,
		"levels": {
			1: {"short": "4 spikes", "description": "Grow 4 spikes around your body."},
			2: {"short": "6 spikes", "description": "Increase to 6 spikes."},
			3: {"short": "8 spikes", "description": "Increase to 8 spikes."}
		}
	},
	"orbiters": {
		"id": "orbiters",
		"name": "Orbiters",
		"description": "Spawn orbiting cells that damage enemies.",
		"lineages": ["swarm", "bulwark"],
		"lineage_affinity": {"swarm": 2.0, "bulwark": 1.4},
		"max_level": 3,
		"levels": {
			1: {"short": "1 cell", "description": "Spawn 1 orbiting cell."},
			2: {"short": "2 cells", "description": "Increase to 2 orbiting cells."},
			3: {"short": "faster", "description": "Orbiters rotate faster."}
		}
	},
	"membrane": {
		"id": "membrane",
		"name": "Membrane",
		"description": "Grow a protective layer to reduce incoming damage.",
		"lineages": ["bulwark"],
		"lineage_affinity": {"bulwark": 2.4},
		"max_level": 3,
		"levels": {
			1: {"short": "-15% dmg", "description": "Reduce incoming damage by 15%."},
			2: {"short": "-30% dmg", "description": "Reduce incoming damage by 30%."},
			3: {"short": "-45% dmg", "description": "Reduce incoming damage by 45%."}
		}
	},
	"pulse_nova": {
		"id": "pulse_nova",
		"name": "Pulse Nova",
		"description": "Emit periodic shockwaves that hit nearby enemies.",
		"lineages": ["predator", "swarm"],
		"lineage_affinity": {"predator": 2.1, "swarm": 1.7},
		"max_level": 3,
		"levels": {
			1: {"short": "small pulse", "description": "Emit a weak short-range pulse."},
			2: {"short": "bigger radius", "description": "Pulse radius increases noticeably."},
			3: {"short": "faster pulses", "description": "Pulse interval is reduced for more pressure."}
		}
	},
	"acid_trail": {
		"id": "acid_trail",
		"name": "Acid Trail",
		"description": "Leave corrosive residue while moving.",
		"lineages": ["predator", "swarm"],
		"lineage_affinity": {"predator": 2.2, "swarm": 1.6},
		"max_level": 3,
		"levels": {
			1: {"short": "trail unlock", "description": "Start leaving a short acid trail."},
			2: {"short": "longer trail", "description": "Trail lasts longer and covers more space."},
			3: {"short": "stronger acid", "description": "Trail damage increases."}
		}
	},
	"metabolism": {
		"id": "metabolism",
		"name": "Metabolism",
		"description": "Adapt internal systems for sustain and tempo.",
		"lineages": ["bulwark", "swarm"],
		"lineage_affinity": {"bulwark": 2.2, "swarm": 1.2},
		"max_level": 3,
		"levels": {
			1: {"short": "+regen", "description": "Gain light passive health regeneration."},
			2: {"short": "+regen+", "description": "Regeneration rate increases."},
			3: {"short": "surge", "description": "Strong sustain while under pressure."}
		}
	}
}

static func get_all() -> Dictionary:
	return MUTATIONS.duplicate(true)
