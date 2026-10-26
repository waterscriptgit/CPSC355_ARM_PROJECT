// Workflows that combine the map, persistent state, and user interface.
.arch armv8-a
.include "game.inc"

.section .text
.balign 4
.global game_action_list_planets
.type game_action_list_planets, %function
game_action_list_planets:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    bl      ui_print_planets
    mov     w0, wzr
    ldp     x29, x30, [sp], #16
    ret
.global game_action_help
.type game_action_help, %function
game_action_help:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    bl      ui_print_help
    mov     w0, wzr
    ldp     x29, x30, [sp], #16
    ret

.global game_action_scan
.type game_action_scan, %function
// w0 = one-based planet number. Returns 0 so the main loop continues.
game_action_scan:
    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]

    sub     w19, w0, #1
    mov     w0, w19
    bl      map_get_planet
    cbz     x0, .Lscan_invalid
    mov     x20, x0

    mov     w0, w19
    bl      game_mark_scanned
    mov     x0, x20
    bl      ui_print_scan_result
    mov     w0, wzr
    b       .Lscan_done

.Lscan_invalid:
    bl      ui_print_invalid_planet
    mov     w0, wzr
.Lscan_done:
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret

.global game_action_travel
.type game_action_travel, %function
// w0 = one-based planet number. Returns 0=continue, 1=won, 2=lost.
game_action_travel:
    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]

    sub     w19, w0, #1
    mov     w0, w19
    bl      map_get_planet
    cbz     x0, .Ltravel_invalid
    mov     x20, x0

    ldr     w0, [x20, #PLANET_TRAVEL_COST]
    bl      game_try_spend_fuel
    cbz     w0, .Ltravel_no_fuel

    mov     w0, w19
    bl      game_set_location
    mov     x0, x20
    bl      ui_print_travel_start

    ldr     w0, [x20, #PLANET_TRAITS]
    and     w0, w0, #TRAIT_VIABLE
    cmp     w0, #TRAIT_VIABLE
    b.eq    .Ltravel_win

    mov     x0, x20
    bl      ui_print_nonviable
    bl      game_get_fuel
    cbz     w0, .Ltravel_loss
    mov     w0, wzr
    b       .Ltravel_done

.Ltravel_win:
    mov     x0, x20
    bl      ui_print_win
    mov     w0, #1
    b       .Ltravel_done

.Ltravel_loss:
    bl      ui_print_loss
    mov     w0, #2
    b       .Ltravel_done

.Ltravel_no_fuel:
    bl      ui_print_insufficient_fuel
    mov     w0, wzr
    b       .Ltravel_done

.Ltravel_invalid:
    bl      ui_print_invalid_planet
    mov     w0, wzr
.Ltravel_done:
    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret

