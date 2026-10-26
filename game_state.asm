// Persistent game state. Values live in memory so they survive subroutine calls.
.arch armv8-a
include(`game.inc')dnl

.section .bss
.balign 4
game_fuel:       .skip 4
game_location:   .skip 4
game_scanned:    .skip PLANET_COUNT

.section .text
.balign 4
.global game_init
.type game_init, %function
game_init:
    adrp    x1, game_fuel
    add     x1, x1, :lo12:game_fuel
    mov     w0, #INITIAL_FUEL
    str     w0, [x1]

    adrp    x1, game_location
    add     x1, x1, :lo12:game_location
    mov     w0, #-1
    str     w0, [x1]

    adrp    x1, game_scanned
    add     x1, x1, :lo12:game_scanned
    mov     w0, wzr
    mov     w2, #PLANET_COUNT
.Lclear_scanned:
    strb    w0, [x1], #1
    subs    w2, w2, #1
    b.ne    .Lclear_scanned
    ret

.global game_get_fuel
.type game_get_fuel, %function
// w0 = remaining fuel.
game_get_fuel:
    adrp    x1, game_fuel
    add     x1, x1, :lo12:game_fuel
    ldr     w0, [x1]
    ret

.global game_try_spend_fuel
.type game_try_spend_fuel, %function
// w0 = requested cost. Returns w0 = 1 and subtracts it, or 0 if unaffordable.
game_try_spend_fuel:
    adrp    x1, game_fuel
    add     x1, x1, :lo12:game_fuel
    ldr     w2, [x1]
    cmp     w2, w0
    b.lt    .Lfuel_unavailable
    sub     w2, w2, w0
    str     w2, [x1]
    mov     w0, #1
    ret
.Lfuel_unavailable:
    mov     w0, wzr
    ret

.global game_set_location
.type game_set_location, %function
// w0 = zero-based planet index.
game_set_location:
    adrp    x1, game_location
    add     x1, x1, :lo12:game_location
    str     w0, [x1]
    ret

.global game_mark_scanned
.type game_mark_scanned, %function
// w0 = zero-based planet index. Invalid indexes are ignored.
game_mark_scanned:
    cmp     w0, #PLANET_COUNT
    b.hs    .Lmark_done
    adrp    x1, game_scanned
    add     x1, x1, :lo12:game_scanned
    mov     w2, #1
    strb    w2, [x1, w0, uxtw]
.Lmark_done:
    ret
