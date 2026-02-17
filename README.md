# Evolution Arena

Evolution Arena is a dark biolab survivor-like roguelite where you become the outbreak: evolve, survive containment crises, and break the final purge in a 4-8 minute run.

## Release 4 Hook
- You are the outbreak, not the cure.
- Crisis phases interrupt farming and force fast adaptation.
- Each successful crisis grants a high-impact reward that reshapes the run.
- Runs now build toward a final climax: the Purge Protocol.

## Art Direction
Evolution Arena uses a bio-organic sci-fi style built for instant combat readability.

- Visual fantasy: a fast-adapting organism fighting for survival in a hostile microscopic arena.
- Readability first: silhouettes and color roles must remain clear at high enemy density.
- Color language:
  - Friendly/player: cyan-teal-white
  - Enemies/threat: red-orange-magenta
  - Biomass/resources: aqua-green
- Mutation identity:
  - Spikes feel angular/offensive
  - Orbiters feel circular/control-oriented
  - Membrane feels protective/layered
  - Pulse Nova, Acid Trail, Metabolism each need distinct silhouette and motion cues
- UI style: dark translucent panels, bright high-contrast typography, clean card hierarchy (icon -> name -> effect)

## Visual Quality Rules
- No placeholder geometric-only visuals for gameplay-significant release content.
- Every mutation tier should look meaningfully stronger than the previous tier.
- Background and VFX should add atmosphere without hiding enemies, pickups, or hazards.
- A random screenshot during combat should clearly show:
  - where the player is
  - where danger comes from
  - what the current build identity is

## Current Alpha Loop
- Move with WASD.
- Enemies spawn continuously and chase the player.
- Enemies drop biomass on death.
- Biomass grants XP and levels.
- On level-up, choose a mutation option.
- Mutations and crisis rewards visibly shape your build.
- Crisis phases (Containment Sweep, Strain Bloom, Biohazard Leak) pressure your decisions.
- Survive to the final crisis to win, or die and restart.

## Controls
- `WASD`: Move
- `1 / 2 / 3`: Select level-up choices (when level-up panel is open)
- Mouse click: Select level-up choices / restart

## Built With
- Godot 4.x (project currently authored in Godot 4.6)

## Run Locally
1. Open the project in Godot.
2. Run the main scene (`scenes/main_menu.tscn`) with `F5`.

## Project Structure
- `scenes/` - Arena, actors, modules, UI, systems scenes
- `scripts/` - Gameplay scripts (actors, systems, modules)
- `data/` - Planned data-driven mutation definitions

## Notes
- Current balancing is in debug-iteration mode.
- Biomass XP gain and starting module loadout may be tuned down before final alpha build.
- Art and UI are being upgraded toward a consistent, recognizable visual identity for upcoming releases.

## Status
Playable debug release with crisis loop, rewards/synergies, and final victory flow.
