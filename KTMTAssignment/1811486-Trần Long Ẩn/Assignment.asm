.data
typeNumber: .asciiz "\nSelect the type of number entered : (1) - The decimal number  (2) - The hexadecimal number   :   "
enterA: .asciiz "\nEnter A : "
enterB: .asciiz "\nEnter B : "
option: .asciiz "\nChoose the operation using : (1) - Multiplication        (2) - Division   :  "
out_mul: .asciiz "\nResult : A * B = " 
out_div1: .asciiz "\nResult : A / B = " 
out_div2: .asciiz "\nResult : A % B = " 
error_size_input: .asciiz "\nThe number entered must be less than or equal to 8 bits!"
error_div_zero: .asciiz "\nError !!! Divisor must be non-zero!"
error_input: .asciiz "\nThe number entered must be hexadecimal!"
error_option: .asciiz "\nOnly two options are 1 or 2!"
spaceA: .space 11
spaceB: .space 11
.text

main:
#==================== Select type number ====================
	li		$v0, 4			
	la		$a0, typeNumber		
	syscall				
	li		$v0, 5			
	syscall				
	beq		$v0, 1, decimal			# Select decimal if the input equals 1
	beq		$v0, 2, hexadecimal		# select decimal if the input equals 2
	li		$v0, 4				# If it is different from 1 or 2, we report an error and try to enter again
	la		$a0, error_option		
	syscall		
	j 		main
#==================== Hexadecimal ====================
hexadecimal:
	addi		$s7, $0, 33			# Marked as hexadecimal to change the screen output type
	li		$v0, 4				
	la		$a0, enterA			
	syscall				
	la		$a0, spaceA		
	addi		$a1, $0, 10	
	li		$v0, 8				# Enter the string A
	syscall				
	jal		convert				# Converts the string A to a number
	addi		$s6, $v0, 0			
	li		$v0, 4			
	la		$a0, enterB		
	syscall				
	la		$a0, spaceB		
	addi		$a1, $0, 10
	li		$v0, 8				# Enter the string B
	syscall			
	jal		convert				# Converts the string B to a number
	addi		$s1, $v0, 0			# Save B to $ s1
	addi		$s0, $s6, 0			# Save A to $ s0
	j		checkNegative			# Check for signs of A and B
#==================== Decimal ====================
decimal:
	li		$v0, 4				
	la		$a0, enterA			
	syscall				
	li 		$v0, 5				# Enter A number
	syscall				
	addi		$s0, $v0, 0			# Save A to $ s0
	li		$v0, 4			
	la		$a0, enterB			
	syscall			
	li 		$v0, 5				# Enter B number
	syscall			
	addi		$s1, $v0, 0			# Save B to $ s1
#====================  Check input ====================
checkNegative:
	bgez 		$s0, next1			# If A is greater than 0, then ignore
	sub		$s0, $0, $s0			# Change the sign of A
	addi		$s4, $0, 1			# Increase the variable memory value to mark
next1:				
	bgez  		$s1, next2			# If B is greater than 0, then ignore
	sub		$s1, $0, $s1			# Change the sign of B
	addi		$s4, $s4, 1			# Increase the variable memory value to mark
next2:
#==================== Select option ====================
	li		$v0, 4		
	la		$a0, option	
	syscall			
	li 		$v0, 5		
	syscall		
	addi		$a0, $s0, 0			# Store A in a0 to pass to the function
	addi		$a1, $s1, 0			# store B in a1 to pass to the function
	beq		$v0, 2, divOption		# Select division if input equals 2
	beq		$v0, 1, mulOption		# Select multiplication if input equals 1
	li		$v0, 4				# If it is different from 1 or 2, we report an error and try to enter again
	la		$a0, error_option		
	syscall		
	j 		next2
#==================== Opition multiplication ====================
mulOption:
	jal		multiple			# Perform multiplication
	addi		$s1, $v0, 0			# Stores the result of multiplication in $s1
	li		$v0, 4		
	la		$a0, out_mul 	
	syscall			
	addi 		$a0, $s1, 0		
	bne 		$s4, 1, next3			# Check the marked variable
	sub		$a0, $0, $a0			# Change the result mark if the variable marked 1
next3:		
	li		$v0, 1			
	add		$v0, $v0, $s7			# Convert to hexadecimal if available
	syscall				
	j		exit			
#==================== Opition division ====================
divOption:
	bnez		$a1, checkZeroOk	 	# Checks if B is 0 then error
	la		$a0, error_div_zero	
	li		$v0, 4		
	syscall			
	j 		exit	
checkZeroOk:			
	jal		divide				# Perform division
	addi		$s1, $v0, 0			# Save the integer part to $ s1
	addi		$s2, $v1, 0			# Save the remainder to $ s2
	bne		$s4, 1, positive		# Check the marked variable
	sub		$s1, $0, $s1			# Change the result mark if the variable marked 1
	sub		$s2, $0, $s2			# Change the result mark if the variable marked 1
positive:
	la		$a0, out_div1	
	li		$v0, 4		
	syscall		
	add		$a0, $s1, $0	
	li		$v0, 1			
	add		$v0, $v0, $s7			# Convert to hexadecimal if available
	syscall 		
	la		$a0, out_div2 
	li		$v0, 4		
	syscall			
	add		$a0, $s2, $0	
	li		$v0, 1		
	add		$v0, $v0, $s7			# Convert to hexadecimal if available
	syscall 
#==================== Exit Program ====================
exit:
	li		$v0, 10				# Exit Program
	syscall		
#==================== Multiplication of two integers (A * B) ====================
multiple:	
	addi		$v0, $0, 0			# set ouput = 0
loopMul:				
	sll		$t0, $a1, 31 			# Checks the last bit of B
	beqz 		$t0, nextMul			# If = 0 then ignore
	add		$v0, $v0, $a0			# Add A to the resulting variable
nextMul:	
	sll		$a0, $a0, 1			# Shifts A to the left 1 bit
	srl		$a1, $a1, 1			# Shifts B to the right 1 bit
	beqz		$a0, exitMul			# If A = 0 then stop loop
	beqz		$a1, exitMul			# If B = 0 then stop loop
	j		loopMul				
exitMul:
	jr		$ra		
#==================== Division of two integers (A / B) ====================
divide:
	addi	$t4, $a1, 0				# Stores the value of B
	addi 	$v0, $0, 0				# set quotient = 0
loop_div1:
	sub	$t2, $a0, $a1				# Check A - B
	bltz	$t2, loop_div2				# If A - B <0 then we stop repeating
	sll	$a1, $a1, 1				# Otherwise, move B to the left 1 bit
	j	loop_div1		  												
loop_div2:
	sub	$t1, $a0, $a1				# Check A - B
	bltz	$t1, next_divv				# If A - B < 0, then ignore
	addi 	$v0, $v0, 1				# If A - B> = 0, then add the quotient by 1
	addi	$a0, $t1, 0				# Set A = A - B
next_divv:
	srl	$a1, $a1, 1 				# Shifts B to the right 1 bit
	slt	$at, $a1, $t4
	bne 	$at, $0, exit_div			# Stop repeating if B is less than the original B value
	sll 	$v0, $v0, 1				# Shifts quotient  to the left 1 bit
	j 	loop_div2
exit_div:
	addi	$v1, $a0, 0				
	jr	$ra
#==================== Convert to decimal ====================
convert:
	lb		$t0, 0($a0)			# Save the first bit of A in $ t0
	addi		$t1, $0, 0			# Set result = $t1 = 0 			
	addi		$t3, $0, 0			# Set variable count = 0
	addi		$t4, $0, 0			# Set $ ​​t4 = 0 to store negative numeric marker values
	bne		$t0, 45, loopConvert		# If the first character is different from '-' then ignore
	addi		$a0, $a0, 1			# Start reading from bit 2
	lb		$t0, 0($a0)		
	addi		$t3, $t3, -1			# Decreased variables 
	addi		$t4, $t4, 1			# Increase the tick variable
loopConvert:
	addi 		$at, $0, 'f'			# If the input character is above 'f' in the ASCII table, an error is reported
	slt		$at, $at, $t0
	bne		$at, $0, errorInput
	slti		$at, $t0, '0'			# If the input character is below '0', an error will occur
	bne		$at, $0, errorInput
	addi		$at, $t0, 0xffffffff 		# The characters entered are numbers from 0-9
	slti		$at, $at, '9'
	bne		$at, $0, number			
	slti		$at, $t0, 'a'			# The characters entered are numbers from a-f
	beq		$at, $0, word			# Report an error if in the remaining cases
	j		errorInput	
number:
	addi		$t0, $t0, -48			# Convert back to the correct number format
	j		checked	
word:	
	addi		$t0, $t0, -87			# Convert back to the correct number format
checked:	
	add		$t1, $t1, $t0			# The adder saves the result for the converted value
	addi		$a0, $a0, 1			# Read the next character
	lb		$t0, 0($a0)	
	addi		$t3, $t3,1			# Increase the counter
	beq		$t0, '\n', exit_convert		# If the next character is '\n', stop
	beq		$t0, '\0', exit_convert		# If the next character is '\0', stop
	beq		$t3, 8, errorSizeInput		# If the input string is a number more than 32 bits, an error will occur
	sll		$t1, $t1, 4			# translate the resulting variable 4 bit to the left
 	j		loopConvert			
exit_convert:
	addi		$v0, $t1, 0			
	bne		$t4, 1, nextConvert		# Check the marked variable
	sub		$v0, $0, $v0			# Change sign if variable marker = 1
nextConvert:
	jr		$ra		
errorInput:
	la		$a0, error_input	
	li		$v0, 4	
	syscall		
	li		$v0, 10	
	syscall	
errorSizeInput:
	la		$a0, error_size_input	
	li		$v0, 4	
	syscall		
	li		$v0, 10	
	syscall	
