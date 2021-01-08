# 	ASSIGNMENT
#	PROBLEM 1
.data
type:		.asciiz "Please input a Hexadecimal integer or Decimal integer\nType '1' for Hex number		Type '2' for Dec number\n"
hex1:		.asciiz "Input first hexadecimal number: "
hex2: 		.asciiz "Input second hexadecimal number: "
dec1: 		.asciiz "Input first decimal number: "
dec2:		.asciiz "Input second decimal number: "
ERROR: 		.asciiz "Your answer is incorrect! Please choose 1 for hex number or 2 for dec number\n"
str1: 		.space 8
str2: 		.space 8
R: 			.space 4
Q:			.space 4
str3: 		.asciiz"Quotient of Division: "
str4: 		.asciiz"\nRemainder of Division: "
str5: 		.asciiz"Invalid division because divisor is zero!"
res_mul: 	.asciiz "Result of Multiplication: "
newline: 	.asciiz "\n"
result: 	.space 8
.text
main:
	# Ask user to input a hex or dec number
	li 	$v0, 4
	la 	$a0, type
	syscall
	# Read the answer
	li 	$v0, 5
	syscall
	add $t0, $0, $v0 					# Store at reg t0
	add $t9, $zero, $t0					# This use for print type of number
										# correcsponding to input mode
	
	beq $t0, 1, inputHex				# If 1, it is a hex number
	beq $t0, 2, inputDec				# If 2, it is a dec number
	
	la 	$a0, ERROR						# else, invite user input again because of incorrect mode
	li 	$v0, 4
	syscall
	j 	main
	
main_program:
#TODO Note: 							# $s1 is stored first number
										# $s2 is stores second number
	add 	$s6, $s1, $zero				#Store content of each register 
	add 	$s7, $s2, $zero	
multiplication:							#to use for division function
#######Multiply#########
	addi 	$s0, $0, 0 					# initialize the result
	slti 	$t8, $s1, 0
	beq		$t8, 1, _next
	slti	$t8, $s2, 0
	beq		$t8, 1, _next
	j 		calculate
_next:
	slti 	$t8, $s2, 0
	beq 	$t8, 1, convertToPositive
	j 		calculate
convertToPositive:
	sub 	$s1, $zero, $s1
	sub 	$s2, $zero, $s2
	j 		calculate

calculate:
	# calculate
	addi	$t0, $0, 0 # $t0 = iterator = 32
	addi 	$t6, $0, 32
	While:
	slt 	$t7, $t0, $t6
	bne 	$t7, 1, END 
	andi 	$t1, $s2, 1 
	beq 	$t1, $0, END_IF
	add 	$s0, $s0, $s1
	END_IF:
	sll 	$s1, $s1, 1
	srl 	$s2, $s2, 1
	addi 	$t0, $t0, 1
	j 		While
	END:
	# $s0 now contain result of multiplication
	beq 	$t9, 1, outputHex		# If mode is 1, branch to output Hex type
	beq 	$t9, 2, outputDec		# If mode is 2, branch to output Dec type
	
	outputHex:
	li 	$t0, 8 						# counter 
	la 	$t3, result 				# where answer will be stored 

	_Loop: 	
		beq 	$t0, 0, popStack 	# branch to popStack if counter is equal to zero 
		and 	$t4, $s0, 0xf 		# and with 1111 
		srl 	$s0, $s0, 4			# Shift 4 low bits in s0 to right (remove it)
		slti	$t8, $t4, 9			# digits have range from 0 - 9
		beq		$t8, 1, Sum
		beq 	$t4, 9, Sum 		# if less than or equal to nine, branch to sum 
		addi 	$t4, $t4, 55 		# if greater than 9, (55 is digit 7 in ascii table)
		j 		End 
Sum:    
		addi 	$t4, $t4, 48 		# add 48 to result (48 is digit 0 in ascii table)
End:
		subu 	$sp, $sp, 4			# Create a location in stack
		sb		$t4, ($sp)  		# Store $t4 to stack
		addi 	$t0, $t0, -1 		# decrement loop counter 
		j 		_Loop 
	
	popStack:
		beq 	$t0, 8, _exit		# If popStack loop do 8 times, stop it (stack empty)
		lb 		$t7, ($sp)			# Pick front value of stack
		addu 	$sp, $sp, 4			# pop stack
		sb 		$t7, 0($t3)			# Store that value to result space
		addi 	$t3, $t3, 1			# increase address by 1
		addi 	$t0, $t0, 1			#increase count by 1
		j 		popStack
	_exit:
	# Print result
	la $a0, res_mul
	li $v0, 4
	syscall
	
	la $a0, result 
	li $v0, 4 
	syscall 
	
	la $a0, newline
	li $v0, 4
	syscall
	# Go to division implemention
	j division
	
outputDec:
	la 		$a0, res_mul
	li 		$v0, 4
	syscall
	add 	$a0, $0, $s0
	li 		$v0, 1
	syscall
	
	la 		$a0, newline
	li 		$v0, 4
	syscall

###########Division##############
division:
	add	$s3, $s6, $zero
	add $s4, $s3, $zero ## dung de xet dau
	slt $t0, $s4, $zero
	beq $t0, $0, next1
	## doi thanh so duong
	sub $s3, $0, $s3
	next1:

	add 	$s1, $s7, $zero 	# divisor = $s1
	beq 	$s1, $0, Invalid    # invalid division
	add		$s5, $s1, $zero 	# for checking sign
	slt 	$t0, $s5, $0
	beq 	$t0, $0, next2

	sub 	$s1, $0, $s1		# convert to positive
	next2:

######################################
## Register $s1: Divisor 		    ##
## Register $s3: Remainder			##
######################################
	li 		$t1, 0 				# Counter
	li 		$t2, 16
Loop:

#Step 1: 
	sll 	$s3, $s3, 1 		# shift left remainder reg

	srl 	$t6, $s3, 16 		# t6 contain high - 16 bits 
	sll 	$t7, $s3, 16 		# t7 contain low - 16 bits
	srl 	$t7, $t7, 16 	
	sub 	$t5, $t6, $s1 		# tru 16 bit cao voi so du
########################################################
##Step 2: Check if the above subtraction negative or not 
	slt 	$t0, $t5, $0  
	beq 	$t0, $0, lonhonkhong

	add 	$t5, $t5, $s1    	#If negative, add back divisor
	j next
	lonhonkhong:
	addi 	$t7, $t7, 1 		# change lowest bit from bit 0 to bit 1
next:
	sll 	$t5, $t5, 16 	
	add 	$s3, $t5, $t7
	addi 	$t1, $t1, 1 		# counter increase by 1
	beq 	$t1, $t2, exitLoop 	# if count == 16 exit loop

	j Loop
exitLoop:
	srl 	$t5, $s3, 16
	jal 	xetdau
	# Check quotient
	sll 	$a0, $s3, 16
	srl 	$a0, $a0, 16

	# Now, print value to console	
	sh 		$s3, Q
	lh		$s0, Q
	
	srl		$s6, $s3, 16
	sh		$s6, R
	beq 	$t9, 1, outputHex_divQ		# If mode is 1, branch to output Hex type
	beq 	$t9, 2, outputDec_divQ		# If mode is 2, branch to output Dec type
	
outputHex_divQ:
	li 	$t0, 8 							# counter 
	la 	$t3, result 					# where answer will be stored 

	Loop_div: 	
		beq 	$t0, 0, _popStack 		# branch to popStack if counter is equal to zero 
		and 	$t4, $s0, 0xf 			# and with 1111 
		srl 	$s0, $s0, 4				# Shift 4 low bits in s0 to right (remove it)
		slti	$t8, $t4, 9				# digits have range from 0 - 9
		beq		$t8, 1, _Sum
		beq 	$t4, 9, _Sum 			# if less than or equal to nine, branch to sum 
		addi 	$t4, $t4, 55 			# if greater than 9, (55 is digit 7 in ascii table)
		j 		_End 
_Sum:    
		addi 	$t4, $t4, 48 			# add 48 to result (48 is digit 0 in ascii table)
_End:
		subu 	$sp, $sp, 4				# Create a location in stack
		sb		$t4, ($sp)  			# Store $t4 to stack
		addi 	$t0, $t0, -1 			# decrement loop counter 
		j 		Loop_div
	
	_popStack:
		beq 	$t0, 8, __exit			# If popStack loop do 8 times, stop it (stack empty)
		lb 		$t7, ($sp)				# Pick front value of stack
		addu 	$sp, $sp, 4				# pop stack
		sb 		$t7, 0($t3)				# Store that value to result space
		addi 	$t3, $t3, 1				# increase address by 1
		addi 	$t0, $t0, 1				#increase count by 1
		j 		_popStack
	__exit:
		
	# Print result
	la $a0, str3
	li $v0, 4
	syscall
	
	la $a0, result 
	li $v0, 4 
	syscall 
	
	j print_remainder
	
outputDec_divQ:
	la 		$a0, str3
	li 		$v0, 4
	syscall
	
	add 	$a0, $0, $s0
	li 		$v0, 1
	syscall
	
	j print_remainder

# Now, print remainder to console
print_remainder:
	lh		$s0, R
	
	beq 	$t9, 1, outputHex_divR		# If mode is 1, branch to output Hex type
	beq 	$t9, 2, outputDec_divR		# If mode is 2, branch to output Dec type
	
outputHex_divR:
	li 	$t0, 8 							# counter 
	la 	$t3, result 					# where answer will be stored 

	Loop_divR: 	
		beq 	$t0, 0, _popStackR 		# branch to popStack if counter is equal to zero 
		and 	$t4, $s0, 0xf 			# and with 1111 
		srl 	$s0, $s0, 4				# Shift 4 low bits in s0 to right (remove it)
		slti	$t8, $t4, 9				# digits have range from 0 - 9
		beq		$t8, 1, _SumR
		beq 	$t4, 9, _SumR 			# if less than or equal to nine, branch to sum 
		addi 	$t4, $t4, 55 			# if greater than 9, (55 is digit 7 in ascii table)
		j 		_EndR 
_SumR:    
		addi 	$t4, $t4, 48 			# add 48 to result (48 is digit 0 in ascii table)
_EndR:
		subu 	$sp, $sp, 4				# Create a location in stack
		sb		$t4, ($sp)  			# Store $t4 to stack
		addi 	$t0, $t0, -1 			# decrement loop counter 
		j 		Loop_divR
	
	_popStackR:
		beq 	$t0, 8, __exitR			# If popStack loop do 8 times, stop it (stack empty)
		lb 		$t7, ($sp)				# Pick front value of stack
		addu 	$sp, $sp, 4				# pop stack
		sb 		$t7, 0($t3)				# Store that value to result space
		addi 	$t3, $t3, 1				# increase address by 1
		addi 	$t0, $t0, 1				#increase count by 1
		j 		_popStackR
	__exitR:
		
	# Print result
	la $a0, str4
	li $v0, 4
	syscall
	
	la $a0, result 
	li $v0, 4 
	syscall 
	
	la $a0, newline
	li $v0, 4
	syscall
	li $v0, 10
	syscall
	
outputDec_divR:
	la 		$a0, str4
	li 		$v0, 4
	syscall
	
	add 	$a0, $0, $s0
	li 		$v0, 1
	syscall
	
	la 		$a0, newline
	li 		$v0, 4
	syscall
	# Stop Program
	li $v0, 10
	syscall
Invalid:
	la $a0, str5
	li $v0, 4
	syscall

	li $v0, 10
	syscall

xetdau:
###   Reg $s4: dividend
###   Reg $s5: divisor
###   Reg $s3: high - 16 bit cao store remainder, low - 16 bit store quotient

	slt $t0, $s4, $0
	slt $t1, $s5, $0
	beq $t0, $0, sobichialonhonkhong
##############################

	beq $t1, $0, nguocdau
##Dividend and divisor are negative
	sub $t5, $0, $t5
	j nextdi
nguocdau:
	#sub $t7, $0, $t7
	#addi $t7, $t7, 0x00010000
	#sub $t5, $0, $t5
	#j nextdi
	sub		$t7, $zero, $t7
	slt		$t1, $t7, $zero
	beq		$t1, $zero, label
	addi	$t7, $t7, 0x00010000
	label:
	sub		$t5, $zero, $t5
	j nextdi
##################################
sobichialonhonkhong:
	beq $t1, $0, nextdi
### divisor < 0
	sub $t7, $0, $t7
	addi $t7, $t7, 0x00010000
	nextdi:

	sll $t5, $t5, 16
	add $s3, $t5, $t7

	jr $ra


###################################################################
#END TODO
inputHex:
	# Read fisrt number
	la 		$a0, hex1
	li 		$v0, 4
	syscall
	
	# Read hex number string
	la		$a0, str1
	addi 	$a1, $a0, 1000
	li 		$v0, 8
	syscall 
	
	# str is stored hex number
	la 		$t0, str1
	# initailization
	addi 	$t1, $zero, 0	 #index = 0
	addi 	$s0, $zero, 0	 #SumDecNumber = 0
	
	jal 	convert
	add 	$s1, $zero, $v0	# register store first number
	
	la 		$a0, hex2
	li 		$v0, 4
	syscall
	
	# Read hex number string
	la		$a0, str2
	addi 	$a1, $a0, 1000
	li 		$v0, 8
	syscall 
	
	# str is stored hex number
	la 		$t0, str2
	# initailization
	addi 	$t1, $zero, 0	 #index = 0
	addi 	$s0, $zero, 0	 #SumDecNumber = 0
	
	jal 	convert
	add 	$s2, $zero, $v0	# register store first number
	
	j 		main_program
	# $s1 is first number, $s2 is second number
	
	
	convert:
	loop:
		add 	$t2, $t0, $t1			# Load address of str's space where hex number string is contained
		lb 		$t3, 0($t2)				# Load fisrt digit
		beq 	$t3, '\n', exit_convert	# Exit when the string is empty
		subi 	$t4, $t3, '0'			# Get number in integer type
		
		slti 	$t8, $t4, 10			# Compare $t4 with 10 
		beq		$t8, $zero, letter		# That mean, digit has range from 10 to 15 (A to F)
		j 		normal
		letter:
		subi $t4, $t3, '7'				# Get value of digit in ascii
		
		normal:
		addi $t5, $t1, 0  				# Index of string
	
		len_loop:						# Calculate length of hex string
			add 	$t6, $t0, $t5			
			lb 		$t7, 0($t6)
			beq 	$t7, '\n', exit_len_loop
			addi 	$t5, $t5, 1
			j 		len_loop
			
		exit_len_loop:
			sub 	$t5, $t5, $t1
		multiply:						# Calculate dec number
			beq 	$t5, 1, exit_multiply
			sll 	$t4, $t4, 4
			subi 	$t5, $t5, 1
			j 		multiply
		
		exit_multiply:
			add 	$s0, $s0, $t4
			addi 	$t1, $t1, 1
		j loop	
		
	exit_convert:
	add 	$v0, $s0, $zero
	jr 		$ra		
		
inputDec:
	# Read first number
	la $a0, dec1
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	add $s1, $zero, $v0
	
	# Read second number
	la $a0, dec2
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	add $s2, $zero, $v0
	j main_program
	
		 	
	
	
	
