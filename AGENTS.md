# Project Contributor Guide

## Purpose

This repository contains a text-based spaceship exploration game written in
ARMv8/AArch64 assembly for CPSC 355. Keep changes small, modular, and easy to
explain during the final presentation.

## Build and Run

Build on the course AArch64 server. Source files use `m4` preprocessing before
they are assembled and linked:

```sh
for file in main map game_state input ui game_logic; do
    m4 "$file.asm" > "$file.s"
done
gcc -g -Wall -o spaceship \
    main.s map.s game_state.s input.s ui.s game_logic.s
./spaceship
```

Generated `.s` files, object files, and the `spaceship` executable must not be
committed.

## Source Layout

- `main.asm`: overall game flow and menu dispatch only.
- `game.inc`: shared constants, action values, and planet-record offsets.
- `map.asm`: immutable planet records and `map_get_planet`.
- `game_state.asm`: persistent mutable state and state access functions.
- `game_logic.asm`: study/travel rules plus win/loss decisions.
- `input.asm`: terminal input and invalid-input recovery.
- `ui.asm`: all user-visible text and output procedures.

Do not duplicate shared constants or record offsets. Change `game.inc` first,
then update every module that consumes the affected layout.

## AArch64 Rules

- Follow the AArch64 Procedure Call Standard.
- Use `x0`-`x7` / `w0`-`w7` for arguments and return values.
- Treat `x0`-`x18` as caller-saved.
- Save and restore every callee-saved register used (`x19`-`x28`, `x29`, and
  `x30`).
- Keep `sp` 16-byte aligned before every `bl` instruction.
- Store state that must survive calls in `.bss`; do not rely on caller-saved
  registers for persistent game state.
- Keep labels local to a source file where possible by using `.L` prefixes.

## Change and Test Expectations

1. Keep input handling in `input.asm` and player-facing strings/output in
   `ui.asm`.
2. Add or update comments for every exported procedure: purpose, input,
   output, and side effects.
3. Test the changed normal path and relevant invalid-input, insufficient-fuel,
   repeat-action, and terminal win/loss paths on the course server.
4. Run `git diff --check` before committing.
5. Keep commits focused and do not commit local IDE settings, generated files,
   credentials, or course-server artifacts.

