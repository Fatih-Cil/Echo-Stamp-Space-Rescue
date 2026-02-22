# ECHO STAMP — DESIGN FLOW / GAMEPLAY (v0.1)

## 1) The One-Sentence Pitch
You don't control the character — you control which part of your recent path becomes "real" before a scanner wipes the rest.

---

## 2) What the Player Actually Does (Plain Language)
- The character keeps moving forward automatically.
- It gently moves up and down on its own (like floating on a wave).
- Behind it, a glowing trail is always being drawn.
- Every few seconds, a "scanner sweep" is about to pass.
- When you TAP, you "STAMP" the last moment of your trail so it becomes LOCKED.
- The scanner then wipes everything that is NOT locked.
- If the scanner catches your character itself: you die.
- Gates give points when you pass them.

So the skill is:
**stamp at the right moment, when your character is at a safe height for what's coming next.**

---

## 3) Why It's Addictive
- Near-miss moments: stamping in the last 200ms before a sweep.
- Mastery: learning the rhythm of oscillation and sweep timing.
- Resource tension: limited stamp charges creates "not now—later" decisions.
- Fast retries: you can immediately chase a higher score.

---

## 4) The Main Rhythm (Telegraph → Decision → Sweep)
Each cycle is:
1) Warning appears: "Sweep incoming" (visual cue)
2) You choose: spend a stamp now or risk it
3) Sweep happens:
   - unlocked trail is erased
   - your survival depends on being in a safe place

---

## 5) Concrete 15-Second Example Run
- 0s: Tap to start. Character moves forward, oscillating.
- 1.8s: You see the warning band: sweep in 0.8s.
- 2.4s: Character is near the top of its wave. You TAP:
  - last 0.40s of trail becomes LOCKED (brighter/thicker).
  - you now have 1 charge left.
- 2.6s: Sweep hits:
  - unlocked trail disappears instantly (erased look).
  - locked segment remains.
  - character survives because it's not overlapped at that moment.
- 3.2s: You pass through a Gate → score +1.
- 5.4s: Another warning appears.
  - you wait because you want to keep a charge for the next gate.
- 6.0s: You TAP late, barely in time (near-miss).
- 6.2s: Sweep hits; you survive again.
- 7.0s: Gate → score +1.
- 9.8s: You mistime, sweep overlaps the character → death → immediate retry.

---

## 6) Visual Readability Rules
- Locked vs unlocked trail must be unmistakable (color + thickness).
- Sweep must be clearly telegraphed with a warning zone.
- The player must always understand why they died (overlap with sweep).

---

## 7) Tuning Targets (initial suggested values)
- STAMP_WINDOW_SEC: 0.40s
- STAMP_CHARGES_MAX: 2
- STAMP_REGEN_SEC: 3.0s
- SWEEP_INTERVAL_SEC: 2.8s
- SWEEP_WARN_SEC: 0.8s
- OSCILLATION_AMPLITUDE: moderate (so gates feel reachable)
- SCROLL_SPEED: medium (so runs last 8–25s early)

---

## 8) v0.2 Ideas (after vertical slice is stable)
- Gate types:
  - Double gate (two scoring zones) timed with wave peaks
- Sweep variations:
  - Alternating top/bottom sweep band
- Cosmetics:
  - trail skins, stamp effect, sweep theme
