// Shared constants and record layout for the Spaceship Exploration Program.
// All source files include this file so their interfaces stay compatible.

.equ PLANET_COUNT,          3
.equ TEMPLATE_COUNT,        20
.equ INITIAL_FUEL,          20
.equ STUDY_COST,            2

// Planet record:
// name pointer
// trait bit mask
// travel fuel cost
// initial report pointer
// detailed study report pointer
.equ PLANET_NAME,           0
.equ PLANET_TRAITS,         8
.equ PLANET_TRAVEL_COST,    12
.equ PLANET_HINT,           16
.equ PLANET_STUDY,          24
.equ PLANET_SIZE,           32

// Trait bits.
// A viable planet must have all three traits.
.equ TRAIT_WATER,           1
.equ TRAIT_ENERGY,          2
.equ TRAIT_NUTRIENTS,       4
.equ TRAIT_VIABLE,          7

// Menu actions.
.equ ACTION_LIST_PLANETS,   1
.equ ACTION_STUDY_PLANET,   2
.equ ACTION_TRAVEL,         3
.equ ACTION_HELP,           4
.equ ACTION_QUIT,           5

// Mission outcome values.
.equ GAME_RUNNING, 0
.equ GAME_WON,     1
.equ GAME_LOST,    2