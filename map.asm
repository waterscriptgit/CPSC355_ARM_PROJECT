// We keep a bigger list here and pick three planets when the game starts.
.arch armv8-a
include(`game.inc')dnl

.section .rodata
.balign 8

// Four good options. The rest have something important missing.
aurelia_name: .asciz "Aurelia"
aurelia_hint: .asciz "Temperate oceans and a dense nitrogen-oxygen atmosphere."
aurelia_study: .asciz "Liquid water, stable oxygen, low radiation, and organic compounds are confirmed."
calypso_name: .asciz "Calypso"
calypso_hint: .asciz "Forest-covered continents with an active magnetic field."
calypso_study: .asciz "The air, water cycle, soil nutrients, and energy sources look good for settlement."
elysia_name: .asciz "Elysia"
elysia_hint: .asciz "Mild climate bands and large freshwater basins detected."
elysia_study: .asciz "The surface has stable water, oxygen, and fertile land."
haven_name: .asciz "Haven"
haven_hint: .asciz "A blue-green world with a calm atmosphere and moderate gravity."
haven_study: .asciz "Water, breathable air, useful minerals, and organic nutrients are all confirmed."

// Bad options. Some look tempting before the detailed scan.
miller_name: .asciz "Miller"
miller_hint: .asciz "Extremely abundant water and a thin atmosphere."
miller_study: .asciz "Recurring tidal waves and unstable gravity make this place unsafe."
mann_name: .asciz "Mann"
mann_hint: .asciz "Oxygen readings and subsurface water deposits detected."
mann_study: .asciz "The report was wrong. The surface is frozen, low-pressure, and nearly airless."
cinder_name: .asciz "Cinder"
cinder_hint: .asciz "Strong geothermal power signatures beneath a volcanic crust."
cinder_study: .asciz "There is plenty of energy, but toxic ash and no liquid water."
dione_name: .asciz "Dione"
dione_hint: .asciz "Bright ice fields surround shallow polar seas."
dione_study: .asciz "There is water, but radiation and the weak atmosphere are dangerous."
erebus_name: .asciz "Erebus"
erebus_hint: .asciz "Dark basalt plains with faint mineral reflections."
erebus_study: .asciz "No water, breathable atmosphere, or reliable energy source was found."
fathom_name: .asciz "Fathom"
fathom_hint: .asciz "Cloud-covered oceans hide a warm deep-water layer."
fathom_study: .asciz "Water and nutrients exist, but corrosive gases make it unsafe."
helios_name: .asciz "Helios"
helios_hint: .asciz "Old solar collectors still transmit power."
helios_study: .asciz "The power is useful, but heat and radiation are fatal."
icarus_name: .asciz "Icarus"
icarus_hint: .asciz "A warm ocean reflects strong sunlight near the equator."
icarus_study: .asciz "Solar storms strip away the atmosphere too quickly."
juniper_name: .asciz "Juniper"
juniper_hint: .asciz "Green patterns show up in sheltered valleys."
juniper_study: .asciz "There are nutrients, but not enough oxygen for humans."
kestrel_name: .asciz "Kestrel"
kestrel_hint: .asciz "Rocky plateaus have a weak but stable magnetic signature."
kestrel_study: .asciz "Radiation is manageable, but there is no accessible water or food source."
lyra_name: .asciz "Lyra"
lyra_hint: .asciz "A pale atmosphere covers wide frozen plains."
lyra_study: .asciz "There is ice and trace oxygen, but it is much too cold."
nereid_name: .asciz "Nereid"
nereid_hint: .asciz "Subsurface oceans produce occasional heat plumes."
nereid_study: .asciz "Water and heat exist, but the pressure is crushing and air is missing."
oberon_name: .asciz "Oberon"
oberon_hint: .asciz "Wide plains show old river channels."
oberon_study: .asciz "The rivers are gone and the atmosphere is too thin."
phobos_name: .asciz "Phobos"
phobos_hint: .asciz "Fast-spinning rocky terrain contains rich mineral deposits."
phobos_study: .asciz "There are minerals for energy, but no water or stable air."
rhea_name: .asciz "Rhea"
rhea_hint: .asciz "Green spectral readings appear near a chain of lakes."
rhea_study: .asciz "The lakes are acidic and the air is full of sulfur compounds."
titan_name: .asciz "Titan"
titan_hint: .asciz "A thick orange atmosphere and hydrocarbon seas cover the surface."
titan_study: .asciz "There is potential energy, but no water or oxygen."

// name, traits, travel cost, basic report, detailed report
.balign 8
map_templates:
    .xword aurelia_name
    .word TRAIT_VIABLE, 9
    .xword aurelia_hint, aurelia_study
    .xword calypso_name
    .word TRAIT_VIABLE, 8
    .xword calypso_hint, calypso_study
    .xword elysia_name
    .word TRAIT_VIABLE, 10
    .xword elysia_hint, elysia_study
    .xword haven_name
    .word TRAIT_VIABLE, 7
    .xword haven_hint, haven_study
    .xword miller_name
    .word TRAIT_WATER | TRAIT_ENERGY, 7
    .xword miller_hint, miller_study
    .xword mann_name
    .word TRAIT_ENERGY, 8
    .xword mann_hint, mann_study
    .xword cinder_name
    .word TRAIT_ENERGY, 6
    .xword cinder_hint, cinder_study
    .xword dione_name
    .word TRAIT_WATER, 7
    .xword dione_hint, dione_study
    .xword erebus_name
    .word 0, 5
    .xword erebus_hint, erebus_study
    .xword fathom_name
    .word TRAIT_WATER | TRAIT_NUTRIENTS, 8
    .xword fathom_hint, fathom_study
    .xword helios_name
    .word TRAIT_ENERGY, 6
    .xword helios_hint, helios_study
    .xword icarus_name
    .word TRAIT_WATER, 7
    .xword icarus_hint, icarus_study
    .xword juniper_name
    .word TRAIT_NUTRIENTS, 5
    .xword juniper_hint, juniper_study
    .xword kestrel_name
    .word TRAIT_ENERGY, 6
    .xword kestrel_hint, kestrel_study
    .xword lyra_name
    .word TRAIT_WATER, 8
    .xword lyra_hint, lyra_study
    .xword nereid_name
    .word TRAIT_WATER | TRAIT_ENERGY, 9
    .xword nereid_hint, nereid_study
    .xword oberon_name
    .word TRAIT_WATER, 5
    .xword oberon_hint, oberon_study
    .xword phobos_name
    .word TRAIT_ENERGY, 6
    .xword phobos_hint, phobos_study
    .xword rhea_name
    .word TRAIT_WATER | TRAIT_NUTRIENTS, 7
    .xword rhea_hint, rhea_study
    .xword titan_name
    .word TRAIT_ENERGY, 8
    .xword titan_hint, titan_study

.section .bss
.balign 8
// These are pointers to the three templates picked for this game.
.global map_planets
.type map_planets, %object
map_planets: .skip PLANET_COUNT * 8

.section .text
.balign 4

.global map_build_candidates
.type map_build_candidates, %function
// Pick three different templates. We might get zero, one, or more good planets.
map_build_candidates:
    stp     x29, x30, [sp, #-64]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]
    stp     x21, x22, [sp, #32]

    // Seed the standard C random generator when the program starts.
    mov     x0, xzr
    bl      time
    bl      srand

    adrp    x19, map_planets
    add     x19, x19, :lo12:map_planets
    mov     w20, wzr

.Lpick_next:
    bl      rand
    mov     w1, #TEMPLATE_COUNT
    udiv    w2, w0, w1
    msub    w21, w2, w1, w0

    // Turn the random index into a template pointer.
    mov     w0, w21
    bl      .Ltemplate_from_index
    mov     x22, x0

    // Do not put the same template in the candidate list twice.
    mov     w3, wzr
.Lcheck_duplicate:
    cmp     w3, w20
    b.ge    .Lstore_candidate
    ldr     x4, [x19, w3, uxtw #3]
    cmp     x4, x22
    b.eq    .Lpick_next
    add     w3, w3, #1
    b       .Lcheck_duplicate

.Lstore_candidate:
    str     x22, [x19, w20, uxtw #3]
    add     w20, w20, #1
    cmp     w20, #PLANET_COUNT
    b.lt    .Lpick_next

    ldp     x19, x20, [sp, #16]
    ldp     x21, x22, [sp, #32]
    ldp     x29, x30, [sp], #64
    ret

// w0 is a template number. x0 comes back as its record address.
.Ltemplate_from_index:
    adrp    x1, map_templates
    add     x1, x1, :lo12:map_templates
    mov     x2, #PLANET_SIZE
    uxtw    x0, w0
    madd    x0, x0, x2, x1
    ret

.global map_get_planet
.type map_get_planet, %function
// w0 is 0, 1, or 2. x0 comes back as that candidate's record pointer.
map_get_planet:
    cmp     w0, #PLANET_COUNT
    b.hs    .Lbad_planet_index
    adrp    x1, map_planets
    add     x1, x1, :lo12:map_planets
    ldr     x0, [x1, w0, uxtw #3]
    ret

.Lbad_planet_index:
    mov     x0, xzr
    ret
