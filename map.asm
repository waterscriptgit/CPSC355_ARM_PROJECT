// Immutable galaxy data and safe indexed access to planet records.
.arch armv8-a
.include "game.inc"

.section .rodata
.balign 8
planet_aurora:   .asciz "Aurora"
planet_borealis: .asciz "Borealis"
planet_cinder:   .asciz "Cinder"
planet_dione:    .asciz "Dione"
planet_erebus:   .asciz "Erebus"
planet_fathom:   .asciz "Fathom"
planet_gaia:     .asciz "Gaia"
planet_helios:   .asciz "Helios"
planet_icarus:   .asciz "Icarus"
planet_juniper:  .asciz "Juniper"

hint_aurora:   .asciz "Water and an active power signature detected."
hint_borealis: .asciz "Water, energy, and organic nutrients detected."
hint_cinder:   .asciz "Energy and organic nutrients detected."
hint_dione:    .asciz "A substantial liquid-water signature detected."
hint_erebus:   .asciz "The surface scan found no viable-life indicators."
hint_fathom:   .asciz "Water and nutrients detected beneath dense clouds."
hint_gaia:     .asciz "Water, energy, and organic nutrients detected."
hint_helios:   .asciz "A strong energy source was detected."
hint_icarus:   .asciz "Water and an active power signature detected."
hint_juniper:  .asciz "Organic nutrients were detected in the soil."

.balign 8
.global map_planets
.type map_planets, %object
map_planets:
    .xword planet_aurora
    .word  TRAIT_WATER | TRAIT_ENERGY
    .word  3
    .xword hint_aurora

    .xword planet_borealis
    .word  TRAIT_VIABLE
    .word  5
    .xword hint_borealis

    .xword planet_cinder
    .word  TRAIT_ENERGY | TRAIT_NUTRIENTS
    .word  4
    .xword hint_cinder

    .xword planet_dione
    .word  TRAIT_WATER
    .word  3
    .xword hint_dione

    .xword planet_erebus
    .word  0
    .word  4
    .xword hint_erebus

    .xword planet_fathom
    .word  TRAIT_WATER | TRAIT_NUTRIENTS
    .word  5
    .xword hint_fathom

    .xword planet_gaia
    .word  TRAIT_VIABLE
    .word  6
    .xword hint_gaia

    .xword planet_helios
    .word  TRAIT_ENERGY
    .word  3
    .xword hint_helios

    .xword planet_icarus
    .word  TRAIT_WATER | TRAIT_ENERGY
    .word  5
    .xword hint_icarus

    .xword planet_juniper
    .word  TRAIT_NUTRIENTS
    .word  4
    .xword hint_juniper

.section .text
.balign 4
.global map_get_planet
.type map_get_planet, %function
// x0 = pointer to planet record for zero-based index w0, or 0 when invalid.
map_get_planet:
    cmp     w0, #PLANET_COUNT
    b.hs    .Lmap_invalid_index

    uxtw    x0, w0
    mov     x1, #PLANET_SIZE
    adrp    x2, map_planets
    add     x2, x2, :lo12:map_planets
    madd    x0, x0, x1, x2
    ret

.Lmap_invalid_index:
    mov     x0, xzr
    ret

