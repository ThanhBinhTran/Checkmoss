.data
prompt_input1:			.asciiz "Enter first number:\t"
prompt_input2:			.asciiz "Enter second number:\t"
result_sum:				.asciiz "\nThe sum is:\t\t"
result_dif:				.asciiz "\nThe difference is:\t"
pos_infinity:			.asciiz "Infinity"
neg_infinity:			.asciiz "-Infinity"
nan:					.asciiz "NaN"

.text
.globl main
main:
	#################### first number ##########################
	la $a0,prompt_input1				# print prompt_input1
	addi $v0,$zero,4
	syscall
	addi $v0,$zero,6					# read first number to $f0
	syscall
	mfc1 $t0,$f0						# move from $f0 to $t0
										###### test ######
										# addi $a0,$t0,0
										# addi $v0,$zero,1
										# syscall
										# input 0.5 ( = 0x3f000000)
										# output 1056964608 ( = 15 * 16^6 + 3 * 16^7)
										
	#################### second number ##########################
	la $a0,prompt_input2				# print prompt_input1
	addi $v0,$zero,4
	syscall
	addi $v0,$zero,6					# read first number to $f0
	syscall
	mfc1 $t4,$f0						# move from $f0 to $t4
	

	# calculate the sum
	la $a0,result_sum					# print result_sum
	addi $v0,$zero,4
	syscall
										# arguments
	add $a0,$zero,$t0					# $a0 = $t0 = the first number
	add $a1,$zero,$t4					# $a1 = $t4 = the second number
	jal add								# call procedure add
	
	# $v0 = sum, $v1 = 0 => print sum, $v1 = 1 => NaN, $v1 = 2 => Infinity, $v1 = 3 => -Infinity
	addi $t1,$zero,1
	addi $t2,$zero,2
	addi $t3,$zero,3
	beq $v1,$t1,add_return_nan
	beq $v1,$t2,add_return_pos_infinity
	beq $v1,$t3,add_return_neg_infinity
	# $v1 = 0 => print float number
	mtc1 $v0,$f12						# $v0 = sum (after calling procedure add), move from $v0 to $f12 to print
	addi $v0,$zero,2					# print float number
	syscall
	j call_subtract
add_return_nan:
	la $a0,nan							# print nan
	addi $v0,$zero,4
	syscall
	j call_subtract
add_return_pos_infinity:
	la $a0,pos_infinity					# print pos_infinity
	addi $v0,$zero,4
	syscall
	j call_subtract
add_return_neg_infinity:
	la $a0,neg_infinity					# print neg_infinity
	addi $v0,$zero,4
	syscall
	j call_subtract

call_subtract:
	# calculate the difference
	la $a0,result_dif					# print result_dif
	addi $v0,$zero,4
	syscall
										# arguments
	add $a0,$zero,$t0					# $a0 = $t0 = the first number
	add $a1,$zero,$t4					# $a1 = $t4 = the second number
	jal subtract						# call procedure subtrac

	# $v0 = sum, $v1 = 0 => print sum, $v1 = 1 => NaN, $v1 = 2 => Infinity, $v1 = 3 => -Infinity
	addi $t1,$zero,1
	addi $t2,$zero,2
	addi $t3,$zero,3
	beq $v1,$t1,subtract_return_nan
	beq $v1,$t2,subtract_return_pos_infinity
	beq $v1,$t3,subtract_return_neg_infinity
	# $v1 = 0 => print float number
	mtc1 $v0,$f12						# $v0 = sum (after calling procedure add), move from $v0 to $f12 to print
	addi $v0,$zero,2					# print float number
	syscall
	j end_program
subtract_return_nan:
	la $a0,nan							# print nan
	addi $v0,$zero,4
	syscall
	j end_program
subtract_return_pos_infinity:
	la $a0,pos_infinity					# print pos_infinity
	addi $v0,$zero,4
	syscall
	j end_program
subtract_return_neg_infinity:
	la $a0,neg_infinity					# print neg_infinity
	addi $v0,$zero,4
	syscall
	j end_program

end_program:	
	addi $v0,$zero,10					# end program
	syscall

############################ PROCEDURE ADD ###############################
add:
	# $s0, $s1, $s2, $s3 will be used in add procedure
	# so we need to store these values in stack
	# after the procedure add finished, we restore these values back
	addi $sp,$sp,-16
	sw $s0,12($sp)
	sw $s1,8($sp)
	sw $s2,4($sp)
	sw $s3,0($sp)
	###
	
	######################## check zero #############################
	addi $t0,$a0,0						# $t0 = first number
	addi $t4,$a1,0						# $t4 = second number
	lui $t8,0x8000						# $t8 = -0
	# ori $t8,$t8,0x0000 no need
	beq $t0,$zero,add_zero_1			# first number = 0 -> add_zero_1
	beq $t0,$t8,add_zero_1				# first number = -0 -> add_zero_1
	# from here first number != 0,-0
	beq $t4,$zero,add_zero_1			# second number = 0 -> add_zero_1
	beq $t4,$t8,add_zero_1				# second number = -0 -> add_zero_1
	# from here first number != 0,-0 and second number != 0,-0
	
	#################### sign of first number ##########################
	srl $t1,$t0,31						# shift right 31 bits (high-order bit gets zeros and the low-order bits are discarded)
										# $t1 = 0x00000000 or 0x00000001
										###### test #########
										# addi $a0,$t1,0
										# addi $v0,$zero,1
										# syscall
										# input 0.5 output 0
										# input -0.5 output 1
									
	#################### exponent of first number ##########################
	sll $t2,$t0,1						# shift left 1 bit (remove 1-bit sign)
	srl $t2,$t2,24						# shift right logical 24 bits (remove 23-bit fraction and last 1-bit 0)
										###### test #########
										# addi $a0,$t2,0
										# addi $v0,$zero,1
										# syscall
										# input 0.5 output 126
										# input -0.4375 output 125
	
	#################### fraction of first number ##########################
	sll $t3,$t0,9						# shift left 9 bits (remove 1-bit sign and 8-bit exponent)
	srl $t3,$t3,9						# shift right logical 9 bits (zeros padding)
										###### test #########
										# addi $a0,$t3,0
										# addi $v0,$zero,1
										# syscall
										# input 0.5 output 0
										# input -0.4375 output 6291456 = 2^22
	lui $t8,0x0080						# 0x00800000 = 0000 0000 1000 0000 0000 0000 0000 0000
	# ori $t8,$t8,0x0000 no need
	or $t3,$t3,$t8						# makes the 23th bit (rightmost is 0th) become 1 to represent 1 in (1 + F)
										###### test #########
										# addi $a0,$t3,0
										# addi $v0,$zero,1
										# syscall
										# input 0.5 output 8388608 = 2^23 (= 1(.)000)
										# input -0.4375 output 14680064 = 2^23 + 2^22 + 2^21 (-1(.)110)
	

									
	#################### sign of second number ##########################
	srl $t5,$t4,31						# shift right logical 31 bits (zeros padding)
										# $t5 = 0x00000000 or 0x00000001
									
	#################### exponent of second number ##########################
	sll $t6,$t4,1						# shift left 1 bit (remove 1-bit sign)
	srl $t6,$t6,24						# shift right logical 24 bits (remove 23-bit fraction and last 1-bit 0)
	
	#################### fraction of second number ##########################
	sll $t7,$t4,9						# shift left 9 bits (remove 1-bit sign and 8-bit exponent)
	srl $t7,$t7,9						# shift right logical 9 bits (zeros padding)
	lui $t8,0x0080						# 0x00800000 = 0000 0000 1000 0000 0000 0000 0000 0000
	# ori $t8,$t8,0x0000 no need
	or $t7,$t7,$t8						# makes the 23th bit (rightmost is 0th) become 1 to represent 1 in (1 + F)
	
	############################### check infinity ############################
	lui $t8,0x7f80						# $t8 = 0x7f800000 = Infinity
	# ori $t8,$zero,0x0000 no need
	lui $t9,0xff80						# $t9 = 0xff800000 = -Infinity
	# ori $t9,$zero,0x0000 no need
	bne $t0,$t8,check_neg_infinity		# first number != Infinity -> check_neg_infinity
	beq $t4,$t9,add_nan					# first number = Infinity and second number = -Infinity -> add_nan
	j add_infinity						# first number = Infinity and (second number = Infinity or num) -> add_infinity
check_neg_infinity:
	bne $t0,$t9,check_infinity_2		# first number != -Infinity -> check_infinity_2 (check if second number is infinity)
	beq $t4,$t8,add_nan					# first number = -Infinity and second number = Infinity -> add_nan
	j add_infinity						# first number = -Infinity and (second number = -Infinity or num) -> add_infinity
check_infinity_2:
	beq $t4,$t8,add_infinity			# first number = num and second number = Infinity -> add_infinity
	beq $t4,$t9,add_infinity			# first number = num and second number = -Infinity -> add_infinity
	j step1								# first number = num and second number = num -> step1

step1:
	# first number 	$t0					sign $t1 exponent $t2 fraction $t3
	# second number $t4					sign $t5 exponent $t6 fraction $t7
	
	# step 1: makes the exponents of two numbers become equal
	beq $t2,$t6,step2					# if e1 = e2 -> step2
	slt $t8,$t2,$t6						# if e1 < e2 then $t8 = 1
	bne $t8,$zero,e1_lessThan_e2		# if $t8 != 0 ($t8 = 1) -> e1_lessThan_e2
	# from here e1 > e2
e2_lessThan_e1:
	srl $t7,$t7,1						# shift fraction of second number right 1 bit
	addi $t6,$t6,1						# => exponent + 1
	beq $t2,$t6,step2					# if e1 = e2 -> equal
	j e2_lessThan_e1
e1_lessThan_e2:
	srl $t3,$t3,1						# shift fraction of first number right 1 bit
	addi $t2,$t2,1						# => exponent + 1
	beq $t2,$t6,step2					# if e1 = e2 -> equal
	j e1_lessThan_e2

step2:
	# from here e1 = e2
										###### test #######
										# addi $a0,$t2,0
										# addi $v0,$zero,1
										# syscall
										# addi $a0,$zero,32
										# addi $v0,$zero,11
										# syscall

										# addi $a0,$t3,0
										# addi $v0,$zero,1
										# syscall
										# addi $a0,$zero,32
										# addi $v0,$zero,11
										# syscall
	
										# addi $a0,$t6,0
										# addi $v0,$zero,1
										# syscall
										# addi $a0,$zero,32
										# addi $v0,$zero,11
										# syscall
	
										# addi $a0,$t7,0
										# addi $v0,$zero,1
										# syscall
										# addi $a0,$zero,32
										# addi $v0,$zero,11
										# syscall
									
										# input		1st = 0.5	2nd = -0.4375
										# output	e1 = 126	f1 = 1(.)000  = 8388608 = 2^23
										#			e2 = 126	f2 = -0(.)111 = 7340032 = 2^22 + 2^21 + 2^20
	
	# first number 	$t0					sign $t1 exponent $t2 fraction $t3
	# second number $t4					sign $t5 exponent $t6 fraction $t7
	
	# step 2: Add the significands
	
	addi $s1,$t1,0						# $s1 is sign of sum, initial = sign of first number
	addi $s2,$t2,0						# $s2 is exponent of sum, initial = exponent of first number
	addi $s3,$zero,0					# $s3 is fraction of sum, initial = 0
	
	# sign
	xor $t8,$t1,$t5						# same sign => $t8 = 0, opposite sign => $t8 = 1
	bne $t8,$zero,opposite_sign			# if $t8 != 0 ($t8 = 1) -> opposite_sign
	# from here same sign
	addi $s1,$t1,0						# $s1 is sign of sum = sign of first or second number (addi $s0,$t5,0 is OK)
	addi $s2,$t2,0						# $s2 is exponent of sum = exponent of first or second number (addi $s1,$t6,0 is OK)
	add $s3,$t3,$t7						# $s3 is fraction of sum
	j step3
opposite_sign:
	beq $t5,$zero,firstNeg_SecondPos	# first < 0, second > 0
	# here first > 0, second < 0
	sub $s3,$t3,$t7						# frac1 - frac2
	j check_dif_frac
firstNeg_SecondPos:
	# here first < 0, second > 0
	sub $s3,$t7,$t3						# frac2 - frac1
check_dif_frac:
	# check if the final sum is 0 (two number is opposite sign and same value) => return 0
	# or if infinity - infinity or -infinity + infinity => return NaN
	bne $s3,$zero,dif_frac_not_zero		# dif_frac != 0 -> dif_frac_not_zero
	j add_zero_2						# dif_frac = 0 and exponent != 255 -> add_zero_2 (return 0)
dif_frac_not_zero:
	# from here dif_frac != 0
	slti $t9,$s3,0						# dif_frac is negative
	bne $t9,$zero,dif_frac_neg
	# from here dif_Frac > 0
	addi $s1,$zero,0					# $s1 is sign of sum (positive)
	addi $s2,$t2,0						# $s2 is exponent of sum = exponent of first or second number (addi $s1,$t6,0 is OK)
										# $s3 is OK, no 2's complement
	j step3
dif_frac_neg:
	addi $s1,$zero,1					# $s1 is sign of sum (negative)
	addi $s2,$t2,0						# $s2 is exponent of sum = exponent of first or second number (addi $s1,$t6,0 is OK)
										# 2's complement of $s3
	nor $s3,$s3,$s3						# not $s3
	addi $s3,$s3,1						# $s3++


step3:
										###### test #######
										# addi $a0,$s1,0
										# addi $v0,$zero,1
										# syscall
										# addi $a0,$zero,32
										# addi $v0,$zero,11
										# syscall

										# addi $a0,$s2,0
										# addi $v0,$zero,1
										# syscall
										# addi $a0,$zero,32
										# addi $v0,$zero,11
										# syscall
	
										# addi $a0,$s3,0
										# addi $v0,$zero,1
										# syscall
										# addi $a0,$zero,32
										# addi $v0,$zero,11
										# syscall
										
										# input		1st = 0.5	2nd = -0.4375
										# output	s = 0		e = 126			f = 0(.)001 = 1048576 = 2^20
	
	# first number 	$t0					sign $t1 exponent $t2 fraction $t3
	# second number $t4					sign $t5 exponent $t6 fraction $t7
	# sum			$s0					sign $s1 exponent $s2 fraction $s3
	
	# step 3: Normalize the sum, checking for overflow or underflow
	
	lui $t8,0x00ff						# $t8 = 0x00ffffff = 0000 0000 1111 1111 1111 1111 1111 1111
	ori $t8,$t8,0xffff
	slt $t9,$t8,$s3						# if 0x00ffffff < $s3 -> shift_right
	bne $t9,$zero,shift_right
	# here $s3 <= 0x00ffffff
	lui $t8,0x0080						# $t8 = 0x00800000 = 0000 0000 1000 0000 0000 0000 0000 0000
	# ori $t8,$t8,0x0000 no need
	slt $t9,$s3,$t8						# if $s3 < 0x00800000 -> shift_left
	bne $t9,$zero,shift_left
	# here $s3 >= 0x00800000 && $s3 <= 0x00ffffff
	j check_of_uf
	
shift_right:
	srl $s3,$s3,1						# shift right 1 bit
	addi $s2,$s2,1						# exponent++
	slt $t9,$t8,$s3						# if 0x00ffffff < $s3 -> shift_right
	bne $t9,$zero,shift_right
	j check_of_uf
shift_left:
	sll $s3,$s3,1						# shift left 1 bit
	addi $s2,$s2,-1						# exponent--
	slt $t9,$s3,$t8						# if $s3 < 0x00800000 -> shift_left
	bne $t9,$zero,shift_left
	j check_of_uf
	
	# check overflow, underflow
	
check_of_uf:
	# valid: 0 <= exponent <= 254
	# exponent = 0 reserved for zero, but can be denormalized
	# exponent = 255 && 23-bit fraction  = 0..0 => infinity
	# exponent = 255 && 23-bit fraction != 0..0 => NaN (not a number)

	addi $t8,$zero,254					# $t8 = 254
	slti $t9,$s2,0						# exponent < 0
	bne $t9,$zero,add_nan				# if exponent < 0 -> add_nan
	slt $t9,$t8,$s2						# 254 < exponent
	bne $t9,$zero,add_infinity			# if 254 < exponent -> add_infinity
	
step4:
										###### test #######
										# addi $a0,$s1,0
										# addi $v0,$zero,1
										# syscall
										# addi $a0,$zero,32
										# addi $v0,$zero,11
										# syscall

										# addi $a0,$s2,0
										# addi $v0,$zero,1
										# syscall
										# addi $a0,$zero,32
										# addi $v0,$zero,11
										# syscall
	
										# addi $a0,$s3,0
										# addi $v0,$zero,1
										# syscall
										# addi $a0,$zero,32
										# addi $v0,$zero,11
										# syscall
										
										# input		1st = 0.5	2nd = -0.4375
										# output	s = 0		e = 123			f = 1(.)000 = 8388608 = 2^23

	# first number 	$t0					sign $t1 exponent $t2 fraction $t3
	# second number $t4					sign $t5 exponent $t6 fraction $t7
	# sum			$s0					sign $s1 exponent $s2 fraction $s3
	
	# step 4: combine sign, exponent and fraction together into $s0
	
	sll $s1,$s1,31						# sign in correct position
	
	sll $s2,$s2,24						
	srl $s2,$s2,1						# exponent in correct position
	
	sll $s3,$s3,9						# remove 23-th bit (rightmost is 0th), which is used to represent 1 in (1 + F)
	srl $s3,$s3,9						# fraction in correct position
	
	addi $s0,$zero,0					# $s0 is the sum
	or $s0,$s1,$s2
	or $s0,$s0,$s3
	
	addi $v0,$s0,0						# $v0 = sum
	addi $v1,$zero,0					# $v1 = 0 => success
	j add_return
	
add_zero_1:
	addi $s0,$t0,0						# $s0 = $t0 = first number
	addi $s1,$t4,0						# $s1 = $t4 = second number
	lui $t8,0x8000						# $t8 = -0
	# ori $t8,$t8,0x0000 no need
	# consider (-0) + (-0) = (-0)
	bne $s0,$t8,make_zero				# first number != -0 -> make_zero
	bne $s1,$t8,make_zero				# second number != -0 -> make_zero
	# here both number = -0
	add $v0,$zero,$t8					# $v0 = -0
	addi $v1,$zero,0					# $v1 = 0 => success
	j add_return
	# check if any number = -0 then make it = 0
make_zero:
	beq $s0,$t8,make_zero_1				# check first number
	j next_1
make_zero_1:
	addi $s0,$zero,0					# if first number = -0 then make it 0
	j next_1
make_zero_2:
	addi $s1,$zero,0					# if second number = -0 then make it 0
	j next_2
next_1:
	beq $s1,$t8,make_zero_2				# check second number
next_2:
	# first number and second number converted to 0 (if any = -0)
	add $v0,$s0,$s1						# return integer sum of one number and 0 (that number doesn't change its value)
	addi $v1,$zero,0					# $v1 = 0 => success
	j add_return
	

add_zero_2:
	addi $v0,$zero,0					# return 0 (two number is opposite sign and same value)
	addi $v1,$zero,0					# $v1 = 0 => success
	j add_return

add_nan:
	addi $v0,$zero,0
	addi $v1,$zero,1					# $v1 = 1 => NaN
	j add_return

add_infinity:
	addi $v0,$zero,0
	slt $t8,$t2,$t6						# e1 < e2 
	bne $t8,$zero,choose_2				# if e1 < e2 => choose sign of second number
	j choose_1							# else => choose sign of first number
choose_1:
	beq $t1,$zero,add_pos_infinity
	j add_neg_infinity
choose_2:
	beq $t5,$zero,add_pos_infinity
	j add_neg_infinity
add_pos_infinity:
	addi $v1,$zero,2					# $v1 = 2 => positive Infinity
	j add_return
add_neg_infinity:
	addi $v1,$zero,3					# $v1 = 3 => negative Infinity
	j add_return

add_return:
	# restore $s0, $s1, $s2, $s3
	lw $s0,12($sp)
	lw $s1,8($sp)
	lw $s2,4($sp)
	lw $s3,0($sp)
	addi $sp,$sp,16
	###
	jr $ra								# return
	
	
################################# PROCEDURE SUBTRACT #####################
subtract:
	# idea: a - b = a + (-b)
	addi $sp,$sp,-4						# store the main's return address
	sw $ra,0($sp)
	
	addi $t0,$a0,0						# $t0 = $a0 = first number
	addi $t4,$a1,0						# $t4 = $a1 = second number
	
	srl $t5,$t4,31						# $t5 = 1-bit sign of the second number
	nor $t5,$t5,$t5						# not $t5
	sll $t5,$t5,31						# move the 1-bit sign at most significant bit (leftmost bit)
	
	sll $t6,$t4,1						# remove the 1-bit sign of the second number
	srl $t6,$t6,1						# move back to its original position
	
	or $t4,$t5,$t6						# after reversing the 1-bit sign, combine it with the rest bits
										# to form the new second number having the sign opposite with the original second number
	
										# arguments
	addi $a0,$t0,0						# $a0 = the first number
	addi $a1,$t4,0						# $a1 = the new second number having the sign opposite with the original second number
	jal add								# call procedure add
	
	addi $v0,$v0,0						# result
	addi $v1,$v1,0						# status
	
	lw $ra,0($sp)						# restore the main's return address
	addi $sp,$sp,4
	
	jr $ra								# return to main
