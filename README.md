# Spaceship Exploration Program

A modular text game written in ARMv8/AArch64 assembly. The goal is to identify
and reach one viable planet before fuel is exhausted.

## Current milestone

The foundation establishes separate modules, a stable data layout, a documented
procedure convention, input validation boundaries, and a full vertical game
flow. The planet map is deterministic on purpose: it makes testing repeatable.

## Toolchain assumption

The code uses GNU AArch64 assembly syntax and the standard C library's
`printf`, `scanf`, and `getchar` functions. Build it in an AArch64 Linux
environment with:

```sh
aarch64-linux-gnu-gcc -g -Wall -x assembler -o spaceship \
  main.asm map.asm game_state.asm input.asm ui.asm game_logic.asm
```

Run the resulting AArch64 executable on native hardware or through the
course-provided execution environment. If the course uses a different I/O
library, only `input.asm` and `ui.asm` should need adjustment; the game data,
logic, and interfaces remain unchanged.

## Manual smoke tests

1. Enter a non-number at the menu and confirm the program recovers.
2. List all ten planets and verify their names and costs.
3. Scan planet 1 and confirm the three traits are shown.
4. Attempt travel without enough fuel and confirm fuel is unchanged.
5. Travel to a non-viable planet, then a viable one, and confirm the win screen.
6. Reach zero fuel after a non-viable trip and confirm the loss screen.
