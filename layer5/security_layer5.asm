// security_layer5.asm
// Security Layer 5: Final Recovery Key
// Displays the information collected in earlier layers (PIN Fragment, Keyword,
// Security Code), builds the correct key by joining them in that order, and gives the
// player up to three attempts to enter it. A correct key completes the mission and
// shows the final score; running out of attempts fails the mission.

define(fp, x29)
define(lr, x30)

define(MAX_TRIES, 3) // Number of attempts the player gets
define(START_SCORE, 800) // Score carried in from Layers 1-4 (set here for standalone testing)

define(tries_r, w19) // Register containing the number of attempts remaining
define(score_r, w20) // Register containing the score counter

alloc = -(16 + 16) & -16 // Space to allocate for fp, lr, and x19-x20
dealloc = -alloc

.data
pin_frag:       .string "48" // PIN Fragment collected after Layer 1
keyword:        .string "ARM" // Keyword decoded in Layer 2
sec_code:       .string "21" // Security Code collected after Layer 4
fmt_info:       .string "FINAL SECURITY LAYER\nYou have collected the following information:\nPIN Fragment: %s\nKeyword: %s\nSecurity Code: %s\nCombine the information in this order:\nPIN Fragment + Keyword + Security Code\n"
fmt_prompt:     .string "Enter Final Recovery Key: "
fmt_in:         .string "%31s" // Limit input format to 31 characters
fmt_wrong:      .string "INCORRECT\nAttempts remaining: %d\n"
fmt_win:        .string "ACCESS GRANTED\nPROJECT PHOENIX LOCATED\nRecovering file...\n100%%\nMISSION SUCCESSFUL\nSecurity Layers Completed: 5/5\nFinal Score: %d\nAttempts Remaining: %d\n"
fmt_lose:       .string "SECURITY LOCKOUT\nAttempts Remaining: %d\nToo many incorrect answers have been entered.\nMISSION FAILED\n"

.bss
        .balign 4
input_key:      .skip 32 // Store the key typed by the player
expected_key:   .skip 32 // Store the correct key built from the collected information

.text
        .balign 4
        .global main

// append
// Purpose: Copy a string onto the end of another string in a buffer, so several strings can be joined one after another.
// Inputs: x0 = where to start writing, x1 = the string to copy.
// Outputs: x0 = address of the null terminator written, ready for the next append.
append:
        ldrb    w9, [x1], 1 // Next byte of the source
        strb    w9, [x0] // Store it in the destination
        cmp     w9, 0
        b.eq    append_done // Stop after copying the terminator
        add     x0, x0, 1
        b       append
append_done:
        ret

// str_equal
// Purpose: Compare two null-terminated strings byte by byte.
// Inputs: x0 = address of the first string, x1 = address of the second string.
// Outputs: w0 = 1 if the strings are identical, 0 otherwise.
str_equal:
        ldrb    w9, [x0], 1 // Next byte of each string
        ldrb    w10, [x1], 1
        cmp     w9, w10
        b.ne    differ // Different bytes mean different strings
        cbnz    w9, str_equal // Equal and not the terminator, keep comparing
        mov     w0, 1 // Both reached the terminator together
        ret
differ:
        mov     w0, 0
        ret

// main
// Purpose: Display the collected information, build the correct key, then read the
//          player's key with scanf until it matches or the attempts run out.
// Inputs: The player's key (a string of up to 31 characters) is read from the
//         standard input via scanf (with the format: "%31s").
// Outputs: The collected information, the prompt, and the mission result are printed
//          to standard output via printf. Returns 0 in w0 if the mission is
//          successful, or 1 if the attempts run out or the input ends.
// Registers overwritten:
//      x19-x20: attempts remaining and score counter (saved and restored)
//      x29, x30: frame pointer and link register (saved and restored)
//      x0-x3, x9: scratch registers
main:
        stp     fp, lr, [sp, alloc]! // Store the fp and lr, and also allocate space to store x19-x20
        mov     fp, sp
        stp     x19, x20, [sp, 16]

        mov     score_r, START_SCORE
        mov     tries_r, MAX_TRIES

        ldr     x0, =fmt_info // Display the collected information
        ldr     x1, =pin_frag
        ldr     x2, =keyword
        ldr     x3, =sec_code
        bl      printf

        // Create the expected key by appending the fragments into x0
        ldr     x0, =expected_key // Build the correct key: PIN Fragment + Keyword + Security Code
        ldr     x1, =pin_frag
        bl      append // x0 now points at the end of what was copied
        ldr     x1, =keyword
        bl      append
        ldr     x1, =sec_code
        bl      append
ask:
        ldr     x0, =fmt_prompt
        bl      printf
        ldr     x0, =fmt_in
        ldr     x1, =input_key // Retrieve the player's key from standard input
        bl      scanf
        cmp     w0, 1 // Stop if no key could be read
        b.ne    failed

        ldr     x0, =input_key
        ldr     x1, =expected_key
        bl      str_equal
        cmp     w0, 0
        b.ne    correct

        sub     tries_r, tries_r, 1 // A wrong key costs one attempt
        ldr     x0, =fmt_wrong
        mov     w1, tries_r
        bl      printf
        cmp     tries_r, 0
        b.ne    ask // Ask again while attempts remain
failed:
        mov     tries_r, 0 // No attempts are left to use
        ldr     x0, =fmt_lose
        mov     w1, tries_r
        bl      printf
        mov     w0, 1
        b       done
correct:
        mov     w9, 50
        madd    w9, tries_r, w9, w9 // Points = attempts remaining * 50 + 50 (200, 150, or 100)
        add     score_r, score_r, w9
        ldr     x0, =fmt_win
        mov     w1, score_r // Print the final score and the attempts remaining
        mov     w2, tries_r
        bl      printf
        
done:
        mov     w0, 0
        ldp     x19, x20, [sp, 16]
        ldp     fp, lr, [sp], dealloc
        ret
