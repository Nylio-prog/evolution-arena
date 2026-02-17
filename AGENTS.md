# AGENTS.md — Evolution Arena (Godot 4.6) — AI-Friendly Project Spec

## 0) Purpose of This File
This document is the single source of truth for:
- What game we are building (alpha in a few days)
- What is in/out of scope
- How the codebase is organized
- How an AI agent should work (rules, workflow, definitions of done)
- How to keep everything simple, shippable, and beginner-friendly

If something is ambiguous, default to the simplest option that keeps the alpha playable.

---

## 1) High-Level Game Pitch (Alpha)
**Evolution Arena** is a minimalist "survivor-like" roguelite.
- You start as a small organism (a circle).
- Enemies spawn in waves (continuous spawning).
- You deal damage automatically via simple evolution modules (spikes/orbiters).
- Killing enemies drops biomass (XP).
- Every time you level up, you pick 1 of 3 mutations.
- Mutations physically change your organism (more spikes, orbiting cells, etc.).
- Goal for alpha: survive as long as possible; show satisfying growth.

**Art style direction (current):** bio-organic sci-fi, readable at high enemy density, with strong silhouettes and mutation-driven visual growth.

### 1.1 Genre Art Style Analysis (Survivor-Like)
This genre works best when combat is readable in less than a second, even during heavy enemy density.

Core genre patterns to keep:
- Silhouette-first readability: player, enemies, pickups, and hazards must be identifiable by shape before color.
- Color-coded threat language: friendly effects use one color family; hostile units and danger zones use a contrasting family.
- Strong combat punctuation: hit feedback, level-up moments, and death moments need immediate visual impact.
- Low-noise background: arena textures should support atmosphere without hiding gameplay.
- Consistent iconography: mutation icons should share one lighting, stroke, and material language.

### 1.2 Evolution Arena Art Direction (Authoritative)
Target fantasy:
- A fast-evolving organism in a hostile microscopic arena.
- The world should feel alive and cellular while staying clean and readable.

Visual pillars:
- Clarity under pressure: gameplay readability comes before decorative detail.
- Visible evolution: each mutation tier must change silhouette, scale, or movement style.
- Cohesive identity: gameplay sprites, UI, icons, and VFX must feel from the same universe.

Color system:
- Player/friendly: cyan, teal, white accents.
- Enemies/threat: red, orange, magenta accents.
- Resources/XP: bright aqua-green accents.
- UI: deep navy translucent panels with high-contrast text.
- Rule: enemy tones must never blend into the arena background.

Shape language:
- Player: rounded, stable nucleus silhouette.
- Basic enemy: sharper asymmetry, directional pressure feel.
- Dasher enemy: elongated forward silhouette that telegraphs burst speed.
- Mutation visuals:
  - Spikes: angular and outward.
  - Orbiters: circular rhythm and orbital motion.
  - Membrane: protective layered ring.
  - Pulse Nova: radial burst with clear edge.
  - Acid Trail: visible persistent hazard residue.
  - Metabolism: internal pulse/glow sustain identity.

Motion language:
- Idle: subtle breathing/pulsing only.
- Move: directional emphasis with minimal noise.
- Hit: quick flash and fast recovery.
- Death: short pop/dissolve that reads instantly.
- Evolve: brief high-contrast celebratory pulse.

UI direction:
- Keep HUD edge-anchored and minimal.
- Level-up cards prioritize: icon, name, one-line effect.
- Favored/recommended options use one consistent accent pattern.
- Typography must be legible at combat pace.

Asset quality bar:
- No placeholder geometric-only gameplay visuals for release candidates.
- Every gameplay-significant object needs authored art.
- New visual asset acceptance checklist:
  - silhouette reads at gameplay scale
  - role color family is correct
  - animation timing feels alive
  - visual does not reduce combat readability

### 1.3 Art Production Workflow (AI + Human)
- AI defines asset specs first (role, size, silhouette cues, palette family).
- Human generates or sources the art asset.
- AI integrates and tunes scale/offset/modulate in-engine.
- Each visual micro-task must include:
  - live readability check in a normal run
  - high-density check with many enemies/effects
  - screenshot check for clarity

---

## 2) Hard Constraints (Non-Negotiable)
This is an **alpha built in a few days**.
Therefore:
- No fancy meta-progression
- No complex procedural maps
- No advanced shaders (optional polish only)
- No complicated enemy AI
- No networking
- No save system required (optional)
- No audio required (optional)

**Primary objective:** a playable loop in 5 minutes:
Start -> move -> enemies spawn -> auto damage -> collect biomass -> level up -> choose mutation -> organism grows -> repeat.

---

## 3) Target Platform & Engine
- Engine: **Godot 4.x**
- Target platform for alpha: **PC (Windows)**
- Input: keyboard + mouse (optional mouse aiming later)

---

## 4) Core Gameplay Loop (Alpha)
### 4.1 Player
- Movement: WASD
- Player has HP. If HP reaches 0 -> Game Over screen.
- Player’s damage comes from modules (no manual shooting in alpha).

### 4.2 Enemies
- Enemies spawn continuously, increasing slightly over time.
- Enemy behavior: move toward player (seek) and deal contact damage.

### 4.3 Biomass (XP)
- Enemies drop Biomass pickups (small circles).
- Player collects by proximity.
- Biomass increases XP bar.
- On level-up: pause the game (or slow time strongly), show 3 mutation choices.

### 4.4 Mutations
- Player chooses 1 of 3.
- Mutation applies immediately and visibly changes the organism.

### 4.5 Run End
- When dead: show time survived + level reached + “Restart”.

---

## 5) Minimal Feature Set (Must-Have for Alpha)
### 5.1 Must-Have Systems
1. Player movement + HP
2. Enemy spawner + chasing enemies
3. Contact damage & invincibility frames (brief)
4. Biomass drops + pickup + XP/Leveling
5. Level-up screen with 3 random mutation options
6. At least **2 mutation types**, each with 2-3 upgrade levels
7. Simple UI: HP bar, XP bar, timer, level number
8. Game Over + Restart

### 5.2 Mutation Types for Alpha (Start Here)
Keep it dead simple, visually obvious.

#### A) Spikes (Contact Damage Aura)
- Represented by triangles placed around the player.
- Damage enemies on collision (Area2D).
- Upgrades:
  - Level 1: 4 spikes
  - Level 2: 6 spikes
  - Level 3: 8 spikes OR +damage

#### B) Orbiting Cells (Orbiting Contact Damage)
- Small circles orbit the player at a radius.
- Damage enemies on collision (Area2D).
- Upgrades:
  - Level 1: 1 orbiter
  - Level 2: 2 orbiters
  - Level 3: faster orbit OR bigger radius

### 5.3 Nice-to-Have (Only If Time)
- Dash ability
- One ranged enemy type
- One elite enemy
- Simple particles on death
- Screen shake
- Settings menu

---

## 6) What Is Explicitly Out of Scope (Alpha)
- Complex evolutionary body simulation / physics
- Drag-and-drop programming / logic trees
- Dozens of enemies/mutations
- Bosses
- Meta progression
- Steam integration
- Localization
- Achievements
- Save files (except trivial best time if you want)

If requested later, plan for "beta".

---

## 7) Design Rules (Keep It Fun Without Assets)
- Visual clarity > detail
- Every mutation must produce a visible change (new triangles/circles, more of them, faster, etc.)
- Avoid +5% style boring upgrades in alpha
- Difficulty scaling: spawn rate increases slowly; enemy HP increases slowly
- Keep strict role-based color coding (friendly vs hostile vs resource).
- Prefer one strong visual idea per mutation rather than stacking many weak effects.

---

## 8) Controls (Alpha)
- WASD: move
- ESC: pause (optional)
- Mouse: not required

---

## 9) Gameplay Numbers (Initial Defaults)
These are starting points; tune later.
- Player HP: 100
- Enemy HP: 15
- Enemy damage (contact): 10 per hit
- Player i-frames after hit: 0.5s
- Biomass per enemy: 1
- XP needed: `10 + (level-1)*5`
- Spawn rate: start 1 enemy/sec, increase over time up to ~4/sec
- Spike damage: 8
- Orbiter damage: 6
- Orbiter speed: 2.5 rotations/sec (tweak)

Keep numbers in one place (constants or a config resource).

---

## 10) Project Structure (Recommended)
Keep it simple and AI-friendly.

res://
scenes/
main_menu.tscn
arena.tscn
ui_hud.tscn
ui_levelup.tscn
game_over.tscn
actors/
player.tscn
enemy_basic.tscn
modules/
spike_ring.tscn
orbiter.tscn
systems/
game_manager.gd
enemy_spawner.gd
xp_system.gd
mutation_system.gd
loot_system.gd
data/
mutations.gd (or mutations.json)
art/
(optional)
audio/
(optional)

---

## 11) Scene Responsibilities (Very Clear)
### 11.1 `arena.tscn`
- Owns the match flow
- Contains Player instance
- Contains EnemySpawner
- Contains HUD
- Contains LevelUp UI (hidden until needed)

### 11.2 `player.tscn`
- Node2D or CharacterBody2D
- Handles movement + HP + receiving damage
- Exposes:
  - `take_damage(amount: int) -> void`
  - `add_xp(amount: int) -> void` (or XPSystem handles)

### 11.3 `enemy_basic.tscn`
- CharacterBody2D
- Seeks player
- Takes damage from module collisions
- On death:
  - emits `died(position)` signal
  - drops biomass pickup (via LootSystem)

### 11.4 `spike_ring.tscn`
- Node2D with multiple Area2D triangles around player
- Upgrades change count/damage

### 11.5 `orbiter.tscn`
- Node2D/Area2D orbiting around player
- Upgrades change count/speed/radius

### 11.6 `mutation_system.gd`
- Owns list of possible mutations & levels
- On level-up: provides 3 random options with weights
- Applies the chosen mutation to player/modules

---

## 12) Data-Driven Mutations (AI-Friendly)
Mutations should be defined in one data file.
Option A: `data/mutations.gd` returning a dictionary
Option B: `data/mutations.json`

Each mutation has:
- `id` (string)
- `name` (string)
- `description` (string)
- `max_level` (int)
- `apply(player, level)` (function) OR mapping to handler

Example IDs:
- `spikes`
- `orbiters`

The agent must keep mutation logic centralized:
- UI reads name/description from the data
- Apply is handled by MutationSystem

---

## 13) UI Requirements (Alpha)
HUD shows:
- HP bar
- XP bar + level number
- Time survived

Level-up UI shows:
- Title: "EVOLVE"
- 3 choice cards
- Each card has name + description
- Click to select (mouse), or 1/2/3 hotkeys (optional)

Game Over UI shows:
- "You were consumed."
- Time survived
- Level reached
- Restart button

---

## 14) Save/Load (Optional)
If implemented, only save:
- Best survival time
- Best level

Use a tiny JSON file in user://.

---

## 15) Audio/FX (Optional)
If time allows:
- Enemy death pop
- Pickup sound
- Level-up sound
- Small screen shake on hit
- Simple particle burst on enemy death

Do NOT block core gameplay for FX.

---

## 16) Coding Standards (For Agent)
- Use GDScript (Godot 4)
- Prefer composition over inheritance
- Avoid overusing signals; use them for clear events (enemy died, level up)
- Keep each script small and single-purpose
- No clever abstractions for alpha

### Naming
- Scenes: `snake_case.tscn`
- Scripts: `snake_case.gd`
- Nodes: `PascalCase` in editor is ok; code references should be stable

### Performance
- Use object pooling only if necessary; likely not needed for alpha.

---

## 17) AI Agent Workflow Rules
When acting as the coding agent:
1. Always keep the game playable at the end of each change set.
2. Implement in small steps; avoid large refactors.
3. Prefer adding missing minimal code over perfect architecture.
4. If a feature is uncertain, implement the simplest plausible version.
5. Do not invent new scope without explicit instruction.
6. If asked to choose between options, pick the option that reduces code and UI complexity.
7. Use micro-tasks with very small human effort (target: under 5 minutes each).
8. For every micro-task:
   - AI does implementation work.
   - AI explains exactly what code was changed and why.
   - Human performs a short verification step in Godot.
   - AI asks for confirmation before making a commit.
9. Create one commit per completed micro-task when files changed.
10. Do not push to remote unless the human explicitly asks.

### 17.1 Git & Commit Workflow (Required)
- Repository is managed with Git and GitHub workflow in mind.
- Commit messages must be clear and scoped to one micro-task.
- Preferred commit style: `type: short summary` (for example `feat: add player movement`).
- If a micro-task has no tracked file changes (for example empty folders only), do not force a commit.
- Keep planning docs local unless explicitly requested for sharing.
- `plan/` is considered local planning space and should not be pushed by default.

### 17.1.1 Godot Resource Metadata Policy
- Track Godot-generated `.uid` files in Git (including script `.gd.uid` files).
- Include related `.uid` files in the same micro-task commit as their scene/script changes.
- Treat `.uid` files as engine-managed metadata; do not hand-edit unless there is a specific repair reason.

### 17.2 Communication & Explanation Rules (Required)
- After any AI code edit, explain in beginner-friendly language:
  - what files changed
  - what each change does
  - why it is needed in the gameplay loop
  - what the human should test next
- Do not continue to the next implementation step until the human confirms the current micro-task.
- If the human reports an issue, fix that issue first, then re-run the same micro-task check.

### 17.3 Docs-First Guidance (Required)
- When Godot behavior is uncertain, check official Godot docs first.
- Prefer official docs over random tutorials.
- Provide links when giving setup guidance that the human performs in the editor.

---

## 18) Development Milestones (Few Days Plan)
### Milestone A (Day 1): Playable Arena
- Player moves
- One enemy spawns and chases
- Basic HP and death

### Milestone B (Day 2): Core Loop
- Biomass drops + XP + leveling
- Level-up UI with 3 choices (can be placeholder)
- Implement Spikes mutation (3 levels)

### Milestone C (Day 3): Second Mutation + Polish
- Orbiters mutation (3 levels)
- UI polish (bars, timer)
- Difficulty scaling (spawn rate increases)
- Game Over screen + restart

### Stretch (Day 4+ if you want)
- 1 ranged enemy
- 2-3 extra mutations
- Small FX

---

## 19) Definition of Done (Alpha)
Alpha is "done" when:
- You can start a run and survive at least 2 minutes
- Level-up happens multiple times
- Mutations visibly change the organism
- Difficulty ramps (spawns increase)
- Game over -> restart works reliably
- No critical errors in output

---

## 20) Debug & Dev Helpers (Recommended)
- Toggle hitboxes (optional)
- Print current mutation levels on screen (optional)
- A debug key to grant XP (optional)

---

## 21) Common Pitfalls (Avoid)
- Spending time on art pipelines
- Adding too many enemy types early
- Making mutation UI complex
- Overengineering stats/upgrade framework
- Building meta progression before core fun exists

---

## 22) Suggested Next Tasks for the Agent (Start Here)
The agent should implement in this order:
1. Create project folders and base scenes (`arena`, `player`, `enemy_basic`, HUD).
2. Implement movement + enemy chase + contact damage + death.
3. Add Biomass drops + pickup.
4. Add XP/leveling and level-up UI.
5. Add MutationSystem + Spikes module.
6. Add Orbiters module.
7. Add difficulty scaling + Game Over UI.

---

## 23) Clarifications (If Needed)
If something is not specified:
- Use a black background with white player and red enemies.
- Use circles/triangles with CollisionShape2D.
- Keep UI minimal and readable.

End of AGENTS.md
