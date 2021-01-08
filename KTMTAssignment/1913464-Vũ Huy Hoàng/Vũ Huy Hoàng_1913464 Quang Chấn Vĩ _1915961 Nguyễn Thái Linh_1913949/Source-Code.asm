#  Data Area
.data

welcome:
	.asciiz " \n\n Main Menu:"

option1:
	.asciiz " \n 1 - Multiplication"
	
option2:
	.asciiz " \n 2 - Division"
	
option1.1:
	.asciiz " \n 1 - Hexadecimal Input"

option1.2:
	.asciiz " \n 2 - Decimal Input"
	
option2.1:
	.asciiz " \n 1 - Hexadecimal Input"

option2.2:
	.asciiz " \n 2 - Decimal Input"
	
fill1: 
	.asciiz " \n\n Enter the task number you wish to perform :"
	
fill2.1: 
	.asciiz " \n\n Enter the input method number you wish to perform on Multiplication: "
		
fill2.2: 
	.asciiz " \n\n Enter the input method number you wish to perform on Division: "
	
error:
	.asciiz " \n Invalid input"
	
exit:
	.asciiz " \n Exitting program"		


input_ins: 	.space 9
endLine:	.asciiz "\n"
dec_result: 	.asciiz "The Decimal number is: "	


getA.1:    	.asciiz "Please enter the first Hexadecimal number(multiplicand): "
getB.1:    	.asciiz "Please enter the second Hexadecimal number(multiplier): "
getA.2:    	.asciiz "Please enter the first Decimal number(multiplicand): "
getB.2:    	.asciiz "Please enter the second Decimal number(multiplier): "
space:    	.asciiz " "
result:    	.asciiz "The product is: "
resultDiv:    	.asciiz "The quotinent is: "


getC.1:    	.asciiz "Please enter the first Hexadecimal number(dividend): "
getD.1:    	.asciiz "Please enter the second Hexadecimal number(divisor): "
getC.2:    	.asciiz "Please enter the first Decimal number(dividend): "
getD.2:    	.asciiz "Please enter the second Decimal number(divisor): "
remainder:    .asciiz "The reminder is: "			
#Text Area
.text

 	addi		$v0, $0, 4		# System call code: print string
	la		$a0, welcome		# Label welcome is printed
	syscall
	la		$a0, option1		# Label option1 is loaded and printed
	syscall
	la		$a0, option2		# Label option2 is loaded and printed
	syscall
	la		$a0, fill1		# Label prompt is loaded and printed
	syscall
	addi		$v0, $0, 5		# System call code: read integer
	syscall
	
	addi		$t0, $0, 1		# $t0 = 1
	addi		$t1, $0, 2		# $t1 = 2

	beq     	$v0, $t0, Multiplication		# if (user input == 1)
	beq    		$v0, $t1, Division	# if (user input == 2)

	blt		$v0, $t1, PRINTERROR
	bgt		$v0, $t4, PRINTERROR
	j		EXIT

Multiplication:

	addi		$v0, $0, 4		# System call code: print string
	la		$a0, option1.1		# Label welcome is printed
	syscall
	la		$a0, option1.2		# Label welcome is printed
	syscall
	la		$a0, fill2.1		# Label prompt is loaded and printed
	syscall
	addi		$v0, $0, 5		# System call code: read integer
	syscall
	
	addi		$t0, $0, 1		# $t0 = 1
	addi		$t1, $0, 2		# $t1 = 2

	beq     	$v0, $t0, Multiplication_Hex	# if (user input == 1)
	beq    		$v0, $t1, Multiplication_Dec	# if (user input == 2)

	blt		$v0, $t1, PRINTERROR
	bgt		$v0, $t4, PRINTERROR
	j		EXIT
	
Division:	
	addi		$v0, $0, 4		# System call code: print string
	la		$a0, option2.1		# Label welcome is printed
	syscall
	la		$a0, option2.2		# Label welcome is printed
	syscall
	la		$a0, fill2.2		# Label prompt is loaded and printed
	syscall
	addi		$v0, $0, 5		# System call code: read integer
	syscall
	
	
	addi		$t0, $0, 1		# $t0 = 1
	addi		$t1, $0, 2		# $t1 = 2

	beq     	$v0, $t0, Division_Hex	# if (user input == 1)
	beq    		$v0, $t1, Division_Dec	# if (user input == 2)

	blt		$v0, $t1, PRINTERROR
	bgt		$v0, $t4, PRINTERROR
	j		EXIT
	
Multiplication_Hex:

	li $v0, 4 
	la $a0, endLine
	syscall 
	
runner1.1:
	li $v0, 4 
	la $a0, getA.1
	syscall 
	
        la 	$a0, input_ins 		# Get address to store string
	addi 	$a1, $0, 9 		# Input 9 characters into string (includes ’\n’)
	li 	$v0, 8 			# Set reading String mode
	syscall	
	la 	$s1, input_ins

run_test1.1:
        move    $a0, $s1                # move address of input str to a0
        jal     hex_convert1.1             # call subroutine under test
        move    $v1, $v0                # move return value in v0 to v1 because we need v0 for syscall
        j       print1.1

#   Function hex_convert
hex_convert1.1:
        and     $v0, $v0, $zero             # make sure $v0 == 0

loop1.1:
        lb      $t0, 0($a0)                 # read next character
        beq     $t0, $zero, done1.1           # if NULL, jump to done
        beq     $t0, 10, done1.1		    # if '\n', jumpto done

case_ge_971.1:
        addi    $t1, $zero, 97              # set $t1 = 97
        slt     $t2, $t0, $t1               # $t2 = $t0 < 97
        bne     $t2, $zero, case_ge_651.1      # if $t2 != ('A'..'F') jump to case_ge_65
        addi    $t0, $t0, -87               # else calculate decimal value of big hex character
        j       inc1.1

case_ge_651.1:
        addi    $t1, $zero, 65              # set $t1 = 65
        slt     $t2, $t0, $t1               # $t2 = $t0 < 65
        bne     $t2, $zero, case_decimal1.1    # if $t2 != ('a'..'f') jump to case_decimal
        addi    $t0, $t0, -55               # else calculate decimal value of small hex character
        j       inc1.1

case_decimal1.1:
        addi    $t0, $t0, -48               # calculate decimal value of decimal character

inc1.1:
        sll     $v0, $v0, 4                 # multiply current sum by 16
        addu    $v0, $v0, $t0               # add calculated value of character
        addi    $a0, $a0, 1                 # move pointer $a0 to next character
        j       loop1.1                        # loop

done1.1:
        jr      $ra                         # return

print1.1:		
	li $v0, 4 
	la $a0, dec_result
	syscall 
	
	add $a0, $0, $v1 # Assign an integer to a0
	li $v0, 1 # Print integer a0
	syscall
	# put the Multiplicand into $s0
	add $s0, $0, $0
	add $s0, $s0, $a0

	li $v0, 4 
	la $a0, endLine
	syscall 
	
	li $v0, 4 
	la $a0, endLine
	syscall 
runner1.2:
	li $v0, 4 
	la $a0, getB.1
	syscall 
	
        la 	$a0, input_ins 		# Get address to store string
	addi 	$a1, $0, 9 		# Input 9 characters into string (includes ’\n’)
	li 	$v0, 8 			# Set reading String mode
	syscall	
	la 	$s1, input_ins

run_test1.2:
        move    $a0, $s1                # move address of input str to a0
        jal     hex_convert1.2          # call subroutine under test
        move    $v1, $v0                # move return value in v0 to v1 because we need v0 for syscall
        j       print1.2

#   Function hex_convert
hex_convert1.2:
        and     $v0, $v0, $zero             # make sure $v0 == 0

loop1.2:
        lb      $t0, 0($a0)                 # read next character
        beq     $t0, $zero, done1.2           # if NULL, jump to done
        beq     $t0, 10, done1.2		    # if '\n', jumpto done

case_ge_971.2:
        addi    $t1, $zero, 97              # set $t1 = 97
        slt     $t2, $t0, $t1               # $t2 = $t0 < 97
        bne     $t2, $zero, case_ge_651.2      # if $t2 != ('A'..'F') jump to case_ge_65
        addi    $t0, $t0, -87               # else calculate decimal value of big hex character
        j       inc1.2

case_ge_651.2:
        addi    $t1, $zero, 65              # set $t1 = 65
        slt     $t2, $t0, $t1               # $t2 = $t0 < 65
        bne     $t2, $zero, case_decimal1.2    # if $t2 != ('a'..'f') jump to case_decimal
        addi    $t0, $t0, -55               # else calculate decimal value of small hex character
        j       inc1.2

case_decimal1.2:
        addi    $t0, $t0, -48               # calculate decimal value of decimal character

inc1.2:
        sll     $v0, $v0, 4                 # multiply current sum by 16
        addu    $v0, $v0, $t0               # add calculated value of character
        addi    $a0, $a0, 1                 # move pointer $a0 to next character
        j       loop1.2                        # loop

done1.2:
        jr      $ra                         # return

print1.2:		

	
	li $v0, 4 
	la $a0, dec_result
	syscall 
	
	add $a0, $0, $v1 # Assign an integer to a0
	li $v0, 1 # Print integer a0
	syscall
	# put the Multiplicand into $s1
	add $s1, $0, $0
	add $s1, $s1, $a0
	
	li $v0, 4 
	la $a0, endLine
	syscall 
	
	li $v0, 4 
	la $a0, endLine
	syscall 
    
    add $a0 , $0, $0	
    add $t0 , $0, $0
    add $s3 , $0, $0
    add $s2 , $0, $0
    add $t9 , $0, $0
    add $t8 , $0, $0				
    addi $t8, $t8, 32
    jal MyMultMult1
    j   printMult1

MyMultMult1:
    move $s3, $0        #  product


    beq $s1, $0, doneMult1
    beq $s0, $0, doneMult1

	#s0 :so bi nhan
	#s1: so nhan	
	
    move $s2, $0        # extend multiplicand to 64 bits

loopMult1:
    andi $t0, $s1, 1    # LSB(multiplier)
    beq $t0, $0, nextMult1   # skip if zero
    addu $s3, $s3, $s0  # (product) += (multiplicand)

nextMult1:
    sll $s0, $s0, 1
    srl $s1, $s1, 1     # shift multiplier right
    addi $t9, $t9, 1
    bne $t9, $t8, loopMult1
doneMult1:
    jr $ra

printMult1:
    # print result string
    li  $v0,4           # code for print_string
    la  $a0,result      # point $a0 to string
    syscall             # print the result string

    # print out the result
    li  $v0,1           # code for print_int
    move    $a0,$s3     # put result in $a0
    syscall             # print out result

    # print the line feed
    li  $v0,4           # code for print_string
    la  $a0,endLine     # point $a0 to string
    syscall             # print the linefeed
    j EXIT
	
Multiplication_Dec:

	li $v0, 4 
	la $a0, endLine
	syscall 
	
    #prompt for multiplicand
    li  $v0,4           # code for print_string
    la  $a0,getA.2        # point $a0 to prompt string
    syscall             # print the prompt

    #acquire multiplicand
    li  $v0,5           # code for read_int
    syscall             # get an int from user --> returned in $v0
    move    $s0,$v0     # move the resulting int to $s0

    #prompt for multiplier
    li  $v0,4           # code for print_string
    la  $a0,getB.2        # point $a0 to prompt string
    syscall             # print the prompt

    #acquire multiplier
    li  $v0,5           # code for read_int
    syscall             # get an int from user --> returned in $v0
    move    $s1,$v0     # move the resulting int to $s0
    
    addi $t8, $t8, 32
    jal MyMultMult2
    j   printMult2
MyMultMult2:
    move $s3, $0        # product


    beq $s1, $0, doneMult2
    beq $s0, $0, doneMult2

	#s0: so bi nhan
	#s1: so nhan	
	
    move $s2, $0        # extend multiplicand to 64 bits

loopMult2:
    andi $t0, $s1, 1    # LSB(multiplier)
    beq $t0, $0, nextMult2   # skip if zero
    addu $s3, $s3, $s0  # (product) += (multiplicand)

nextMult2:
    sll $s0, $s0, 1
    srl $s1, $s1, 1     # shift multiplier right
    addi $t9, $t9, 1
    bne $t9, $t8, loopMult2
doneMult2:
    jr $ra

printMult2:
    # print result string
    li  $v0,4           # code for print_string
    la  $a0,result      # point $a0 to string
    syscall             # print the result string

    # print out the result
    li  $v0,1           # code for print_int
    move    $a0,$s3     # put result in $a0
    syscall             # print out result

    # print the line feed
    li  $v0,4           # code for print_string
    la  $a0,endLine     # point $a0 to string
    syscall             # print the linefeed
    j EXIT

Division_Hex:

runner2.1:
	li $v0, 4 
	la $a0, getC.1
	syscall 
	
        la 	$a0, input_ins 		# Get address to store string
	addi 	$a1, $0, 9 		# Input 9 characters into string (includes ’\n’)
	li 	$v0, 8 			# Set reading String mode
	syscall	
	la 	$s1, input_ins

run_test2.1:
        move    $a0, $s1                # move address of input str to a0
        jal     hex_convert2.1             # call subroutine under test
        move    $v1, $v0                # move return value in v0 to v1 because we need v0 for syscall
        j       print2.1

#   Function hex_convert
hex_convert2.1:
        and     $v0, $v0, $zero             # make sure $v0 == 0

loop2.1:
        lb      $t0, 0($a0)                 # read next character
        beq     $t0, $zero, done2.1           # if NULL, jump to done
        beq     $t0, 10, done2.1		    # if '\n', jumpto done

case_ge_972.1:
        addi    $t1, $zero, 97              # set $t1 = 97
        slt     $t2, $t0, $t1               # $t2 = $t0 < 97
        bne     $t2, $zero, case_ge_652.1      # if $t2 != ('A'..'F') jump to case_ge_65
        addi    $t0, $t0, -87               # else calculate decimal value of big hex character
        j       inc2.1

case_ge_652.1:
        addi    $t1, $zero, 65              # set $t1 = 65
        slt     $t2, $t0, $t1               # $t2 = $t0 < 65
        bne     $t2, $zero, case_decimal2.1    # if $t2 != ('a'..'f') jump to case_decimal
        addi    $t0, $t0, -55               # else calculate decimal value of small hex character
        j       inc2.1

case_decimal2.1:
        addi    $t0, $t0, -48               # calculate decimal value of decimal character

inc2.1:
        sll     $v0, $v0, 4                 # multiply current sum by 16
        addu    $v0, $v0, $t0               # add calculated value of character
        addi    $a0, $a0, 1                 # move pointer $a0 to next character
        j       loop2.1                       # loop

done2.1:
        jr      $ra                         # return

print2.1:		
	li $v0, 4 
	la $a0, dec_result
	syscall 
	
	add $a0, $0, $v1 # Assign an integer to a0
	li $v0, 1 # Print integer a0
	syscall
	# put the Multiplicand into $s0
	add $s0, $0, $0
	add $s0, $s0, $a0

	li $v0, 4 
	la $a0, endLine
	syscall 
	
	li $v0, 4 
	la $a0, endLine
	syscall 
runner2.2:
	li $v0, 4 
	la $a0, getD.1
	syscall 
	
        la 	$a0, input_ins 		# Get address to store string
	addi 	$a1, $0, 9 		# Input 9 characters into string (includes ’\n’)
	li 	$v0, 8 			# Set reading String mode
	syscall	
	la 	$s1, input_ins

run_test2.2:
        move    $a0, $s1                # move address of input str to a0
        jal     hex_convert2.2          # call subroutine under test
        move    $v1, $v0                # move return value in v0 to v1 because we need v0 for syscall
        j       print2.2

#   Function hex_convert
hex_convert2.2:
        and     $v0, $v0, $zero             # make sure $v0 == 0

loop2.2:
        lb      $t0, 0($a0)                 # read next character
        beq     $t0, $zero, done2.2           # if NULL, jump to done
        beq     $t0, 10, done2.2		    # if '\n', jumpto done

case_ge_972.2:
        addi    $t1, $zero, 97              # set $t1 = 97
        slt     $t2, $t0, $t1               # $t2 = $t0 < 97
        bne     $t2, $zero, case_ge_652.2      # if $t2 != ('A'..'F') jump to case_ge_65
        addi    $t0, $t0, -87               # else calculate decimal value of big hex character
        j       inc2.2

case_ge_652.2:
        addi    $t1, $zero, 65              # set $t1 = 65
        slt     $t2, $t0, $t1               # $t2 = $t0 < 65
        bne     $t2, $zero, case_decimal2.2    # if $t2 != ('a'..'f') jump to case_decimal
        addi    $t0, $t0, -55               # else calculate decimal value of small hex character
        j       inc2.2

case_decimal2.2:
        addi    $t0, $t0, -48               # calculate decimal value of decimal character

inc2.2:
        sll     $v0, $v0, 4                 # multiply current sum by 16
        addu    $v0, $v0, $t0               # add calculated value of character
        addi    $a0, $a0, 1                 # move pointer $a0 to next character
        j       loop2.2                        # loop

done2.2:
        jr      $ra                         # return

print2.2:		

	
	li $v0, 4 
	la $a0, dec_result
	syscall 
	
	add $a0, $0, $v1 # Assign an integer to a0
	li $v0, 1 # Print integer a0
	syscall
	# put the Multiplicand into $s1
	add $s1, $0, $0
	add $s1, $s1, $a0
	
	li $v0, 4 
	la $a0, endLine
	syscall 
	
	li $v0, 4 
	la $a0, endLine
	syscall 
    
    add $a0 , $0, $0	
    add $t0 , $0, $0
    add $s3 , $0, $0
    add $s2 , $0, $0
    add $t9 , $0, $0
    add $t8 , $0, $0				
    addi $t8, $t8, 17
    jal MyDiv1
    j   print1
MyDiv1:
    move $s3, $0        #  quotinent
    beq $s1, $0, done1
	
    move $s2, $0        # extend dividend to 64 bits
    sll $s1, $s1, 16
step1.1:
    sub $s0, $s0, $s1
    blt $s0, $0, step4.1   # skip if zero  
    sll $s3, $s3, 1
    xori $s3, $s3, 1
    j step5.1
step4.1:
    add $s0, $s0, $s1
    sll $s3, $s3, 1
step5.1:
    srl $s1, $s1, 1     
    addi $t9, $t9, 1
    bne $t9, $t8, step1.1
done1:
    jr $ra

print1:
    # print result string
    li  $v0,4           # code for print_string
    la  $a0,resultDiv   # point $a0 to string
    syscall             # print the result string

    li  $v0,4           # code for print_string
    la  $a0,space       # point $a0 to string
    syscall             # print the result string

    li  $v0,1           # code for print_int
    move    $a0,$s3     # put result in $a0
    syscall             # print out result

    # print the line feed
    li  $v0,4           # code for print_string
    la  $a0,endLine     # point $a0 to string
    syscall             # print the linefeed

    li  $v0,4           # code for print_string
    la  $a0,remainder   # point $a0 to string
    syscall             # print the result string
    
    li  $v0,4           # code for print_string
    la  $a0,space       # point $a0 to string
    syscall             # print the result string

    li  $v0,1           # code for print_int
    move    $a0,$s0     # put result in $a0
    syscall             # print out result

    j EXIT

Division_Dec:

	li $v0, 4 
	la $a0, endLine
	syscall 
	
    #prompt for multiplicand
    li  $v0,4           # code for print_string
    la  $a0,getC.2        # point $a0 to prompt string
    syscall             # print the prompt

    #acquire multiplicand
    li  $v0,5           # code for read_int
    syscall             # get an int from user --> returned in $v0
    move    $s0,$v0     # move the resulting int to $s0

    #prompt for multiplier
    li  $v0,4           # code for print_string
    la  $a0,getD.2        # point $a0 to prompt string
    syscall             # print the prompt

    #acquire multiplier
    li  $v0,5           # code for read_int
    syscall             # get an int from user --> returned in $v0
    move    $s1,$v0     # move the resulting int to $s0
    
    addi $t8, $t8, 17
    jal MyDiv2
    j   print2

	# $s0: so bi chia
	# $s1: so chia
	
MyDiv2:
    move $s3, $0        #  quotinent
    beq $s1, $0, done2
    beq $s0, $0, done2
	
    move $s2, $0        # extend dividend to 64 bits
    sll $s1, $s1, 16
step1.2:
    sub $s0, $s0, $s1
    blt $s0, $0, step4.2   # skip if zero  
    sll $s3, $s3, 1
    xori $s3, $s3, 1
    j step5.2
step4.2:
    add $s0, $s0, $s1
    sll $s3, $s3, 1
step5.2:
    srl $s1, $s1, 1     
    addi $t9, $t9, 1
    bne $t9, $t8, step1.2
done2:
    jr $ra

print2:
    # print result string
    li  $v0,4           # code for print_string
    la  $a0,resultDiv      # point $a0 to string
    syscall             # print the result string

    li  $v0,4           # code for print_string
    la  $a0,space       # point $a0 to string
    syscall             # print the result string

    li  $v0,1           # code for print_int
    move    $a0,$s3     # put result in $a0
    syscall             # print out result

    # print the line feed
    li  $v0,4           # code for print_string
    la  $a0,endLine     # point $a0 to string
    syscall             # print the linefeed

    li  $v0,4           # code for print_string
    la  $a0,remainder      # point $a0 to string
    syscall             # print the result string
    
    li  $v0,4           # code for print_string
    la  $a0,space       # point $a0 to string
    syscall             # print the result string

    li  $v0,1           # code for print_int
    move    $a0,$s0     # put result in $a0
    syscall             # print out result
    j EXIT

PRINTERROR:
	addi		$v0, $0, 4			# System call code: print string
	la		$a0, error			# Label error is loaded and printed
	syscall
	j		EXIT
	
EXIT:
	addi	$v0, $0, 4			# System call code: print string
	la	$a0, exit			# Label exit is loaded and printed
	syscall
	addi	$v0, , $0, 10		# Exit
	syscall	