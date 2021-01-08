.data
	In1_str:	.asciiz "Input first number: "
	In2_str:	.asciiz "Input second number: "
	str_smallexp:	.asciiz "Exponent is too small !!!"
	str_bigexp:	.asciiz "Exponent is too big !!!"
	Out_str:	.asciiz "Multiplication result: "
.text
main:
### Input two real number
	la $a0, In1_str
	li $v0, 4
	syscall
	li $v0, 6				# Input first number
	syscall
	mfc1 $a1, $f0				# Move from $f0 to $a1
	
	la $a0, In2_str
	li $v0, 4
	syscall
	li $v0, 6				# Input second number
	syscall	
	mfc1 $a2, $f0				# Move from $f0 to $a2
### $a1, $a2 are holding values of two real number

	# zero handling
	add $s0, $zero, $zero			# init $a0 = 0
	beqz $a1, print_result			# if $a1 == 0, jump to the end and result is 0
	beqz $a2, print_result			# if $a2 == 0, jump to the end and result is 0
	
	# sign handling
	xor $s0, $a1, $a2
	srl $s0, $s0, 31	
	sll $s0, $s0, 31 
### $s0 is holding sign of multiplication

	# Get exponent
	srl $t0, $a1, 23			# Get the first 9 bits of $a1 (include 1 bit sign and 8 bits exponent) and store in $t0. 
	andi $t0, $t0, 0x000000ff		# Get 8 bits exponent and store in $t0.
	srl $t1, $a2, 23			# Get the first 9 bits of $a2 (include 1 bit sign and 8 bits exponent) and store in $t1.
	andi $t1, $t1, 0x000000ff		# Get 8 bits exponent and store in $t1.
	
	# add two exponent
	addu $s1, $t0, $t1			# add two exponent
	bltu $s1, 127, TooSmallExp		# if exponent is too small
	subi $s1, $s1, 127			# else exponent must be sub bias
	sll $s1, $s1, 23			# shift exponent to its correct position
	bltz $s1, TooBigExp			# exponent is too big, it overflows the register
### $s1 is holding exponent (in its correct position)

	# Get fraction
	andi $t0, $a1, 0x007fffff		# Get faction of $a1 and store in $t0
	ori $t0, $t0, 0x00800000		# Add 1 in front of this fraction.(this fraction has 24 bits)
	andi $t1, $a2, 0x007fffff		# Get faction of $a2 and store in $t1
	ori $t1, $t1, 0x00800000		# Add 1 in front of this fraction.(this fraction has 24 bits)
	
	# Multiply two fraction
	multu $t0, $t1				# results of multiplication can be 47 bits or 48 bits
	mfhi $t2				# take 15 or 16 bits high into $t2
	mflo $t3				# take 32 bits low into $t3
### $t2 and $t3 are holding 15/16 bits high and 32 bits low of fraction

	# Check 47 bits or 48 bits
	and $t4, $t2, 0x0000ffff		
	srl $t4, $t4, 15			# $t4 is holding 16th bit of high
	beq $t4, $0, fourtyseven_bits		# check 47 bits or 48 bits
	
fourtyeight_bits: 
	andi $t2, $t2, 0x00007fff		# Get 15 bits high (don't get bit 1 in head)
	sll $t2, $t2, 8				# shift to correct position
	srl $t3, $t3, 24			# Get 8 bits low (ignore 24 bits remain) 
	or $s2, $t2, $t3			# $s2 is holding fraction
	
	# Add 1 to the exponent
	srl $s1, $s1, 23			# add 1 in 9th bit
	addi $s1, $s1, 1
	sll $s1, $s1, 23

	# combine three registers
	or $s0, $s0, $s1
	or $s0, $s0, $s2			# then combine with fraction
	j print_result
	
fourtyseven_bits:
	andi $t2, $t2, 0x00003fff		# Get 14 bits (don't get bit 1 in head)
	sll $t2, $t2, 9				# shift to correct position
	
	srl $t3, $t3, 23			# Get 8 bits low (ignore 23 bits remain) 
	or $s2, $t2, $t3			# $s2 is holding fraction
	
	# combine three registers
	or $s0, $s0, $s1
	or $s0, $s0, $s2			# then combine with fraction
	j print_result
	
### Exception
TooSmallExp:
	la $a0, str_smallexp				
	li $v0, 4
	syscall
	j exit
TooBigExp:
	la $a0, str_bigexp
	li $v0, 4
	syscall
	j exit
	
print_result:
	la $a0, Out_str
	li $v0, 4
	syscall					# print Out_str
	mtc1 $s0, $f12
	li $v0, 2
	syscall					# print result		
exit:
