.data
str_in: .asciiz "Enter the multiplicant: "
str_in1: .asciiz "Enter the multiplier: "
str_out: .asciiz "Product: " 
.text  
Enter:
# Enter the multiplicant
la $a0, str_in
add $v0, $0, 4
syscall 

li $v0, 6
syscall 
mfc1 $t0, $f0		# $t0 =multiplicant

#Enter the multiplier
la $a0,str_in1
add $v0, $0, 4 
syscall 
li $v0, 6
syscall
mfc1 $t1, $f0 		#$t1 s= multiplier

# Sign of product
Get_sign:
srl $s0, $t0, 31	#sign of multiplicant
srl $s1, $t1, 31	#sign of multiplier
xor $s2, $s0, $s1	#sign of product
sll $s2, $s2, 31	# sign is MSB  

# function get exponent of multiplicant, multiplier
Get_exponent:
sll $t2, $t0, 1		#shift left $t0 1 bit
srl $t2, $t2, 24	#shift right $t2 24bit
sll $t3, $t1, 1		#shift left $t1 1 bit
srl $t3, $t3, 24	#shift right $t3 24bit

#add 2 exponent 
Add_exponent:
add $t6, $t2, $t3	
addi $t6, $t6,-127 	# t6= exponent of product

#function get mantissa of multiplicant, multiplier
Get_mantissa:
sll $t4,$t0, 9		#shift left $t0 9 bit
srl $t4, $t4 9		#shift right $t4 bit
addi $t4, $t4, 8388608	#add bit 1 to front of $t4
sll $t5,$t1, 9		#shift left $t1 9 bit
srl $t5, $t5, 9		#shift right $t5 bit
addi $t5, $t5, 8388608	#add bit 1 to front of $t5
 
#add 2 mantissa
Mul_mantissa:
mult $t4, $t5		# mul 2 mantissa and store to Hi-Lo
mfhi $s3		#copy Hi to $s3
mflo $s4		#copy Lo to $s4	
srl $s5, $s3, 15	#shift right $s3 15 bit 
beq $s5, 0, man_pro	#if $s3 is 14 bit then man_pro
sll $s6, $s3, 31	#else $s3 is 15 bit then process
srl $s4, $s4, 1		#
add $s4, $s4, $s6	#$s4 is Lo register	
srl $s3, $s3, 1		#$s3 is Hi register
addi $t6, $t6, 1	#add exponent 1

#process mantissa for product
man_pro:		#get 23 bit MSB for mantissa 
sll $s3, $s3, 18		
srl $s3, $s3, 9		# get 14bit of Hi
srl $s4, $s4, 23	#get 9 bit for Lo
add $s4, $s3, $s4	#mantissa of product

#connect 3 element and return product $f2
Return_product:	
sll $t6, $t6, 23	#
add $t7, $s2, $t6
add $t7, $t7, $s4
mtc1 $t7, $f2

#print result
Print_out:
la $a0, str_out 
add $v0, $0, 4
syscall

mov.s $f12, $f2
li $v0, 2
syscall
