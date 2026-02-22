# ECHO STAMP — SPEC (v0.1)

## 1) High Concept
ECHO STAMP is a one-touch, portrait mobile arcade game. The player does NOT steer. The character moves forward while oscillating vertically automatically. The only input is TAP, which "stamps" (locks) the most recent segment of the character's trail, making it safe from an upcoming scanner sweep. Survive scanner events and pass gates to increase score.

Design goal: Flappy-level simplicity (one input, instant restart) with a novel core mechanic (locking trailing path segments against periodic sweeps).

---

## 2) Platform & Tech Targets
- Engine: Godot 4.6
- Language: GDScript
- Platform: iOS + Android (mobile-first)
- Orientation: Portrait (9:16)
- FPS target: 60
- Input: single action "tap" (Screen Touch + Mouse Left)
- Restart friction: <= 0.3s
- Build stability: 10 consecutive deaths/restarts without errors

---

## 3) Core Gameplay Loop
1. Character auto-moves forward; the world scrolls (endless runner).
2. Character vertical motion is automatic (e.g., smooth sine oscillation).
3. A trail is drawn behind the character continuously.
4. Periodically, a Scanner Sweep crosses the screen.
5. Player taps to STAMP: the last X seconds of trail become LOCKED (safe).
6. When sweep occurs:
   - Unlocked trail is wiped (visual erase).
   - If the sweep line overlaps the character's current position → death.
7. Passing a Gate increments score.
8. Death → instant restart.

---

## 4) Controls
- TAP: STAMP (lock last X seconds of trail)
No other controls. No steering. No swipe/hold required.

---

## 5) Rules & Systems
### 5.1 Trail
- Trail is a polyline behind the character.
- Trail segments have two states:
  - UNLOCKED (default): will be erased by sweep
  - LOCKED (stamped): immune to sweep

### 5.2 Stamp
- Tap locks the most recent trail window:
  - `STAMP_WINDOW_SEC` (default 0.40s)
- Stamping has limited resource:
  - `STAMP_CHARGES_MAX` (default 2)
  - Regeneration: +1 charge every `STAMP_REGEN_SEC` (default 3.0s)
- If no charge available, tap does nothing (optional: play "dry" sound).

### 5.3 Scanner Sweep
- Occurs every `SWEEP_INTERVAL_SEC` (default 2.8s initially).
- Telegraph: show a warning for `SWEEP_WARN_SEC` (default 0.8s).
- Sweep effect:
  - Erase all UNLOCKED trail segments instantly.
  - Kill if the sweep line overlaps the character.

### 5.4 Gates (Scoring)
- A Gate is a pass-through scoring trigger area placed on the path.
- If the character passes through → +1 score.
- Each gate scores once.

---

## 6) Game States
- READY: show "Tap to Start", no sweep yet (or very slow).
- RUNNING: normal gameplay.
- DEAD: show "Dead — Tap to Retry", stop motion, allow restart after short delay.

---

## 7) Scoring
- +1 per Gate passed.
- Persist BEST score locally (ConfigFile).

Optional later:
- Combo: +1 bonus for surviving N sweeps without death.

---

## 8) Difficulty (v0.1)
v0.1 uses fixed values (no ramp) for stability:
- constant scroll speed
- constant sweep interval
- constant gate spacing

v0.2+ difficulty knobs:
- decrease sweep interval slightly over time
- reduce stamp regen speed
- gates placed closer and with more vertical offset

Fairness rule: gates must be reachable by the auto-oscillation (do not place outside min/max Y).

---

## 9) Visuals (Prototype)
- Background: simple ColorRect
- Character: circle or square ColorRect
- Trail: Line2D
- Locked trail: different color/thickness than unlocked
- Sweep: a horizontal line (ColorRect) moving quickly or appearing as a flash band
- Gate: Area2D with a rectangle visual

---

## 10) File / Folder Conventions
Suggested folders:
- `scenes/`
- `scripts/`
- `ui/`
- `assets/` (optional placeholders)

---

## 11) Acceptance Criteria (v0.1)
1) Runs in portrait without errors.
2) Tap starts the run.
3) Character oscillates automatically; player cannot steer.
4) Trail draws continuously behind character.
5) Tap consumes a charge and locks last 0.40s trail (visual difference).
6) Sweep happens with warning; it erases unlocked trail and kills if overlapping character.
7) Passing gates increments score.
8) Death → restart quickly and reliably; best score persists across sessions.
