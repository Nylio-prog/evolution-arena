extends RefCounted

const MUTATIONS: Dictionary = {
	"spikes": {
		"id": "spikes",
		"name": "Spikes",
		"description": "Grow defensive spikes around your organism.",
		"lineages": ["predator", "bulwark"],
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
		"max_level": 3,
		"levels": {
			1: {"short": "-15% dmg", "description": "Reduce incoming damage by 15%."},
			2: {"short": "-30% dmg", "description": "Reduce incoming damage by 30%."},
			3: {"short": "-45% dmg", "description": "Reduce incoming damage by 45%."}
		}
	}
}

static func get_all() -> Dictionary:
	return MUTATIONS.duplicate(true)
