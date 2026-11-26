// security_layer4.asm
// Security Layer 4: Pattern / Code Challenge
// Displays one number pattern with four numbered choices for the missing fifth term,
// and gives the player up to three attempts to choose the correct one. A correct
// choice adds points to the score (200, 150, or 100 for 3, 2, or 1 attempts
// remaining), prints the score, and reveals the Security Code used in Layer 5.

define(fp, x29)
define(lr, x30)

define(ANSWER, 2) // Number of the correct choice (the pattern 2, 4, 6, 8 continues with 10)
define(MAX_TRIES, 3) // Number of attempts the player gets
define(START_SCORE, 600) // Score carried in from Layers 1-3 (set here for standalone testing)
define(SEC_CODE, 21) // Security Code revealed after this layer

define(tries_r, w19) // Register containing the number of attempts remaining
define(score_r, w20) // Register containing the score counter

alloc = -(16 + 16) & -16 // Space to allocate for fp, lr, and x19-x20
dealloc = -alloc

.data
fmt_q:          .string "SECURITY LAYER 4\nComplete the security sequence:\n2, 4, 8, 16, ?\n1. 9\n2. 32\n3. 42\n4. 60\n"
fmt_prompt:     .string "Enter choice: "
fmt_in:         .string "%d"
fmt_wrong:      .string "INCORRECT\nAttempts remaining: %d\n"
fmt_right:      .string "CORRECT\nSecurity Layer 4 completed.\n"
fmt_score:      .string "Score: %d\n"
fmt_code:       .string "Security Code: %d\n"
fmt_fail:       .string "Security Layer 4 failed.\n"

.bss
        .balign 4
input_choice:   .skip 4 // Store the input from scanf

.text
        .balign 4
        .global main

// main
// Purpose: Display the pattern question, then read the player's choice with scanf
//          until it is correct or the attempts run out. A correct choice adds
//          50 * attempts remaining + 50 points to the score, then prints the score
//          and the Security Code.
// Inputs: The player's choice (an integer) is read from the standard input via
//         scanf (with the format: "%d").
// Outputs: The question, the four numbered choices, and the result messages are
//          printed to standard output via printf. Returns 0 in w0 if the layer is
//          completed, or 1 if the attempts run out or the input ends.
main:
        stp     fp, lr, [sp, alloc]! // Store the fp and lr, and also allocate space to store x19-x20
        mov     fp, sp
        stp     x19, x20, [sp, 16]

        mov     score_r, START_SCORE
        mov     tries_r, MAX_TRIES

        ldr     x0, =fmt_q // Print the question and the four choices
        bl      printf
ask:
        ldr     x0, =fmt_prompt
        bl      printf
        ldr     x0, =fmt_in
        ldr     x1, =input_choice // Retrieve the player's choice from standard input
        bl      scanf
        cmp     w0, 1 // Stop if no number could be read
        b.ne    failed

        ldr     x9, =input_choice
        ldr     w9, [x9] // The player's choice
        cmp     w9, ANSWER
        b.eq    correct

        sub     tries_r, tries_r, 1 // A wrong choice costs one attempt
        ldr     x0, =fmt_wrong
        mov     w1, tries_r
        bl      printf
        cmp     tries_r, 0
        b.ne    ask // Ask again while attempts remain
failed:
        ldr     x0, =fmt_fail
        bl      printf
        mov     w0, 1
        b       done
correct:
        mov     w9, 50
        madd    w9, tries_r, w9, w9 // Points = attempts remaining * 50 + 50 (200, 150, or 100)
        add     score_r, score_r, w9
        ldr     x0, =fmt_right
        bl      printf
        ldr     x0, =fmt_score
        mov     w1, score_r // Print the score counter
        bl      printf
        ldr     x0, =fmt_code
        mov     w1, SEC_CODE // Reveal the Security Code for Layer 5
        bl      printf
done:
        mov     w0, 0
        ldp     x19, x20, [sp, 16]
        ldp     fp, lr, [sp], dealloc
        ret
