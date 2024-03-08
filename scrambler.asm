.data
input_message: .asciiz "hello world"
scrambler_key: .word 42
output_message: .space 12

.text
main:
    # Load input message and scrambler key
    la a0, input_message
    lw a1, scrambler_key
    
    # Scramble the message
    jal scramble_message
    
    # Display the scrambled message
    la a0, output_message
    li x11, 4
    ecall
    
    # Exit program
    li x11, 10
    ecall

# Scramble the message
# Inputs: a0 = input message, a1 = scrambler key
# Outputs: x11 = scrambled message
scramble_message:
    # Initialize pseudorandom number generator
    mv t0, a1
    li t1, 1103515245
    li t2, 12345
    
    # Convert input message to list of characters
    mv t3, a0
    li t4, 0
    convert_loop:
        lb t5, (t3)
        beqz t5, scramble_done
        addi t3, t3, 1 #
        addi t4, t4, 1 #
        sb t5, (sp)
        j convert_loop
    
    # Shuffle list of characters using pseudorandom number generator
    li t6, 0
    shuffle_loop:
        beq t6, t4, shuffle_done
        jal random_int
        mv x12, x11
        jal random_int
        mv x14, x11
        add x12, x12, sp
        add x14, x14, sp
        lb  x7, 0(x12)
        lb x8, 0(x14)
        sb x8, 0(x12)
        sb x7, 0(x14)
        addi t6, t6, 1 #
        j shuffle_loop
    
    # Convert shuffled list of characters back to string
    mv t3, sp
    mv t6, t4
    convert_back_loop:
        beqz t6, convert_back_done
        lb t5, (t3)
        addi t3, t3, 1 #
        addi t6, t6, -1 #
        sb t5, (x11)
        j convert_back_loop
    
    scramble_done:
        jr ra
    
# Generate a pseudorandom integer
# Inputs: t0 = current state
# Outputs: x11 = pseudorandom integer, t0 = new state
#random_int:
#    mulhu  t0, t1 #mulh
#    mflo x11
#    add x11, x11, t2 #
#    add t0, x11, t0 #
#    jr ra
random_int:
    mul t0, t1, t2 # multiply t1 and t2 and store the 64-bit result in t0
    add x11, x0, t0 # add the 64-bit result to x0 to obtain the lower 32 bits in x11
    jr ra
    
shuffle_done:
    jr ra
convert_back_done:
    jr ra
