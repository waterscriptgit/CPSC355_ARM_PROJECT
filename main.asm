// Main controller for the Spaceship Exploration Program.
// This file controls the overall flow of the game.

.arch armv8-a
include(`game.inc')dnl


.section .text
.balign 4

.global main
.type main, %function


// Game state functions.
.extern game_init

// Input functions.
.extern input_read_integer

// Game action functions.
.extern game_action_list_planets
.extern game_action_study
.extern game_action_travel
.extern game_action_help

// UI functions.
.extern ui_print_banner
.extern ui_print_prologue
.extern ui_prompt_wormhole
.extern ui_print_wormhole_entered
.extern ui_print_abandon
.extern ui_print_status
.extern ui_print_menu
.extern ui_prompt_planet
.extern ui_print_invalid_input
.extern ui_print_quit
.extern ui_wait_for_enter

main:

    // Save frame pointer and return address.
    stp     x29, x30, [sp, #-32]!
    mov     x29, sp
    str     x19, [sp, #16]


    // --------------------------------------------------------
    // SET UP THE GAME
    // --------------------------------------------------------

    // Set starting fuel and clear previous game state.
    bl      game_init

    // Show title and introduction.
    bl      ui_print_banner
    bl      ui_print_prologue


    // --------------------------------------------------------
    // WORMHOLE DECISION
    //
    // The player must decide whether to accept the mission.
    //
    // 1 = enter wormhole
    // 2 = abandon mission
    // --------------------------------------------------------

.Lwormhole_choice:

    bl      ui_prompt_wormhole
    bl      input_read_integer


    // Did the player choose to enter the wormhole?
    cmp     w0, #1
    b.eq    .Lenter_wormhole


    // Did the player abandon the mission?
    cmp     w0, #2
    b.eq    .Labandon_mission


    // Anything else is invalid.
    bl      ui_print_invalid_input
    b       .Lwormhole_choice



.Lenter_wormhole:

    // The spacecraft is damaged during the wormhole trip.
    bl      ui_print_wormhole_entered

    // Start the main mission.
    b       .Lmain_loop



.Labandon_mission:

    // Player chose family instead of continuing the mission.
    bl      ui_print_abandon

    // End the game.
    b       .Lmain_exit



    // --------------------------------------------------------
    // MAIN GAME LOOP
    //
    // The player repeatedly chooses an action until:
    //
    // - a habitable planet is found
    // - no reachable planet remains
    // - the player quits
    // --------------------------------------------------------

.Lmain_loop:

    // Show remaining fuel.
    bl      ui_print_status

    // Show available actions.
    bl      ui_print_menu

    // Read menu choice.
    bl      input_read_integer


    // --------------------------------------------------------
    // ACTION 1: VIEW PLANETS
    // --------------------------------------------------------

    cmp     w0, #ACTION_LIST_PLANETS
    b.eq    .Llist_planets


    // --------------------------------------------------------
    // ACTION 2: STUDY PLANET
    // --------------------------------------------------------

    cmp     w0, #ACTION_STUDY_PLANET
    b.eq    .Lstudy_planet


    // --------------------------------------------------------
    // ACTION 3: TRAVEL
    // --------------------------------------------------------

    cmp     w0, #ACTION_TRAVEL
    b.eq    .Ltravel_planet


    // --------------------------------------------------------
    // ACTION 4: MISSION HELP
    // --------------------------------------------------------

    cmp     w0, #ACTION_HELP
    b.eq    .Lhelp


    // --------------------------------------------------------
    // ACTION 5: QUIT
    // --------------------------------------------------------

    cmp     w0, #ACTION_QUIT
    b.eq    .Lquit


    // If none matched, input was invalid.
    bl      ui_print_invalid_input

    // Return to menu.
    b       .Lmain_loop



// ------------------------------------------------------------
// VIEW PLANETS
// ------------------------------------------------------------

.Llist_planets:

    bl      game_action_list_planets

    // Let the player read the planet information.
    bl      ui_wait_for_enter

    b       .Lmain_loop

// ------------------------------------------------------------
// STUDY PLANET
// ------------------------------------------------------------

.Lstudy_planet:

.Lstudy_choice:

    // Ask which planet to study.
    bl      ui_prompt_planet

    // Read planet number.
    bl      input_read_integer

    // 0 means go back to the main menu.
    cmp     w0, #0
    b.eq    .Lmain_loop

    // Valid choices are only 1, 2, and 3.
    cmp     w0, #1
    b.lt    .Lstudy_invalid_choice

    cmp     w0, #PLANET_COUNT
    b.gt    .Lstudy_invalid_choice


    // Study the selected planet.
    bl      game_action_study

    // Save return value because the pause may change w0.
    mov     w19, w0

    // Let the player read the report.
    bl      ui_wait_for_enter

    // Restore result.
    mov     w0, w19

    // 2 means mission lost.
    cmp     w0, #2
    b.eq    .Lmain_exit

    b       .Lmain_loop


.Lstudy_invalid_choice:

    // Tell the player the planet number was invalid.
    bl      ui_print_invalid_planet

    // Stay inside the Study submenu.
    b       .Lstudy_choice

// ------------------------------------------------------------
// TRAVEL TO PLANET
// ------------------------------------------------------------

.Ltravel_planet:

.Ltravel_choice:

    // Ask which planet to travel to.
    bl      ui_prompt_planet

    // Read planet number.
    bl      input_read_integer

    // 0 means go back to the main menu.
    cmp     w0, #0
    b.eq    .Lmain_loop

    // Valid choices are only 1, 2, and 3.
    cmp     w0, #1
    b.lt    .Ltravel_invalid_choice

    cmp     w0, #PLANET_COUNT
    b.gt    .Ltravel_invalid_choice


    // Attempt the trip.
    bl      game_action_travel

    // Save the result because the pause may change w0.
    mov     w19, w0


    // If the game is still continuing,
    // let the player read the travel result.
    cmp     w19, #0
    b.ne    .Ltravel_check_result

    bl      ui_wait_for_enter


.Ltravel_check_result:

    // Restore result.
    mov     w0, w19

    // 1 = mission won.
    cmp     w0, #1
    b.eq    .Lmain_exit

    // 2 = mission lost.
    cmp     w0, #2
    b.eq    .Lmain_exit

    b       .Lmain_loop


.Ltravel_invalid_choice:

    // Tell the player the number was invalid.
    bl      ui_print_invalid_planet

    // Stay inside the Travel submenu.
    b       .Ltravel_choice

// ------------------------------------------------------------
// MISSION HELP
// ------------------------------------------------------------

.Lhelp:

    bl      game_action_help

    // Give the player time to read the mission instructions.
    bl      ui_wait_for_enter

    b       .Lmain_loop

// ------------------------------------------------------------
// PLAYER QUITS
// ------------------------------------------------------------

.Lquit:

    bl      ui_print_quit



// ------------------------------------------------------------
// END PROGRAM
// ------------------------------------------------------------

.Lmain_exit:

    // Return 0 from main.
    mov     w0, wzr

    // Restore frame pointer and return address.
    ldr     x19, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret
