# Component Sync Checklist

Drift and Dashboard share functionality but were built separately. This checklist tracks what needs syncing.

## Dashboard Mixer ← Drift Mixer
- [ ] Mute toggle button on each layer (hover to show, click to toggle)
- [ ] Waveform slider visualization (canvas behind slider, per-layer patterns)
- [ ] AnalyserNode for synthesis layers (real audio data)
- [ ] Slider thumb bob animation (idle: bobs, hover: snaps)
- [ ] Sticky controls bar (position: sticky bottom when scrolling 16 layers)
- [ ] Progressive disclosure (6 featured → show all 16, with state persistence)
- [ ] Share nudge (share button glows after 30s of mixing)
- [ ] Auto-name saves ("rain + fire · sunday afternoon")
- [ ] UI sounds (click, tick, ping on interactions)

## Dashboard Timer ← Pulse
- [ ] Phase color shift (green focus → warm brown break) — already done
- [ ] Keyboard shortcuts (space, R) — already done
- [ ] Session dots — already done
- [ ] Custom duration input — done on dashboard

## Dashboard Music ← Static FM
- [ ] Chat sidebar (ephemeral messages, frosted glass)
- [ ] Spotify embed per mood
- [ ] Track info display (now playing)
- [ ] Music volume control (separate from atmosphere)

## Long-term Fix
Create shared CSS/JS components that both repos import. One source of truth instead of duplicated code.

## Priority
Medium. The dashboard works. These sync items make it feel identical to the standalone products. Do it in a fresh session with full context.
