// Immutable galaxy data and safe indexed access to planet records.
.arch armv8-a
include(`game.inc')dnl

.section .rodata
.balign 8

// ------------------------------------------------------------
// PLANET NAMES
// ------------------------------------------------------------

planet_aurelia:
    .asciz "Aurelia"

planet_miller:
    .asciz "Miller"

planet_mann:
    .asciz "Mann"


// ------------------------------------------------------------
// INITIAL REPORTS
//
// These are the reports the player sees before studying
// the planet in greater detail.
// ------------------------------------------------------------

hint_aurelia:
    .asciz "Temperature: 18 C | Atmosphere: Nitrogen/Oxygen | Water: Large oceans | Gravity: 0.96 Earth | Radiation: Low"

hint_miller:
    .asciz "Temperature: 12 C | Atmosphere: Thin | Water: Extremely abundant | Gravity: 1.08 Earth | Radiation: Moderate"

hint_mann:
    .asciz "Temperature: 21 C | Atmosphere: Oxygen detected | Water: Subsurface deposits | Gravity: 1.01 Earth | Radiation: Low"


// ------------------------------------------------------------
// DETAILED STUDY REPORTS
//
// The player pays fuel to study a planet.
// These reports reveal more useful information.
// ------------------------------------------------------------

study_aurelia:
    .asciz "Atmospheric oxygen is stable. Liquid water is confirmed. Surface pressure is similar to Earth. A strong magnetic field protects the surface from radiation. Organic compounds are present. Habitability probability: HIGH."

study_miller:
    .asciz "Extreme gravitational tidal forces detected. Enormous recurring tidal waves cover most of the surface. Stable land is almost nonexistent. Long-term human settlement probability: VERY LOW."

study_mann:
    .asciz "WARNING: SENSOR DATA INCONSISTENCY. Surface temperature is approximately -68 C. Oxygen exists only in trace amounts. Water is permanently frozen and atmospheric pressure is extremely low. The original scientist transmission does not match the spacecraft observations."


// ------------------------------------------------------------
// PLANET RECORDS
//
// Each record is 32 bytes:
//
// 0  = name pointer
// 8  = trait mask
// 12 = travel cost
// 16 = initial report pointer
// 24 = detailed study report pointer
// ------------------------------------------------------------

.balign 8
.global map_planets
.type map_planets, %object

map_planets:

    // --------------------------------------------------------
    // Planet 1: Aurelia
    //
    // This is the only truly habitable planet.
    // It contains every required trait.
    // Travel cost = 9 fuel.
    // --------------------------------------------------------

    .xword planet_aurelia
    .word  TRAIT_VIABLE
    .word  9
    .xword hint_aurelia
    .xword study_aurelia


    // --------------------------------------------------------
    // Planet 2: Miller
    //
    // It has water and an energy source,
    // but conditions are too dangerous for human settlement.
    // Travel cost = 7 fuel.
    // --------------------------------------------------------

    .xword planet_miller
    .word  TRAIT_WATER | TRAIT_ENERGY
    .word  7
    .xword hint_miller
    .xword study_miller


    // --------------------------------------------------------
    // Planet 3: Mann
    //
    // The original report looks promising,
    // but detailed study exposes false information.
    // Travel cost = 8 fuel.
    // --------------------------------------------------------

    .xword planet_mann
    .word  TRAIT_ENERGY
    .word  8
    .xword hint_mann
    .xword study_mann


.section .text
.balign 4

.global map_get_planet
.type map_get_planet, %function

// w0 = zero-based planet index.
//
// Returns:
// x0 = pointer to the planet record
// x0 = 0 if the index is invalid.
map_get_planet:

    // Make sure the requested planet exists.
    cmp     w0, #PLANET_COUNT
    b.hs    .Lmap_invalid_index

    // Convert the 32-bit index into a 64-bit value.
    uxtw    x0, w0

    // Each planet record is PLANET_SIZE bytes.
    mov     x1, #PLANET_SIZE

    // Get the address of the first planet record.
    adrp    x2, map_planets
    add     x2, x2, :lo12:map_planets

    // Calculate:
    //
    // address = map_planets + (index * PLANET_SIZE)
    //
    // madd does:
    // x0 = x0 * x1 + x2
    madd    x0, x0, x1, x2

    ret


.Lmap_invalid_index:

    // Return 0 if the player entered an invalid planet.
    mov     x0, xzr
    ret
