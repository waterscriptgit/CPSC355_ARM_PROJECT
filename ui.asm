// Terminal output for the Spaceship Exploration Program.
// All player-facing text is kept in this file.

.arch armv8-a
include(`game.inc')dnl


.section .rodata

// ------------------------------------------------------------
// STORY / PROLOGUE TEXT
// ------------------------------------------------------------

ui_banner:
    .asciz "\n=== INTERSTELLAR EXPLORATION MISSION ===\n"

ui_prologue:
    .asciz "\nEarth is dying.\nCrops are failing, oxygen levels are declining, and humanity is running out of time.\n\nYears earlier, NASA sent scientists through a newly discovered wormhole to search for a new home.\nThree scientists returned promising signals from three different planets.\n\nYou are a former NASA pilot chosen to lead humanity's final mission.\n"

ui_wormhole_prompt:
    .asciz "\nA wormhole lies ahead.\n\n1. Enter the wormhole\n2. Abandon the mission and return to your family\n> "

ui_wormhole_entered:
    .asciz "\nEntering wormhole...\n\nWARNING: Gravitational instability detected.\nWARNING: Spacecraft hull damaged.\nWARNING: Fuel reserves compromised.\n\nRemaining fuel: 20 units.\nMission calculations show that you will not be able to visit all three planets.\nChoose carefully.\n"

ui_abandon:
    .asciz "\nYou turn the spacecraft back toward Earth.\n\nWithout a habitable world, humanity's final chance disappears.\n\nMISSION FAILED - HUMANITY'S FINAL EXPEDITION ENDS BEFORE IT BEGINS.\n"


// ------------------------------------------------------------
// MAIN GAME UI
// ------------------------------------------------------------

ui_status_format:
    .asciz "\nFuel remaining: %d\n"

ui_menu:
    .asciz "\n1. View candidate planets\n2. Study a planet\n3. Travel to a planet\n4. Mission help\n5. Quit mission\n> "

ui_planet_heading:
    .asciz "\n=== CANDIDATE PLANETS ===\n"

ui_planet_row:
    .asciz "\nPlanet %d: %s\nTravel cost: %d fuel\nInitial report: %s\n"

ui_planet_prompt:
    .asciz "Planet number (1-3): "

ui_invalid_input:
    .asciz "Invalid choice. Enter one of the listed numbers.\n"

ui_invalid_planet:
    .asciz "Invalid planet number. Choose a value from 1 to 3.\n"


// ------------------------------------------------------------
// HELP / SCIENCE INFORMATION
// ------------------------------------------------------------

ui_help:
    .asciz "\n=== MISSION HELP ===\nA planet suitable for long-term human survival should have liquid water, a stable atmosphere, reasonable temperatures, manageable radiation, and conditions that allow food and energy production.\n\nStudying a planet remotely costs 2 fuel but reveals a more detailed scientific report.\nTravelling costs more fuel and cannot be undone.\n\nRemember: the original scientist reports may not always be reliable.\n"


// ------------------------------------------------------------
// STUDY TEXT
// ------------------------------------------------------------

ui_study_format:
    .asciz "\n=== DETAILED ANALYSIS: %s ===\n%s\n"

ui_study_cost:
    .asciz "\nRemote study initiated. 2 fuel consumed.\n"

ui_insufficient_study_fuel:
    .asciz "Not enough fuel remaining to perform a detailed study.\n"


// ------------------------------------------------------------
// TRAVEL TEXT
// ------------------------------------------------------------

ui_travel_format:
    .asciz "\nTravelling to %s...\nTravel cost: %d fuel.\n\nLanding sequence initiated...\n"

ui_insufficient_fuel:
    .asciz "Not enough fuel for that trip.\n"

ui_already_visited:
    .asciz "You have already visited %s. Travelling there again would waste fuel.\n"

ui_nonviable_format:
    .asciz "\nSurface analysis complete.\n%s is NOT suitable for permanent human settlement.\nYou must continue searching.\n"


// ------------------------------------------------------------
// ENDING TEXT
// ------------------------------------------------------------

ui_win_format:
    .asciz "\nAtmospheric composition: SAFE\nLiquid water: CONFIRMED\nTemperature: STABLE\nRadiation: SAFE\nOrganic compounds: DETECTED\n\n%s IS HABITABLE.\n\nFor the first time in decades, humanity receives hopeful news.\nCoordinates are transmitted back through the wormhole, and preparations begin for the largest journey in human history.\n\nEarth may be dying, but humanity will continue somewhere new among the stars.\n\nMISSION SUCCESS - HUMANITY SURVIVES.\n"

ui_loss:
    .asciz "\nCRITICAL WARNING: No reachable habitable planet remains.\n\nThe spacecraft drifts silently through the system.\nA habitable world may still exist nearby, but you no longer have the fuel required to reach it.\n\nNo rescue signal reaches Earth.\n\nMISSION FAILED - HUMANITY'S FINAL EXPEDITION IS LOST.\n"

ui_quit:
    .asciz "\nMission ended by player.\nHumanity's fate remains unknown.\n"


.section .text
.balign 4


.global ui_print_banner
.type ui_print_banner, %function

/**
 * ui_print_banner
 *
 * Purpose:
 * Displays the game's title.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints text to the terminal.
 */
ui_print_banner:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    adrp    x0, ui_banner
    add     x0, x0, :lo12:ui_banner
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_prologue
.type ui_print_prologue, %function

/**
 * ui_print_prologue
 *
 * Purpose:
 * Displays the opening story explaining Earth's condition
 * and the player's mission.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints story text to the terminal.
 */
ui_print_prologue:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    adrp    x0, ui_prologue
    add     x0, x0, :lo12:ui_prologue
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_prompt_wormhole
.type ui_prompt_wormhole, %function

/**
 * ui_prompt_wormhole
 *
 * Purpose:
 * Displays the player's first major decision.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints the wormhole menu.
 */
ui_prompt_wormhole:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    adrp    x0, ui_wormhole_prompt
    add     x0, x0, :lo12:ui_wormhole_prompt
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_wormhole_entered
.type ui_print_wormhole_entered, %function

/**
 * ui_print_wormhole_entered
 *
 * Purpose:
 * Displays the spacecraft damage and fuel-loss message
 * after the player enters the wormhole.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints story text.
 */
ui_print_wormhole_entered:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    adrp    x0, ui_wormhole_entered
    add     x0, x0, :lo12:ui_wormhole_entered
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_abandon
.type ui_print_abandon, %function

/**
 * ui_print_abandon
 *
 * Purpose:
 * Displays the ending when the player refuses
 * to enter the wormhole.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints the failed-mission ending.
 */
ui_print_abandon:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    adrp    x0, ui_abandon
    add     x0, x0, :lo12:ui_abandon
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_status
.type ui_print_status, %function

/**
 * ui_print_status
 *
 * Purpose:
 * Displays the player's current fuel.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Calls game_get_fuel and prints the value.
 */
ui_print_status:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // Get the current fuel.
    bl      game_get_fuel

    // printf second argument = fuel amount.
    mov     w1, w0

    adrp    x0, ui_status_format
    add     x0, x0, :lo12:ui_status_format
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_menu
.type ui_print_menu, %function

/**
 * ui_print_menu
 *
 * Purpose:
 * Displays the main mission menu.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints the available actions.
 */
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

/**
 * ui_print_planets
 *
 * Purpose:
 * Displays all three planets, their travel costs,
 * and their original scientist reports.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Calls map_get_planet and prints planet information.
 */
ui_print_planets:

    stp     x29, x30, [sp, #-48]!
    mov     x29, sp

    stp     x19, x20, [sp, #16]

    // Print heading.
    adrp    x0, ui_planet_heading
    add     x0, x0, :lo12:ui_planet_heading
    bl      printf

    // Start at planet index 0.
    mov     w19, wzr


.Lplanet_row:

    // Get planet record.
    mov     w0, w19
    bl      map_get_planet

    mov     x20, x0

    // printf arguments:
    //
    // w1 = displayed planet number
    // x2 = planet name
    // w3 = travel cost
    // x4 = original report
    add     w1, w19, #1
    ldr     x2, [x20, #PLANET_NAME]
    ldr     w3, [x20, #PLANET_TRAVEL_COST]
    ldr     x4, [x20, #PLANET_HINT]

    adrp    x0, ui_planet_row
    add     x0, x0, :lo12:ui_planet_row
    bl      printf

    // Move to next planet.
    add     w19, w19, #1

    cmp     w19, #PLANET_COUNT
    b.lt    .Lplanet_row


    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret



.global ui_prompt_planet
.type ui_prompt_planet, %function

/**
 * ui_prompt_planet
 *
 * Purpose:
 * Asks the player to choose one of the three planets.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints the prompt.
 */
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

/**
 * ui_print_invalid_input
 *
 * Purpose:
 * Tells the player that the menu choice was invalid.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints an error message.
 */
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

/**
 * ui_print_invalid_planet
 *
 * Purpose:
 * Tells the player that the planet number was invalid.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints an error message.
 */
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

/**
 * ui_print_help
 *
 * Purpose:
 * Explains the basic science and game rules.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints help text.
 */
ui_print_help:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    adrp    x0, ui_help
    add     x0, x0, :lo12:ui_help
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_study_result
.type ui_print_study_result, %function

/**
 * ui_print_study_result
 *
 * Purpose:
 * Displays the detailed scientific analysis
 * for a studied planet.
 *
 * Input:
 * x0 = pointer to the selected planet record.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints the planet's detailed report.
 */
ui_print_study_result:

    stp     x29, x30, [sp, #-32]!
    mov     x29, sp

    // Save planet pointer.
    str     x0, [sp, #16]

    // Print study cost message.
    adrp    x0, ui_study_cost
    add     x0, x0, :lo12:ui_study_cost
    bl      printf

    // Restore planet pointer.
    ldr     x0, [sp, #16]

    // printf arguments:
    // x1 = planet name
    // x2 = detailed study report
    ldr     x1, [x0, #PLANET_NAME]
    ldr     x2, [x0, #PLANET_STUDY]

    adrp    x0, ui_study_format
    add     x0, x0, :lo12:ui_study_format
    bl      printf

    ldp     x29, x30, [sp], #32
    ret



.global ui_print_insufficient_study_fuel
.type ui_print_insufficient_study_fuel, %function

/**
 * ui_print_insufficient_study_fuel
 *
 * Purpose:
 * Tells the player they cannot afford a remote study.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints an error message.
 */
ui_print_insufficient_study_fuel:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    adrp    x0, ui_insufficient_study_fuel
    add     x0, x0, :lo12:ui_insufficient_study_fuel
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_travel_start
.type ui_print_travel_start, %function

/**
 * ui_print_travel_start
 *
 * Purpose:
 * Displays the travel and landing message.
 *
 * Input:
 * x0 = pointer to the selected planet record.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints travel information.
 */
ui_print_travel_start:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // x1 = planet name.
    ldr     x1, [x0, #PLANET_NAME]

    // w2 = travel fuel cost.
    ldr     w2, [x0, #PLANET_TRAVEL_COST]

    adrp    x0, ui_travel_format
    add     x0, x0, :lo12:ui_travel_format
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_insufficient_fuel
.type ui_print_insufficient_fuel, %function

/**
 * ui_print_insufficient_fuel
 *
 * Purpose:
 * Tells the player they cannot afford the selected trip.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints an error message.
 */
ui_print_insufficient_fuel:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    adrp    x0, ui_insufficient_fuel
    add     x0, x0, :lo12:ui_insufficient_fuel
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_already_visited
.type ui_print_already_visited, %function

/**
 * ui_print_already_visited
 *
 * Purpose:
 * Tells the player they have already travelled
 * to the selected planet.
 *
 * Input:
 * x0 = pointer to the selected planet record.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints a warning message.
 */
ui_print_already_visited:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // x1 = planet name.
    ldr     x1, [x0, #PLANET_NAME]

    adrp    x0, ui_already_visited
    add     x0, x0, :lo12:ui_already_visited
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_nonviable
.type ui_print_nonviable, %function

/**
 * ui_print_nonviable
 *
 * Purpose:
 * Displays the result when the player lands
 * on a planet that cannot support humanity.
 *
 * Input:
 * x0 = pointer to the selected planet record.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints the failed landing result.
 */
ui_print_nonviable:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // x1 = planet name.
    ldr     x1, [x0, #PLANET_NAME]

    adrp    x0, ui_nonviable_format
    add     x0, x0, :lo12:ui_nonviable_format
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_win
.type ui_print_win, %function

/**
 * ui_print_win
 *
 * Purpose:
 * Displays the successful ending when the player
 * reaches the habitable planet.
 *
 * Input:
 * x0 = pointer to the habitable planet record.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints the mission-success story.
 */
ui_print_win:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    // x1 = habitable planet name.
    ldr     x1, [x0, #PLANET_NAME]

    adrp    x0, ui_win_format
    add     x0, x0, :lo12:ui_win_format
    bl      printf

    ldp     x29, x30, [sp], #16
    ret



.global ui_print_loss
.type ui_print_loss, %function

/**
 * ui_print_loss
 *
 * Purpose:
 * Displays the ending when the player can no longer
 * reach a habitable planet.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints the mission-failure story.
 */
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

/**
 * ui_print_quit
 *
 * Purpose:
 * Displays the message when the player manually
 * quits the mission.
 *
 * Input:
 * None.
 *
 * Output:
 * None.
 *
 * Side effects:
 * Prints the quit message.
 */
ui_print_quit:

    stp     x29, x30, [sp, #-16]!
    mov     x29, sp

    adrp    x0, ui_quit
    add     x0, x0, :lo12:ui_quit
    bl      printf

    ldp     x29, x30, [sp], #16
    ret