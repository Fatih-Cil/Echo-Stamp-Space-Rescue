# Echo Stamp: Space Rescue

Fast-paced portrait mobile arcade game built with **Godot 4.6**.
Pilot a rocket through lethal scanner sweeps, manage armor + fuel, rescue drifting astronauts, and survive escalating level loops.

## Highlights

- Auto forward motion + vertical oscillation
- Timed armor/stamp mechanic against lethal sweeps
- Fuel management layer (`OUT OF FUEL` fail state)
- 4-level biome cycle with infinite loop progression
- Astronaut pickups with multiple effects
- [Score, best score, and local save persistence](file:///Users/fatih/Documents/Projeler/Oyun-Demolar%C4%B1/ECHO%20STAMP/README.md#L13)
- [Badge/collection album with unlock flow](file:///Users/fatih/Documents/Projeler/Oyun-Demolar%C4%B1/ECHO%20STAMP/README.md#L14)
- [Mobile-friendly portrait UI](file:///Users/fatih/Documents/Projeler/Oyun-Demolar%C4%B1/ECHO%20STAMP/README.md#L15)

## Gameplay Screenshots

<p align="center">
  <img src="screenshots/Screenshot%202026-02-22%20at%2018.34.01.png" width="19%" />
  <img src="screenshots/Screenshot%202026-02-22%20at%2018.34.30.png" width="19%" />
  <img src="screenshots/Screenshot%202026-02-22%20at%2018.37.12.png" width="19%" />
  <img src="screenshots/Screenshot%202026-02-22%20at%2018.38.33.png" width="19%" />
  <img src="screenshots/Screenshot%202026-02-22%20at%2018.39.35.png" width="19%" />
</p>

## Tech

- Engine: Godot 4.6
- Language: GDScript
- Main scene: `res://scenes/Main.tscn`

## Run Locally

1. Open project in Godot 4.6.
2. Set `scenes/Main.tscn` as main scene (already configured in project).
3. Press Play.

## Core Controls

- `Tap / Click`: Use armor (consumes 1 charge)
- Survive scanner sweeps, collect fuel capsules, rescue astronauts, and pass score orbs.

## Project Structure

- `scenes/` - main and gameplay scenes
- `scripts/` - gameplay logic (player, sweep, trail, pickups, UI/meta)
- `assets/` - visual/audio assets (badges, voice, etc.)
- `GAME_GUIDE.md` - living gameplay/system design document
- `docs/archive/SPEC.md` / `docs/archive/DESIGN_FLOW.md` - historical product/design specs

## Save Data (macOS)

`~/Library/Application Support/Godot/app_userdata/ECHO STAMP/save.cfg`

Stores best score, progression, audio settings, and collection state.

## Status

Active prototype / vertical slice. Gameplay and UX are under iterative tuning.

## License

Add your preferred license here (e.g. MIT).
