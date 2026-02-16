# Evolution Arena

Evolution Arena is a minimalist Godot 4 survivor-like roguelite where you evolve mutation modules (spikes and orbiters) to survive escalating enemy waves.

## Current Alpha Loop
- Move with WASD.
- Enemies spawn continuously and chase the player.
- Enemies drop biomass on death.
- Biomass grants XP and levels.
- On level-up, choose a mutation option.
- Mutations visibly change the organism (spikes/orbiters).
- Run ends on death, then restart from game over.

## Controls
- `WASD`: Move
- `1 / 2 / 3`: Select level-up choices (when level-up panel is open)
- Mouse click: Select level-up choices / restart

## Built With
- Godot 4.x (project currently authored in Godot 4.6)

## Run Locally
1. Open the project in Godot.
2. Run the main scene (`scenes/arena.tscn`) with `F5`.

## Project Structure
- `scenes/` - Arena, actors, modules, UI, systems scenes
- `scripts/` - Gameplay scripts (actors, systems, modules)
- `data/` - Planned data-driven mutation definitions

## Notes
- Current balancing is in debug-iteration mode.
- Biomass XP gain and starting module loadout may be tuned down before final alpha build.

## Status
Playable debug alpha loop is working end-to-end.
