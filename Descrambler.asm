# Descrambler program for RARS
# Takes scrambled text and scrambler key as input, and outputs original message

# Define constants
SYSCALL_PRINT_STRING = 4
SYSCALL_READ_STRING = 8

# Allocate memory for input and output strings
.data
input: .space 100	# maximum length of input string
output: .space 100	# maximum length of output string

# Define variables
len: .word 0		# length of input string
key: .asciiz ""		# scrambler key

# Define main program
.text
.globl main
main:
	# Prompt user for input string and key
	li $v0, SYSCALL_PRINT_STRING
	la $a0, prompt_input
	syscall
	
	# Read input string from user
	li $v0, SYSCALL_READ_STRING
	la $a0, input
	li $a1, 100
	syscall
	
	# Prompt user for scrambler key
	li $v0, SYSCALL_PRINT_STRING
	la $a0, prompt_key
	syscall
	
	# Read scrambler key from user
	li $v0, SYSCALL_READ_STRING
	la $a0, key
	li $a1, 100
	syscall
	
	# Compute length of input string
	li $t0, 0
loop:
	lb $t1, ($a0)
	beqz $t1, done
	addi $t0, $t0, 1
	addi $a0, $a0, 1
	j loop
done:
	sw $t0, len		# store length of input string in memory
	
	# Descramble input string using key
	la $t2, input		# pointer to input string
	la $t3, key		# pointer to key
	lw $t4, len		# load length of input string
	xor $t5, $zero, $zero	# initialize output string character to 0
	
descramble_loop:
	beq $t4, $zero, descramble_done	# done when all input characters processed
	lb $t6, ($t2)		# load current input character
	lb $t7, ($t3)		# load current key character
	xor $t6, $t6, $t7	# descramble character by XOR with key
	sb $t6, ($t5)		# store descrambled character in output string
	addi $t2, $t2, 1	# increment input string pointer
	addi $t3, $t3, 1	# increment key string pointer
	addi $t5, $t5, 1	# increment output string pointer
	addi $t4, $t4, -1	# decrement character count
	j descramble_loop

descramble_done:
	# Print output string
	li $v0, SYSCALL_PRINT_STRING
	la $a0, output
	syscall
	
	# Terminate program
	li $v0, 10
	syscall

# Define string prompts
prompt_input: .asciiz "Enter scrambled text: "
prompt_key: .asciiz "Enter scrambler key: "
