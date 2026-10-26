.arch armv8-a
include(`game.inc')dnl

.section .text
.balign 4
.global main
.type main, %function
.extern game_init
.extern input_read_integer
.extern game_action_list_planets
.extern game_action_scan
.extern game_action_travel
.extern game_action_help
.extern ui_print_banner
.extern ui_print_status
.extern ui_print_menu
.extern ui_prompt_planet
.extern ui_print_invalid_input
.extern ui_print_quit

main:
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    bl      game_init
    bl      ui_print_banner
.Lmain_loop:
    bl      ui_print_status
    bl      ui_print_menu
    bl      input_read_integer

    cmp     w0, #ACTION_LIST_PLANETS
    b.eq    .Llist_planets
    cmp     w0, #ACTION_SCAN_PLANET
    b.eq    .Lscan_planet
    cmp     w0, #ACTION_TRAVEL
    b.eq    .Ltravel_planet
    cmp     w0, #ACTION_HELP
    b.eq    .Lhelp
    cmp     w0, #ACTION_QUIT
    b.eq    .Lquit
    bl      ui_print_invalid_input
    b       .Lmain_loop

.Llist_planets:
    bl      game_action_list_planets
    b       .Lmain_loop

.Lscan_planet:
    bl      ui_prompt_planet
    bl      input_read_integer
    bl      game_action_scan
    b       .Lmain_loop

.Ltravel_planet:
    bl      ui_prompt_planet
    bl      input_read_integer
    bl      game_action_travel
    cmp     w0, #1
    b.eq    .Lmain_exit
    cmp     w0, #2
    b.eq    .Lmain_exit
    b       .Lmain_loop

.Lhelp:
    bl      game_action_help
    b       .Lmain_loop

.Lquit:
    bl      ui_print_quit
.Lmain_exit:
    mov     w0, wzr
    ldp     x29, x30, [sp], #16
    ret
