# Game Design Document — ProjectClanker

## Overview

ProjectClanker is a GDScript Godot 4 game. This document captures high-level design intent and will expand as development progresses.

## Core loop

_TBD — define the primary player loop._

## Pillars

1. **Engine-first configuration** — layers, masks, input, and tunables live in the editor where possible.
2. **Explicit, typed GDScript** — snake_case functions, no ternaries, descriptive errors.
3. **Testable logic** — critical math and state covered by the test runner in `Tests/`.

## Systems (planned)

| System | Status | Notes |
|--------|--------|-------|
| Main scene bootstrap | Done | Entry point and placeholder UI |
| Global services autoload | Done | Version and pause state |
| Input map | Done | Move + interact + pause |
| Test runner | Done | Console output for pass/fail |

## Content scope

_TBD — levels, entities, progression._

## Technical notes

- Main scene: `Scenes/Main.tscn`
- Autoload: `Autoload/GameServices.gd`
- Tests: `Tests/Scenes/TestRunner.tscn`
