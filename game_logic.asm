// Game workflows.
// This file connects the map, game state, input choices, and user interface together.

.arch armv8-a
include(`game.inc')dnl


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



.global game_action_study
.type game_action_study, %function

game_action_study:

    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]


    // Convert player choice 1-3 into array index 0-2.
    sub     w19, w0, #1

    // Find the planet record.
    mov     w0, w19
    bl      map_get_planet

    // x0 = 0 means invalid planet.
    cbz     x0, .Lstudy_invalid

    // Save the planet pointer.
    mov     x20, x0


    // Check whether this planet was already studied.
    mov     w0, w19
    bl      game_is_studied

    // If already studied, show the report again for free.
    cbnz    w0, .Lstudy_show_report


    // Try to spend the 2 fuel required to study.
    mov     w0, #STUDY_COST
    bl      game_try_spend_fuel

    // Not enough fuel to study.
    cbz     w0, .Lstudy_no_fuel


    // Remember that this planet has now been studied.
    mov     w0, w19
    bl      game_mark_studied


.Lstudy_show_report:

    // Display the detailed scientific report.
    mov     x0, x20
    bl      ui_print_study_result


    // Check whether the player can still afford
    // to reach at least one remaining planet.
    bl      game_has_travel_option

    cbz     w0, .Lstudy_loss


    // Continue the game.
    mov     w0, wzr
    b       .Lstudy_done


.Lstudy_loss:

    // Record the mission failure.
    mov     w0, #GAME_LOST
    bl      game_set_outcome

    bl      ui_print_loss

    mov     w0, #GAME_LOST
    b       .Lstudy_done


.Lstudy_no_fuel:

    bl      ui_print_insufficient_study_fuel

    mov     w0, wzr
    b       .Lstudy_done


.Lstudy_invalid:

    bl      ui_print_invalid_planet

    mov     w0, wzr


.Lstudy_done:

    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret



.global game_action_travel
.type game_action_travel, %function

game_action_travel:

    stp     x29, x30, [sp, #-48]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]


    // Convert 1-3 player choice into 0-2 index.
    sub     w19, w0, #1


    // Get the selected planet.
    mov     w0, w19
    bl      map_get_planet

    cbz     x0, .Ltravel_invalid

    // Save the planet pointer.
    mov     x20, x0


    // Check if the player has already landed here.
    mov     w0, w19
    bl      game_is_visited

    cbnz    w0, .Ltravel_already_visited


    // Load this planet's travel cost.
    ldr     w0, [x20, #PLANET_TRAVEL_COST]

    // First check affordability without spending anything.
    bl      game_can_afford_travel

    cbz     w0, .Ltravel_no_fuel


    // We know the player can afford it,
    // so now actually subtract the travel cost.
    ldr     w0, [x20, #PLANET_TRAVEL_COST]
    bl      game_try_spend_fuel


    // Save the player's new location.
    mov     w0, w19
    bl      game_set_location


    // Mark this planet as visited.
    mov     w0, w19
    bl      game_mark_visited


    // Tell the player they are travelling/landing.
    mov     x0, x20
    bl      ui_print_travel_start


    /*
        Check if the planet is actually habitable.

        A viable planet must have every required trait.
    */

    ldr     w0, [x20, #PLANET_TRAITS]

    and     w0, w0, #TRAIT_VIABLE
    cmp     w0, #TRAIT_VIABLE

    b.eq    .Ltravel_win


    // The planet was not suitable.
    mov     x0, x20
    bl      ui_print_nonviable


    // See if any unvisited planet can still be reached.
    bl      game_has_travel_option

    // If none can be reached, the mission is over.
    cbz     w0, .Ltravel_loss


    // Otherwise continue exploring.
    mov     w0, wzr
    b       .Ltravel_done



.Ltravel_win:

    // Record the mission success.
    mov     w0, #GAME_WON
    bl      game_set_outcome

    mov     x0, x20
    bl      ui_print_win

    mov     w0, #GAME_WON
    b       .Ltravel_done



.Ltravel_loss:

    // Record the mission failure.
    mov     w0, #GAME_LOST
    bl      game_set_outcome

    bl      ui_print_loss

    mov     w0, #GAME_LOST
    b       .Ltravel_done


.Ltravel_no_fuel:

    bl      ui_print_insufficient_fuel

    mov     w0, wzr
    b       .Ltravel_done



.Ltravel_already_visited:

    mov     x0, x20
    bl      ui_print_already_visited

    mov     w0, wzr
    b       .Ltravel_done



.Ltravel_invalid:

    bl      ui_print_invalid_planet

    mov     w0, wzr



.Ltravel_done:

    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #48
    ret



.global game_has_travel_option
.type game_has_travel_option, %function

game_has_travel_option:

    stp     x29, x30, [sp, #-32]!
    mov     x29, sp
    stp     x19, x20, [sp, #16]


    // Start checking at planet index 0.
    mov     w19, wzr


.Lcheck_planet:

    // Has this planet already been visited?
    mov     w0, w19
    bl      game_is_visited

    // If yes, skip it.
    cbnz    w0, .Lcheck_next


    // Get this planet's record.
    mov     w0, w19
    bl      map_get_planet

    // Save the pointer.
    mov     x20, x0


    // Load its travel cost.
    ldr     w0, [x20, #PLANET_TRAVEL_COST]

    // Can the player afford it?
    bl      game_can_afford_travel

    // If yes, at least one travel option still exists.
    cbnz    w0, .Ltravel_option_found


.Lcheck_next:

    // Move to the next planet.
    add     w19, w19, #1

    cmp     w19, #PLANET_COUNT
    b.lt    .Lcheck_planet


    // checked all planets and none were affordable.
    mov     w0, wzr
    b       .Ltravel_option_done



.Ltravel_option_found:

    mov     w0, #1



.Ltravel_option_done:

    ldp     x19, x20, [sp, #16]
    ldp     x29, x30, [sp], #32
    ret
