# Spaceship Exploration Program - Architecture

The game is a text-based ARMv8/AArch64 program. The player starts with a finite
fuel supply, inspects a fixed galaxy of ten planets, and travels to a chosen
planet. A planet is viable only when its trait bit mask contains water, an
energy source, and nutrients.

## Module boundaries

| Module | Responsibility |
| --- | --- |
| `main.asm` | Main loop and action dispatch |
| `map.asm` | Immutable planet records and safe indexed lookup |
| `game_state.asm` | Persistent fuel and visit state |
| `input.asm` | Integer input and invalid-input recovery |
| `ui.asm` | Terminal output only |
| `game_logic.asm` | Scan/travel workflows and win/loss decisions |
| `game.inc` | Shared constants, record offsets, and action values |

Keeping the map, input, state, and display work separate means each part can be
tested without changing the game loop. It also keeps the course-specific I/O
assumption in `input.asm` and `ui.asm` rather than spreading it through the
program.

## Calling convention

The source follows the AArch64 Procedure Call Standard:

- Arguments and return values use `x0`-`x7` (`w0`-`w7` for 32-bit values).
- `x0`-`x18` are treated as caller-saved.
- Any procedure using `x19`-`x28`, `x29`, or `x30` saves and restores them.
- Every non-leaf procedure creates a stack frame and keeps `sp` 16-byte aligned
  before every call.

## Data model

Each planet occupies a 24-byte record in `map_planets`:

```text
offset 0:  8-byte pointer to name
offset 8:  4-byte trait mask
offset 12: 4-byte travel cost
offset 16: 8-byte pointer to a scanner hint
```

Mutable game state lives in `.bss`, not in registers, so values survive calls
between menu actions. The trait mask makes the viability check a single
bitwise-and followed by a comparison.
