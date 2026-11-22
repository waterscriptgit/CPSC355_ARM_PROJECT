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


/**
 * main
 *
 * Purpose:
 * Controls the overall game.
 *
 * The function:
 * 1. Initializes the game state.
 * 2. Displays the prologue.
 * 3. Handles the wormhole decision.
 * 4. Runs the main mission menu.
 * 5. Ends the program after a win, loss, abandonment,
 *    or player quit.
 *
 * Input:
 * None.
 *
 * Output:
 * w0 = 0 when the program ends.
 *
 * Side effects:
 * Calls the different game, input, and UI functions.
 */
main:

    // Save frame pointer and return address.
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp


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

    // Return to main menu.
    b       .Lmain_loop



// ------------------------------------------------------------
// STUDY PLANET
// ------------------------------------------------------------

.Lstudy_planet:

    // Ask which planet to study.
    bl      ui_prompt_planet

    // Read planet number.
    bl      input_read_integer

    // Study selected planet.
    //
    // Returns:
    // 0 = continue
    // 2 = mission lost
    bl      game_action_study


    // A return value of 2 means there are no
    // reachable planets remaining.
    cmp     w0, #2
    b.eq    .Lmain_exit


    // Otherwise keep playing.
    b       .Lmain_loop



// ------------------------------------------------------------
// TRAVEL TO PLANET
// ------------------------------------------------------------

.Ltravel_planet:

    // Ask which planet to travel to.
    bl      ui_prompt_planet

    // Read planet number.
    bl      input_read_integer

    // Attempt the trip.
    //
    // Returns:
    // 0 = continue
    // 1 = mission won
    // 2 = mission lost
    bl      game_action_travel


    // Player found the habitable planet.
    cmp     w0, #1
    b.eq    .Lmain_exit


    // Player can no longer continue the mission.
    cmp     w0, #2
    b.eq    .Lmain_exit


    // Otherwise return to the menu.
    b       .Lmain_loop



// ------------------------------------------------------------
// MISSION HELP
// ------------------------------------------------------------

.Lhelp:

    bl      game_action_help
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
    ldp     x29, x30, [sp], #16

    ret