# Spaceship Exploration Program

This project is a text-based space exploration game written in ARMv8/AArch64 assembly.

Earth is becoming unable to support human life, and the player takes the role of a former NASA pilot chosen to search for a new home for humanity. The game has 20 planet templates and randomly chooses three different candidates at the beginning of each run.

The player must decide how to use the remaining fuel. Planets can be studied remotely for additional information or travelled to directly. Some runs have a habitable candidate; other unlucky runs do not, so humanity can lose even with good choices.

The mission ends when the player finds the habitable planet, abandons the mission, quits, or no longer has enough fuel to continue.

## Gameplay

The game begins with a short prologue followed by the player's first decision:

1. Enter the wormhole and continue the mission.
2. Abandon the mission and return to Earth.

Entering the wormhole damages the spacecraft and leaves the player with 20 units of fuel.

After entering the system, the main menu allows the player to:

1. View candidate planets
2. Study a planet
3. Travel to a planet
4. View mission help
5. Quit the mission

There are three candidate planets each run. They are picked without duplicates from the 20-template pool, so both their names and their order can change whenever the game starts.

Studying a planet costs 2 fuel and reveals a more detailed scientific report. Studying the same planet again does not charge fuel a second time.

Travelling costs more fuel and permanently uses that fuel. Once a planet has been visited, the player cannot waste fuel by travelling to the same planet again.

## Planet Habitability

The game uses several simple scientific ideas to help the player determine whether a planet could support human life.

Important conditions include:

- liquid water;
- a stable atmosphere;
- reasonable surface temperature;
- manageable radiation;
- suitable pressure and gravity; and
- resources that could support long-term human settlement.

The player is encouraged to compare the original scientist reports with the detailed study results before deciding where to travel.

## Project Structure

The project is separated into several assembly files so that each part of the program has a clear responsibility.

| File | Responsibility |
| --- | --- |
| `main.asm` | Controls the overall game flow, menus, branching, and player choices |
| `map.asm` | Stores 20 planet templates and picks three candidates at startup |
| `game_state.asm` | Stores fuel, current location, studied planets, and visited planets |
| `game_logic.asm` | Handles studying, travelling, habitability checks, and win/loss conditions |
| `input.asm` | Reads integer input and recovers from invalid input |
| `ui.asm` | Stores and displays all terminal messages and story text |
| `game.inc` | Stores shared constants, menu values, planet offsets, and trait values |

Keeping these responsibilities separate makes the code easier to understand, test, and modify.

## Technical Implementation

The project uses several ARMv8/AArch64 concepts covered in the course.

### Persistent Game State

Values that must survive between function calls are stored in memory inside the `.bss` section.

This includes:

- remaining fuel;
- current planet location;
- which planets have been studied; and
- which planets have already been visited.

For example, the player's fuel is loaded from memory when needed and written back after fuel is spent.

### Planet Records

The planets are stored as fixed-size records in `map.asm`.

Each record contains:

```text
Planet name
Habitability trait information
Travel fuel cost
Initial scientist report
Detailed study report
```

A random template index is converted into an address using the record size. The game then stores three selected-record pointers for the current mission.

### Function Calls and Registers

Functions pass arguments and return values using ARM registers such as `w0` and `x0`.

For example:

```text
w0 = integer argument or return value
x0 = pointer to a planet record
```

Functions that call other functions create stack frames and preserve registers when necessary.

The stack pointer remains aligned according to the AArch64 calling convention.

### Branching and Control Flow

The game makes heavy use of:

```asm
cmp
b.eq
b.ne
b.lt
b.gt
cbz
cbnz
```

These instructions control menu choices, input validation, fuel checks, planet selection, and win/loss decisions.

For example, the main menu compares the player's input against each possible action and branches to the correct part of the program.

### Fuel Checking

There are two different fuel operations.

`game_can_afford_travel` checks whether the player has enough fuel without changing the stored fuel.

`game_try_spend_fuel` checks the fuel and subtracts the requested amount when the player can afford it.

Keeping these operations separate allows the program to check whether an action is possible before changing the game state.

## Input Validation and Error Handling

Input validation is handled mainly through `input.asm` and branching in `main.asm`.

The program reads integers using `scanf`.

If the player enters valid numeric input, the number is returned normally.

If the player enters non-numeric input such as:

```text
abc
```

`scanf` fails to convert the input. The program then uses `getchar` to remove the remaining invalid characters from the input buffer before returning an invalid value.

This prevents the same bad input from causing every future input attempt to fail.

### Invalid Main Menu Input

If the player enters a number that does not correspond to a menu option, the program displays an error and returns to the main menu.

Examples:

```text
0
6
99
```

### Planet Selection

Inside the Study and Travel menus, valid planet numbers are:

```text
1
2
3
```

The player can also enter:

```text
0
```

to return to the main menu.

If an invalid planet number is entered, the player remains inside the Study or Travel submenu instead of being returned to the main menu.

### Insufficient Fuel

Before travelling, the game checks whether the selected trip can be afforded.

If there is not enough fuel:

- the trip does not happen;
- no fuel is deducted; and
- an error message is displayed.

The same idea is used when the player attempts to study a planet without enough fuel.

### Repeated Actions

The game keeps track of studied and visited planets.

A planet that has already been studied can be viewed again without spending another 2 fuel.

A planet that has already been visited cannot be travelled to again, preventing the player from accidentally wasting fuel.

### UI Pause

Longer screens such as planet information, detailed study reports, and mission help use a:

```text
Press Enter to continue...
```

prompt.

This gives the player time to read the information before the main menu is displayed again.

## Build and Run

The project uses GNU AArch64 assembly syntax and the `m4` preprocessor.

The program should be built on the ARM/AArch64 course server.

First generate the `.s` files:

```sh
for file in main map game_state input ui game_logic; do
    m4 "$file.asm" > "$file.s"
done
```

Compile and link:

```sh
gcc -g -Wall -o spaceship \
    main.s map.s game_state.s input.s ui.s game_logic.s
```

Run the game:

```sh
./spaceship
```

The generated `.s` files and `spaceship` executable are ignored by Git.

They can be removed using:

```sh
rm *.s spaceship
```

## Manual Test Cases

The following cases can be used to test functionality and error handling.

### Input Recovery

Enter:

```text
abc
```

at the main menu.

Expected result:

- invalid input is detected;
- the program does not crash;
- the menu appears again; and
- a valid choice entered afterward still works.

### Invalid Menu Choice

Enter:

```text
0
6
99
```

Expected result:

- invalid choice message;
- no game state changes;
- menu is shown again.

### Invalid Planet Number

Enter Study or Travel and choose:

```text
4
99
-1
```

Expected result:

- invalid planet message;
- player remains inside the submenu;
- no fuel is deducted.

### Back Option

Enter Study or Travel and choose:

```text
0
```

Expected result:

- return to the main menu;
- no fuel is deducted.

### Study a Planet

Start with:

```text
Fuel: 20
```

Study any listed candidate.

Expected result:

```text
Fuel: 18
```

and that candidate's detailed report is displayed.

### Study the Same Planet Twice

Study the same candidate again.

Expected result:

```text
Fuel remains: 18
```

The report can still be viewed.

### Travel to a Non-Habitable Planet

Travel to a candidate that turns out to be unsafe.

Expected result:

```text
20 -> 13 fuel
```

The planet is reported as unsuitable and the mission continues if another planet can still be reached.

### Repeat Travel

Attempt to travel to the same planet again.

Expected result:

- the game reports that the planet was already visited;
- no additional fuel is deducted.

### Insufficient Fuel

Attempt to travel to a planet whose cost is greater than the player's remaining fuel.

Expected result:

- the trip is rejected;
- fuel remains unchanged.

### Random Candidate List

Start the game several times.

Expected result:

- every list contains three different planet names;
- the names and order can change from one run to another; and
- some runs have no habitable candidate, so losing is possible even with enough fuel.

### Winning Path

On a run with a viable candidate, study the candidates and travel to the one whose report confirms the needed conditions.

Expected result:

- mission success.

### Mission Failure

Use enough fuel studying and travelling to non-habitable planets that no unvisited planet can still be reached.

Expected result:

- the game detects that there are no affordable travel options remaining;
- the mission-failure ending is displayed;
- the program exits normally.

### Abandon Mission

Choose option `2` before entering the wormhole.

Expected result:

- the mission is abandoned;
- the failure story is displayed;
- the main game menu is never entered.

## Current Status

The main game flow, planet system, fuel management, input validation, studying, travelling, and win/loss logic have been implemented.

Current work is focused on testing the different paths through the game, handling edge cases, improving readability, and polishing the terminal interface.

The template pool is fixed so each planet can be explained and tested, but the three candidates are randomized every time the program starts.
