# Crushline-Godot

Crushline is a Godot-built node-graph production sandbox / expert-pack progression puzzle.

The graph is the factory. Players place machine nodes, choose recipes, connect typed ports, and solve production goals through resource flow, power, waste, byproducts, bottlenecks, unlocks, and evaluator feedback.

## Current priority

Playable Slice 1 before burnout.

Slice 1 should prove the Basic Iron Processing loop:

- create or load a production graph;
- add machine nodes;
- display left-side inputs and right-side outputs;
- connect ports;
- inspect nodes and links;
- run a deterministic evaluator;
- show deficits, bottlenecks, zero-output links, power state, unmanaged byproducts, and objective progress;
- save and load both successful and failed graphs;
- support washed ore, slurry recovery, and dirty shortcut iron routes.

## Production direction

Early implementation should stay Godot-native and small:

- Godot scenes for UI and game structure;
- `GraphEdit` / `GraphNode` for the first graph canvas prototype;
- Godot `Resource` files, JSON, or simple dictionaries for authored data;
- GDScript for fast iteration;
- a separate Crushline production graph model behind the visual graph;
- a deterministic Slice 1 evaluator.

Crushline owns game meaning. Godot owns engine, editor, UI, rendering, input, and platform infrastructure.

## Early non-goals

Do not start by building a custom graph renderer, custom canvas input system, custom node layout engine, custom port routing system, docking UI, save/load framework, platform layer, custom engine, multiplayer, full mod support, or hundreds of recipes.

WPL/WNG are not active blockers for this Godot repository.

## Slice 1 route concepts

### Washed ore route

`Iron Ore -> Crusher -> Crushed Iron Ore -> Washer -> Washed Iron Ore -> Smelter -> Iron Ingot`

The washer produces Iron Slurry that must be handled when the objective requires byproduct handling.

### Slurry recovery route

`Iron Ore -> Crusher -> Crushed Iron Ore -> Washer -> Iron Slurry -> Filter -> Iron Dust -> Smelter -> Iron Ingot`

This route introduces byproduct recovery and shows that waste-like materials can become useful.

### Dirty shortcut route

`Iron Ore -> Crusher -> Crushed Iron Ore -> Smelter -> Impure Iron Ingot or reduced-rate Iron Ingot`

This route is valid but inferior. It should demonstrate that flawed graphs can still run, fail clearly, and be improved.

## Repository status

This repository is being initialized for the Godot-first Crushline playable slice.
