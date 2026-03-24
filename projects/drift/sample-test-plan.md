---
title: drift sample upgrade. test plan
date: 2026-03-22
type: reference
scope: shared
summary: Drift Sample Upgrade. Test Plan
---

# Drift Sample Upgrade. Test Plan

Run through this checklist after implementing the dual audio engine with real samples.

## Pre-Test Setup
- [ ] All 11 sample MP3s are in `/public/audio/`
- [ ] Layer definitions updated with `type: 'sample'` and `src` paths
- [ ] Dual engine code deployed

## Desktop (Chrome)
- [ ] Each sample layer plays when slider moves above 0
- [ ] Each sample layer stops when slider returns to 0
- [ ] Synthesis layers (brown noise, white noise, drone, wind, snow) still work
- [ ] No audible gap or pop when sample loops
- [ ] Master volume controls both sample and synthesis layers
- [ ] Multiple sample layers play simultaneously without distortion
- [ ] Preset loading works (loads correct layers at correct volumes)
- [ ] Share link works (encodes and loads mix correctly)
- [ ] Layer suggestions still highlight on activation
- [ ] "Loading..." shows briefly on first activation of each sample layer

## Desktop (Firefox)
- [ ] Same checklist as Chrome

## Desktop (Safari)
- [ ] Same checklist as Chrome
- [ ] Tap-to-begin overlay works

## Mobile (iOS Safari)
- [ ] Audio plays after tap-to-begin
- [ ] Sample layers play (HTML5 Audio should work even if Web Audio had issues)
- [ ] Audio continues when switching to a different tab (HTML5 Audio advantage)
- [ ] Audio plays even with mute switch on (HTML5 Audio advantage. verify this)
- [ ] Sliders are usable with touch (44px touch targets)
- [ ] No static/noise artifacts

## Mobile (Chrome/Edge)
- [ ] Audio plays
- [ ] Sample + synthesis layers work together
- [ ] No performance issues with multiple layers

## Thunder (Special Case)
- [ ] Thunder plays random individual samples, not a loop
- [ ] Different intensity/timing each time
- [ ] Thunder volume controlled by slider
- [ ] Thunder stops when slider goes to 0

## Audio Quality
- [ ] Rain sounds like rain (not filtered white noise)
- [ ] Fireplace sounds like crackling embers (not harsh static)
- [ ] Birds sound like a forest morning (no single dominant call)
- [ ] Cafe sounds like indistinct chatter (no identifiable words)
- [ ] Ocean sounds like rhythmic waves (not crashing surf)
- [ ] Train sounds like a cabin on tracks (rhythmic, not loud)
- [ ] All samples blend well when layered together

## Performance
- [ ] No noticeable delay when activating a sample layer for the first time
- [ ] Page doesn't slow down with 5+ layers active
- [ ] Memory usage stays reasonable (check browser dev tools)
- [ ] Lazy loading works. samples only download when needed

## Regression
- [ ] Analytics still tracking (layer_activate, preset_load, mix_share events)
- [ ] Keyboard shortcuts still work (Space, M, 1-6)
- [ ] PWA still installable
- [ ] Default presets still load correctly
- [ ] SEO pages still link to working mixes
