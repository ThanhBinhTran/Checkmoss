.data
prompt1: .asciiz "Enter the first number: "
prompt2: .asciiz "Enter the second number: "
err:	.asciiz "Error: Divide by 0\n"
answer: .asciiz "The product of those numbers is: "
mode: .asciiz "1) Decimal mode         2) Hexadecimal mode \n"
mulVsDiv: .asciiz "1) Multiply mode        2) Divide mode\n"
first_hex_number: .asciiz "2991aab"
second_hex_number: .asciiz "723ad"
new_line:      .asciiz " \n"
end1:	.asciiz "\nQuotient: "
end2:	.asciiz "\nRemainder: "
	.align 2
saven:	.word
.text
.globl main

main:
	# Display choose mode
	li $v0, 4
	la $a0, mode
	syscall
	
	#input from the user
	li $v0, 5 
	syscall
	move $t9,$v0
	
	beq $t9, 2, hexa
	
	
	# Display prompt1
	li $v0, 4
	la $a0, prompt1
	syscall

	li $v0, 5 # read keyboard into $v0 (number x is number to test)
	syscall
	move $s0,$v0 # move the first number from $v0 in $t0

	# Display the prmopt2 (string)
	li $v0, 4
	la $a0, prompt2
	syscall

	# read keyboard into $v0 
	li $v0, 5 
	syscall
		
	# move the second number from $v0 in $t1
	move $s1,$v0 
	
	# Mul or Div
	li $v0, 4
	la $a0, mulVsDiv
	syscall
	
	#input from the user
	li $v0, 5
	syscall
	move $t8, $v0
	beq $t8, 2, division
	
	
multiply:
	# $s0 - Multiplier 
	
	# $s1 -  Multiplicand
	
	# $t7 - Result we have to change this later
	
	# $t4 - The mask for the right bit
	
	# $t3 - The LSB of the multiplier


	li $t7, 0	# Initialize the result so that we are sure it is zero, Also helps with 0 multiples
	li $t4, 1	# a 1 Register
	li $t3, 0	# Initialize the LSB resultso that we are sure it is zero

loop:
	beq $s1, $zero, end_state	# If the multiplier is zero we finished because the answer is zero
	
	and $t3, $t4, $s1			# Get the LSB
	
	beq $t3, 1, add_a_to_c	# If the LSB is not zero, and thus 1, we add the multiplicand to the result
	
	beq $t3, 0, shift	# If the LSB is zero, thus we only need to do shifts 

add_a_to_c: 
	
	addu $t7, $t7, $s0		

shift:
	
	sll $s0, $s0, 1			# Shift left the multiplicand
		
	srl $s1, $s1, 1			# Shift right the multiplier

	j loop			# Back to the loop

end_state:
	# Return in $t7 

 
	move $s7, $t7 #Move the answer to s7 because temp regs aren't guarrentied to not change on syscalls


l1: 
	li $v0, 4 
	la $a0, answer
	syscall

	beq $t9, 2, answer_hex
	# print integer function call 1 
	# put the answer into $a0
	li $v0, 1 
	move $a0, $s7
	syscall
	
	li	 $v0, 4
	la 	 $a0, new_line
	syscall
	li $v0, 10
	syscall
answer_hex:
	li $v0, 34
	move $a0, $s7
	syscall
	#exit
	end:
	li	 $v0, 4
	la 	 $a0, new_line
	syscall 
	li $v0, 10 
	syscall 

hexa:
 	 li	 $v0, 4
	 la 	 $a0, new_line
	 syscall
	 li	 $v0, 4
	 la 	 $a0, prompt1
	 syscall
	 li	 $v0, 4
	 la 	 $a0, first_hex_number
	 syscall
	 li	 $v0, 4
	 la 	 $a0, new_line
	 syscall
	 li	 $v0, 4
	 la 	 $a0, prompt2
	 syscall
	 li	 $v0, 4
	 la 	 $a0, second_hex_number
	 syscall
	 li	 $v0, 4
	 la 	 $a0, new_line
	 syscall
	 # Mul or Div
	 li $v0, 4
	 la $a0, mulVsDiv
	 syscall
	
	 #input from the user
	 li $v0, 5
	 syscall
	 move $t8, $v0
	
	 la 	 $s1, first_hex_number
	 
         move    $a0, $s1                # move address of input str to a0
         jal     hex_convert             # call subroutine under test
	
	 move 	 $s0, $v0		# s0 = first_hex_number.toInteger()
	 
	
	 
	 li 	 $v0, 4
	 la 	 $a0, new_line
	 syscall 
	 
	 la $s2, second_hex_number
	 
	 move    $a0, $s2                # move address of input str to a0
         jal     hex_convert             # call subroutine under test

	 move	 $s1, $v0		 #s1 = second_hex_number.toInteger()
	
	 beq	 $t8, 2, division
	 j	 multiply
hex_convert:
        and     $v0, $v0, $zero             # make sure $v0 == 0

loop_hex:
        lb      $t0, 0($a0)                 # read next character
        beq     $t0, $zero, done            # if NULL, jump to done

case_ge_97:
        addi    $t1, $zero, 97              # set $t1 = 97
        slt     $t2, $t0, $t1               # $t2 = $t0 < 97
        bne     $t2, $zero, case_ge_65      # if $t2 != ('A'..'F') jump to case_ge_65
        addi    $t0, $t0, -87               # else calculate decimal value of big hex character
        j       inc

case_ge_65:
        addi    $t1, $zero, 65              # set $t1 = 65
        slt     $t2, $t0, $t1               # $t2 = $t0 < 65
        bne     $t2, $zero, case_decimal    # if $t2 != ('a'..'f') jump to case_decimal
        addi    $t0, $t0, -55               # else calculate decimal value of small hex character
        j       inc

case_decimal:
        addi    $t0, $t0, -48               # calculate decimal value of decimal character

inc:
        sll     $v0, $v0, 4                 # multiply current sum by 16
        addu    $v0, $v0, $t0               # add calculated value of character
        addi    $a0, $a0, 1                 # move pointer $a0 to next character
        j       loop_hex                        # loop

done:
        jr      $ra                         # return
        
        ###############################
        #          DEVIDE             #
        ###############################
division:
	sw	$s0, saven($0) 		#saven(0) = numerator
	move	$a1, $s1		# a1 = denominator   mau
	lw	$a0, saven($0)		# a0 = numerator   tu

	jal 	divide

	la 	$t0, saven
	sw 	$v1, 0($t0)
	sw 	$v0, 4($t0)

	la 	$a0, end1
	li 	$v0, 4
	syscall
	la 	$t0, saven
	lw 	$a0, 4($t0)
	beq	$t9, 2, print_hex_1
	li 	$v0, 1
	syscall
	la 	$a0, end2
	li 	$v0, 4
	syscall
	la 	$t0, saven
	lw 	$a0, 0($t0)
	li 	$v0, 1
	syscall
	li 	$v0, 10
	syscall
print_hex_1:
	li	$v0, 34
	syscall
	la 	$t0, saven
	lw 	$a0, 4($t0)
	la 	$a0, end2
	li 	$v0, 4
	syscall
	la 	$t0, saven
	lw 	$a0, 0($t0)
	li 	$v0, 34
	syscall
	li 	$v0, 10
	syscall
divide:	
	beq 	$a1, $0, dbze 	# tried to divide by 0
	subi 	$sp, $sp, 8 	# make room for 2 registers on stack
	sw 	$s0, 0($sp) 	# save $s0 to stack
	sw 	$s1, 4($sp) 	# save $s1 to stack
	move 	$s0, $a0 	# numerator
	move 	$s1, $a1 	# denominator
	addi 	$sp, $sp, -4 	# make room for 1 register on stack
	sw 	$ra, 0($sp) 	# save $ra to stack
	jal 	msb		# get n
	lw 	$ra, 0($sp) 	# load $ra from the stack
	addi 	$sp, $sp 4 	# remove space for register
	move 	$t0, $v0 	# n
	li 	$t1, 0 		# quotient
	li 	$t2, 0 		# remainder
divl:	addi 	$t0, $t0, -1 	# n = n - 1
	bltz 	$t0, divr 	# if n == -1, we're done
	sll 	$t2, $t2, 1 	# Shift R left one
	li 	$t3, 1 		# store 1
	and 	$t4, $t3, $t2 	# mask AND R -> LSB
	sllv 	$t3, $t3, $t0 	# move mask into position
	and 	$t3, $s0, $t3 	# mask AND N -> mask
	srlv 	$t3, $t3, $t0 	# move mask back
	beq 	$t3, $t4, endif # check if they're already equal
	xor 	$t2, $t3, $t2 	# flip LSB if they're not
endif:	blt 	$t2, $s1, divl 	# skip if R < D
	sub 	$t2, $t2, $s1 	# R = R - D
	li 	$t3, 1 		# create mask
	sllv 	$t3, $t3, $t0 	# shift mask by n places
	or 	$t1, $t1, $t3 	# Set nth bit of Quotient to 1
	j 	divl 		# restart loop
divr:	move 	$v0, $t1 	# prepare to return quotient
	move 	$v1, $t2 	# prepare to return remainder
	lw 	$s1, 4($sp) 	# retrieve original $s1
	lw 	$s0, 0($sp) 	# retrieve original $s0
	addi 	$sp, $sp, 8 	# remove stack space
	jr 	$ra 		# return

msb:	move 	$t0, $a0 	# store argument for work
	li 	$t1, 0 		# prepare i
msbl:	beqz 	$t0, msbr 	# end the loop
	srl 	$t0, $t0, 1 	# shift $t0 right
	addi 	$t1, $t1, 1 	# increment i
	j 	msbl 		# restart loop
msbr:	move 	$v0, $t1 	# prepare to return
	jr 	$ra 		# return

dbze:	li 	$v0, 4 		# load print string syscall
	la 	$a0, err 	# load err to be printed
	syscall 		# print err
	li 	$v0, 10 	# load terminate syscall
	syscall 		# terminate
