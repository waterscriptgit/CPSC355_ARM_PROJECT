// Persistent game state.
// Values are stored in memory so they survive between function calls.

.arch armv8-a
include(`game.inc')dnl


.section .bss
.balign 4

game_fuel:       .skip 4
game_location:   .skip 4

// One byte for each planet.
// 0 = not studied/visited
// 1 = studied/visited
game_studied:    .skip PLANET_COUNT
game_visited:    .skip PLANET_COUNT


.section .text
.balign 4


.global game_init
.type game_init, %function

game_init:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    bl      map_build_candidates

    // Start the player with INITIAL_FUEL.
    adrp    x1, game_fuel
    add     x1, x1, :lo12:game_fuel
    mov     w0, #INITIAL_FUEL
    str     w0, [x1]


    // -1 means the player has not landed anywhere yet.
    adrp    x1, game_location
    add     x1, x1, :lo12:game_location
    mov     w0, #-1
    str     w0, [x1]


    // Clear the studied array.
    adrp    x1, game_studied
    add     x1, x1, :lo12:game_studied

    mov     w0, wzr
    mov     w2, #PLANET_COUNT

.Lclear_studied:

    strb    w0, [x1], #1

    subs    w2, w2, #1
    b.ne    .Lclear_studied


    // Clear the visited array.
    adrp    x1, game_visited
    add     x1, x1, :lo12:game_visited

    mov     w0, wzr
    mov     w2, #PLANET_COUNT

.Lclear_visited:

    strb    w0, [x1], #1

    subs    w2, w2, #1
    b.ne    .Lclear_visited

    ldp     x29, x30, [sp], #16
    ret



.global game_get_fuel
.type game_get_fuel, %function

game_get_fuel:

    adrp    x1, game_fuel
    add     x1, x1, :lo12:game_fuel

    // Load the current fuel into w0.
    ldr     w0, [x1]

    ret



.global game_try_spend_fuel
.type game_try_spend_fuel, %function

game_try_spend_fuel:

    adrp    x1, game_fuel
    add     x1, x1, :lo12:game_fuel

    // w2 = current fuel.
    ldr     w2, [x1]

    // Compare current fuel against the cost.
    cmp     w2, w0
    b.lt    .Lfuel_unavailable

    // Subtract the cost and save the new fuel amount.
    sub     w2, w2, w0
    str     w2, [x1]

    // Return success.
    mov     w0, #1
    ret


.Lfuel_unavailable:

    // Return failure.
    mov     w0, wzr
    ret



.global game_set_location
.type game_set_location, %function

game_set_location:

    adrp    x1, game_location
    add     x1, x1, :lo12:game_location

    str     w0, [x1]

    ret



.global game_mark_studied
.type game_mark_studied, %function

game_mark_studied:

    // Ignore an invalid planet index.
    cmp     w0, #PLANET_COUNT
    b.hs    .Lmark_studied_done

    adrp    x1, game_studied
    add     x1, x1, :lo12:game_studied

    mov     w2, #1

    // Store 1 for this planet.
    strb    w2, [x1, w0, uxtw]

.Lmark_studied_done:
    ret



.global game_is_studied
.type game_is_studied, %function

game_is_studied:

    // Save the index before using w0 for the return value.
    mov     w2, w0

    cmp     w2, #PLANET_COUNT
    b.hs    .Lis_studied_invalid

    adrp    x1, game_studied
    add     x1, x1, :lo12:game_studied

    // Load either 0 or 1.
    ldrb    w0, [x1, w2, uxtw]

    ret


.Lis_studied_invalid:

    mov     w0, wzr
    ret



.global game_mark_visited
.type game_mark_visited, %function

game_mark_visited:

    cmp     w0, #PLANET_COUNT
    b.hs    .Lmark_visited_done

    adrp    x1, game_visited
    add     x1, x1, :lo12:game_visited

    mov     w2, #1
    strb    w2, [x1, w0, uxtw]

.Lmark_visited_done:
    ret



.global game_is_visited
.type game_is_visited, %function

game_is_visited:

    mov     w2, w0

    cmp     w2, #PLANET_COUNT
    b.hs    .Lis_visited_invalid

    adrp    x1, game_visited
    add     x1, x1, :lo12:game_visited

    ldrb    w0, [x1, w2, uxtw]

    ret


.Lis_visited_invalid:

    mov     w0, wzr
    ret



.global game_can_afford_travel
.type game_can_afford_travel, %function

game_can_afford_travel:

    stp     x29, x30, [sp, #-32]!
    mov     x29, sp

    // Save the travel cost because game_get_fuel uses w0.
    str     w0, [sp, #16]

    // w0 now becomes the player's current fuel.
    bl      game_get_fuel

    // Restore the travel cost into w1.
    ldr     w1, [sp, #16]

    // Compare:
    // current fuel < travel cost?
    cmp     w0, w1
    b.lt    .Lcant_afford

    // The player has enough fuel.
    mov     w0, #1
    b       .Lafford_done


.Lcant_afford:

    // The player does not have enough fuel.
    mov     w0, wzr


.Lafford_done:

    ldp     x29, x30, [sp], #32
    ret
