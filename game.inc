// Shared constants and record layout for the Spaceship Exploration Program.
// All source files include this file so their interfaces stay compatible.

.equ PLANET_COUNT,          10
.equ INITIAL_FUEL,          30

// Planet record: name pointer, trait bit mask, travel fuel cost, hint pointer.
.equ PLANET_NAME,           0
.equ PLANET_TRAITS,         8
.equ PLANET_TRAVEL_COST,    12
.equ PLANET_HINT,           16
.equ PLANET_SIZE,           24

// Trait bits. A viable planet has all three bits set.
.equ TRAIT_WATER,           1
.equ TRAIT_ENERGY,          2
.equ TRAIT_NUTRIENTS,       4
.equ TRAIT_VIABLE,          7

// Menu actions.
.equ ACTION_LIST_PLANETS,   1
.equ ACTION_SCAN_PLANET,    2
.equ ACTION_TRAVEL,         3
.equ ACTION_HELP,           4
.equ ACTION_QUIT,           5
