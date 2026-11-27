        .data

layer1_title:   .string "\n=== SECURITY LAYER 1: PIN AUTHENTICATION ===\n"
layer1_puzzle:  .string "Solve the equation to unlock the firewall:\n(25 x 4) + 23 = ?\n"
layer1_prompt:  .string "Enter PIN: "
layer1_input:   .string "%d"
layer1_clear:   .string "%*[^\n]"
layer1_correct: .string "ACCESS GRANTED!\nPIN Fragment recovered: 123\n"
layer1_wrong:   .string "ACCESS DENIED! Incorrect PIN.\n"
layer1_attempt: .string "Remaining attempts: %d\n"
layer1_failed:  .string "No attempts remaining. Mission failed.\n"

        .bss
        .balign 4
pin_guess:      .skip 4

        .text
        .balign 4
        .global layer1

// Security Layer 1: PIN Authentication
// Asks the player to solve a mathematical puzzle.
// A wrong answer decreases the remaining attempts.
// A correct answer increases the score.
// Returns 1 for success and 0 for failure.

layer1:         // here i will Save the frame pointer and return address before displaying the title and puzzle
        stp     x29, x30, [sp, -16]!
        mov     x29, sp

        // Display the title
        ldr     x0, =layer1_title
        bl      printf

        // Display the puzzle
        ldr     x0, =layer1_puzzle
        bl      printf

layer1_loop:// make sure to check if thee plyer has any trrys left and display the remaining attempts

        ldr     x1, =attempts
        ldr     w1, [x1]
        cmp     w1, #0
        b.eq    layer1_fail

        ldr     x0, =layer1_attempt
        bl      printf

        ldr     x0, =layer1_prompt
        bl      printf

        ldr     x0, =layer1_input
        ldr     x1, =pin_guess
        bl      scanf


        // make sure to see if the input was read properlu before comparing the answer with 123

        cmp     w0, #-1
        b.eq    layer1_fail
        cmp     w0, #1
        b.ne    layer1_invalid

        ldr     x1, =pin_guess
        ldr     w2, [x1]
        cmp     w2, #123
        b.eq    layer1_success

layer1_incorrect:         // Decrease the shared attempts by one, display an error message and let the player try again


        ldr     x1, =attempts
        ldr     w2, [x1]
        sub     w2, w2, #1
        str     w2, [x1]

        ldr     x0, =layer1_wrong
        bl      printf

        b       layer1_loop

layer1_invalid:
        // Clear invalid characters from the input and treat the guess as an incorrect answer

        ldr     x0, =layer1_clear
        bl      scanf
        b       layer1_incorrect

layer1_success:
        // Increase the score by one, display the recovered PIN part and return 1 for success
        ldr     x1, =score
        ldr     w2, [x1]
        add     w2, w2, #1
        str     w2, [x1]

        ldr     x0, =layer1_correct
        bl      printf

        mov     w0, #1
        b       layer1_end

layer1_fail:        // Display the mission failure message and return 0 to indicate that the layer was not completed


        ldr     x0, =layer1_failed
        bl      printf

        mov     w0, #0

layer1_end:

        ldp     x29, x30, [sp], 16
        ret