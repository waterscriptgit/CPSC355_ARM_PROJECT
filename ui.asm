// Output boundary. Keeping all terminal text here makes future UI changes local.
.arch armv8-a
.include "game.inc"

.section .rodata
ui_banner:
    .asciz "\n=== Spaceship Exploration Program ===\n"
ui_status_format:
    .asciz "Fuel remaining: %d\n"
ui_menu:
    .asciz "\n1. List planets\n2. Scan a planet\n3. Travel to a planet\n4. Mission help\n5. Quit\n> "
ui_planet_heading:
    .asciz "\nKnown planets:\n"
ui_planet_row:
    .asciz "  %2d. %-10s Travel cost: %d\n"
ui_planet_prompt:
    .asciz "Planet number (1-10): "
ui_invalid_input:
    .asciz "Invalid choice. Enter one of the listed numbers.\n"
ui_invalid_planet:
    .asciz "Invalid planet number. Choose a value from 1 to 10.\n"
ui_help:
    .asciz "\nScan planets to reveal their life-support traits. Travel consumes fuel. A viable planet has water, energy, and nutrients.\n"
ui_scan_format:
    .asciz "\n--- %s scan report ---\n%s\nWater: %s\nEnergy: %s\nNutrients: %s\n"
ui_yes:
    .asciz "yes"
ui_no:
    .asciz "no"
ui_travel_format:
    .asciz "\nTravelling to %s costs %d fuel.\n"
ui_insufficient_fuel:
    .asciz "Not enough fuel for that trip.\n"
ui_nonviable_format:
    .asciz "%s is not viable. Continue exploring.\n"
ui_win_format:
    .asciz "\nMission success! %s has water, energy, and nutrients.\n"
ui_loss:
    .asciz "\nMission failed: fuel is depleted before a viable planet was reached.\n"
ui_quit:
    .asciz "\nMission ended by player.\n"

.section .text
.balign 4
.global ui_print_banner
.type ui_print_banner, %function
ui_print_banner:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    adrp    x0, ui_banner
    add     x0, x0, :lo12:ui_banner
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_status
.type ui_print_status, %function
ui_print_status:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    bl      game_get_fuel
    mov     w1, w0
    adrp    x0, ui_status_format
    add     x0, x0, :lo12:ui_status_format
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_menu
.type ui_print_menu, %function
ui_print_menu:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    adrp    x0, ui_menu
    add     x0, x0, :lo12:ui_menu
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_planets
.type ui_print_planets, %function
ui_print_planets:
    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]

    adrp    x0, ui_planet_heading
    add     x0, x0, :lo12:ui_planet_heading
    bl      printf

    mov     w19, wzr
.Lplanet_row:
    mov     w0, w19
    bl      map_get_planet
    mov     x20, x0

    add     w1, w19, #1
    ldr     x2, [x20, #PLANET_NAME]
    ldr     w3, [x20, #PLANET_TRAVEL_COST]
    adrp    x0, ui_planet_row
    add     x0, x0, :lo12:ui_planet_row
    bl      printf

    add     w19, w19, #1
    cmp     w19, #PLANET_COUNT
    b.lt    .Lplanet_row

    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret

.global ui_prompt_planet
.type ui_prompt_planet, %function
ui_prompt_planet:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    adrp    x0, ui_planet_prompt
    add     x0, x0, :lo12:ui_planet_prompt
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_invalid_input
.type ui_print_invalid_input, %function
ui_print_invalid_input:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    adrp    x0, ui_invalid_input
    add     x0, x0, :lo12:ui_invalid_input
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_invalid_planet
.type ui_print_invalid_planet, %function
ui_print_invalid_planet:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    adrp    x0, ui_invalid_planet
    add     x0, x0, :lo12:ui_invalid_planet
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_help
.type ui_print_help, %function
ui_print_help:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    adrp    x0, ui_help
    add     x0, x0, :lo12:ui_help
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_scan_result
.type ui_print_scan_result, %function
// x0 = planet record pointer.
ui_print_scan_result:
    stp     x29, x30, [sp, #-64]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]

    mov     x19, x0
    ldr     w20, [x19, #PLANET_TRAITS]

    adrp    x3, ui_no
    add     x3, x3, :lo12:ui_no
    tst     w20, #TRAIT_WATER
    b.eq    .Lwater_ready
    adrp    x3, ui_yes
    add     x3, x3, :lo12:ui_yes
.Lwater_ready:
    adrp    x4, ui_no
    add     x4, x4, :lo12:ui_no
    tst     w20, #TRAIT_ENERGY
    b.eq    .Lenergy_ready
    adrp    x4, ui_yes
    add     x4, x4, :lo12:ui_yes
.Lenergy_ready:
    adrp    x5, ui_no
    add     x5, x5, :lo12:ui_no
    tst     w20, #TRAIT_NUTRIENTS
    b.eq    .Lnutrients_ready
    adrp    x5, ui_yes
    add     x5, x5, :lo12:ui_yes
.Lnutrients_ready:
    ldr     x1, [x19, #PLANET_NAME]
    ldr     x2, [x19, #PLANET_HINT]
    adrp    x0, ui_scan_format
    add     x0, x0, :lo12:ui_scan_format
    bl      printf

    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #64
    ret

.global ui_print_travel_start
.type ui_print_travel_start, %function
// x0 = planet record pointer.
ui_print_travel_start:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    ldr     x1, [x0, #PLANET_NAME]
    ldr     w2, [x0, #PLANET_TRAVEL_COST]
    adrp    x0, ui_travel_format
    add     x0, x0, :lo12:ui_travel_format
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_insufficient_fuel
.type ui_print_insufficient_fuel, %function
ui_print_insufficient_fuel:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    adrp    x0, ui_insufficient_fuel
    add     x0, x0, :lo12:ui_insufficient_fuel
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_nonviable
.type ui_print_nonviable, %function
// x0 = planet record pointer.
ui_print_nonviable:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    ldr     x1, [x0, #PLANET_NAME]
    adrp    x0, ui_nonviable_format
    add     x0, x0, :lo12:ui_nonviable_format
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_win
.type ui_print_win, %function
// x0 = viable planet record pointer.
ui_print_win:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    ldr     x1, [x0, #PLANET_NAME]
    adrp    x0, ui_win_format
    add     x0, x0, :lo12:ui_win_format
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_loss
.type ui_print_loss, %function
ui_print_loss:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    adrp    x0, ui_loss
    add     x0, x0, :lo12:ui_loss
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

.global ui_print_quit
.type ui_print_quit, %function
ui_print_quit:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    adrp    x0, ui_quit
    add     x0, x0, :lo12:ui_quit
    bl      printf
    ldp     x29, x30, [sp], #16
    ret

