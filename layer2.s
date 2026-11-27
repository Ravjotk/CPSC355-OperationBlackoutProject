        .data

layer2_title:   .string "\n=== SECURITY LAYER 2: PASSWORD CRACKER ===\n"
layer2_hint:    .string "Hint: A type of fast computer memory.\n"
layer2_blanks:  .string "Password: _ _ _ _ _\n"
layer2_prompt:  .string "Enter a five-letter password (uppercase): "
layer2_input:   .string "%99s"
layer2_answer:  .string "CACHE"
layer2_letter:  .string "%c "
layer2_blank:   .string "_ "
layer2_newline: .string "\n"
layer2_attempt: .string "Remaining attempts: %d\n"
layer2_correct: .string "ACCESS GRANTED!\nKeyword recovered: CACHE\n"
layer2_wrong:   .string "ACCESS DENIED! Incorrect password.\n"
layer2_failed:  .string "No attempts remaining. Mission failed.\n"

        .bss
word_guess:     .skip 100

        .balign 4
letter_index:   .skip 4
correct_count:  .skip 4

        .text
        .balign 4
        .global layer2

// Security Layer 2: Password Cracker
// The player must guess a five-letter password.
// Correct letters are displayed in their positions.
// Wrong guesses decrease the remaining attempts.
// Returns 1 for success and 0 for failure.

layer2:
        stp     x29, x30, [sp, -16]!
        mov     x29, sp

        // Display the title, hint and blanks
        ldr     x0, =layer2_title
        bl      printf

        ldr     x0, =layer2_hint
        bl      printf

        ldr     x0, =layer2_blanks
        bl      printf
  



// this is tthemain loop that allows the player to guess the password
layer2_loop:


        ldr     x1, =attempts
        ldr     w1, [x1]
        cmp     w1, #0
        b.eq    layer2_fail

        // Display remaining attempts
        ldr     x0, =layer2_attempt
        bl      printf

        // here i will be asking the player for a password and reading the answer. 
        ldr     x0, =layer2_prompt
        bl      printf

        ldr     x0, =layer2_input
        ldr     x1, =word_guess
        bl      scanf

        cmp     w0, #1
        b.ne    layer2_fail


        // Count the number of letters
        ldr     x1, =word_guess
        mov     w2, #0

count_letters: // Count the letters until the end of the string is reached

        ldrb    w3, [x1]
        cmp     w3, #0
        b.eq    check_length

        add     w2, w2, #1
        add     x1, x1, #1
        b       count_letters

check_length:
        cmp     w2, #5
        b.ne    layer2_incorrect



        ldr     x1, =letter_index
        mov     w2, #0
        str     w2, [x1]

        // Set the correct letter count to zero
        ldr     x1, =correct_count
        mov     w2, #0
        str     w2, [x1]
 // Compare each letter of the guess with the correct password

layer2_compare:
        // Stop comparing once all five letters have been checked

        ldr     x1, =letter_index
        ldr     w2, [x1]
        cmp     w2, #5
        b.eq    layer2_check
        // Load the letter at the current position in the player's guess

        ldr     x3, =word_guess
        add     x3, x3, x2
        ldrb    w4, [x3]
        // Compare the letters and branch if they do not match

        ldr     x3, =layer2_answer
        add     x3, x3, x2
        ldrb    w5, [x3]

        // Compare the two letters
        cmp     w4, w5
        b.ne    layer2_wrong_letter
        // Increase the correct letter count when the letters match

        ldr     x1, =correct_count
        ldr     w2, [x1]
        add     w2, w2, #1
        str     w2, [x1]

        // Display the correct letter
        ldr     x0, =layer2_letter
        mov     w1, w4
        bl      printf

        b       layer2_next

layer2_wrong_letter:

        // Display a blank for an incorrect letter
        ldr     x0, =layer2_blank
        bl      printf

layer2_next:

        // Move to the next letter
        ldr     x1, =letter_index
        ldr     w2, [x1]
        add     w2, w2, #1
        str     w2, [x1]

        b       layer2_compare
// Check if the player correctly guessed all five letters

layer2_check:

        // Move to a new line
        ldr     x0, =layer2_newline
        bl      printf

        ldr     x1, =correct_count
        ldr     w2, [x1]
        cmp     w2, #5
        b.eq    layer2_success
// Handle an incorrect password and allow another guess
layer2_incorrect:
        // Decrease the player's shared attempts by one and display error and return to guessing loopp.

        ldr     x1, =attempts
        ldr     w2, [x1]
        sub     w2, w2, #1
        str     w2, [x1]

        ldr     x0, =layer2_wrong
        bl      printf

        b       layer2_loop
// Handle a correct password and complete Security Layer 2
layer2_success:

        ldr     x1, =score
        ldr     w2, [x1]
        add     w2, w2, #1
        str     w2, [x1]

        ldr     x0, =layer2_correct
        bl      printf

        mov     w0, #1
        b       layer2_end

layer2_fail:


// Handle mission failure when the player runs out of attempts
// or the input cannot be read

        // Display failure message
        ldr     x0, =layer2_failed
        bl      printf

        mov     w0, #0
// Restore the saved registers and return to the calling function

layer2_end:

        ldp     x29, x30, [sp], 16
        ret