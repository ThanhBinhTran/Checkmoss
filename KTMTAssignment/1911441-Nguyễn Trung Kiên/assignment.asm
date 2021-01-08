.data
# declare the variable lables of ASCII storage type.
prompt0: .asciiz"Enter mode number you want to caculate with\n"
prompt01: .asciiz "Enter 0 if numbers are Dec\n"
prompt02: .asciiz "Enter 1 if numbers are Hex\n"
prompt1: .asciiz "Enter number 1: "
prompt2: .asciiz "Enter number 2: "
result1: .asciiz "\nThe multiplication of two 31 bit binary numbers is: "
result2: .asciiz "\nand the upper part of result is: " 
result3: .asciiz "\n\nThe division of two 31 bit binary numbers is: "
result4: .asciiz "\nand the remainder is: " 
result5: .asciiz"\nERROR"
.text

mode:
	#prompt0.
        li $v0, 4   
        la $a0, prompt0
        syscall
        
	#prompt01.
        li $v0, 4   
        la $a0, prompt01
        syscall
        
	#prompt02.
        li $v0, 4   
        la $a0, prompt02
        syscall
        
        #read mode and store in the register $t0
        li $v0, 5        
        syscall  
        move $t0, $v0
        
checkmode:
 	bnez $t0, enterhex
 	j enterdec
 	
enterhex:
	 #prompt1.
        li $v0, 4   
        la $a0, prompt1
        syscall

        #read number(string) 1 and store in the register $t1
        addi $a1,$0,9 # hex number has 8 characters
        li $v0, 8        
        syscall  
        move $t1, $v0
        
        add $a0,$0,$t1 
        jal convert
	add $t1,$0,$v0
	
        #prompt2.
        li $v0, 4   
        la $a0, prompt2
        syscall

        #read number(string) 2 and store in the register $t2
        li $v0, 8        
        syscall  
        move $t2, $v0
        
        add $a0,$0,$t2 
        jal convert
        add $t2,$0,$v0
        
        j multiply
        
enterdec:
	#prompt1.
        li $v0, 4   
        la $a0, prompt1
        syscall

        #read number 1 and store in the register $t1
        li $v0, 5        
        syscall  
        move $t1, $v0

        #prompt2.
        li $v0, 4   
        la $a0, prompt2
        syscall

        #read number 2 and store in the register $t2
        li $v0, 5        
        syscall  
        move $t2, $v0	
        
        j multiply
		        
		        
		        
		        
		       
convert:
	addi $sp,$sp,-8     # Moving Stack pointer
	sw $t1,0($sp)
	sw $t2,4($sp)
	
	add $t0,$0,$a0
	
	li $t1,0X30
        li $t2,0x39

        andi $t1,$t1,0x000000ff #Cast to word for comparison.
        andi $t2,$t2,0x000000ff

        bltu $t0,$t1,ERROR     #error if lower than 0x30
        bgt $t0,$t2,dohex     #if greater than 0x39, test for A -F

        addiu $t0,$t0,-0x30     #OK, char between 48 and 55. Subtract 48.
        
        lw $t2, 4($sp)      # Load previous value
        lw $t1, 0($sp)
        addi $sp,$sp,8     # Moving Stack pointer 
        
        j return

dohex:  
	addi $sp,$sp,-8     # Moving Stack pointer
	sw $t1,0($sp)
	sw $t2,4($sp)
	
	li $t1,0x41
        li $t2,0x46

        andi $t1,$t1,0x000000ff #Cast to word for comparison.
        andi $t2,$t2,0x000000ff

        #/*is byte is between 65 and 70?*/

        bltu $t0,$t1,ERROR     #error if lower than 0x41
        bgt $t0,$t2,ERROR     #error if greater than 0x46
        
        lw $t2, 4($sp)      # Load previous value
        lw $t1, 0($sp)
        addi $sp,$sp,8     # Moving Stack pointer 

ishex:  
	addiu   $t0,$t0,-0x37     #subtract 55 from hex char ('A'- 'F')
        j return

ERROR:  
	addiu   $t0,$zero,-1      #return -1.

return: 
	move    $v0,$t0           #move return value to register v0
	jr $ra
	
	
	
multiply:

        li $t3, 0 # The final result of the multiplication is 64 bits
                  # MSB part is in register $t3
        li $t5, 0 #  and LSB part of result is in $t5
        li $t4, 1 # Mask for extracting bit!
        li $s1, 32 # set the Counter to 32 for loop.   
        
multiply1:
        and $s2, $t2, $t4
        beq $s2, 0, increment
        addu $t3, $t3, $t1

increment:
        sll $t4, $t4, 1 # update mask
        andi $s4, $t3,1  # save lsb of result
        srl $t3,$t3,1    # t3>>=1
        srl $t5,$t5,1    # t5>>=1
        sll $s4,$s4,31
        or  $t5,$t5,$s4  # reinject saved lsb of result in msb of $t5
        addi $s1, $s1, -1 # decrement loop counter
        #if the Counter $s1 reaches 0 then go the label exit
        beq $s1, $zero, exit
        j multiply1

exit:
        #display the result string.
        ## must be changed to take into account the 64 bits of the result
        ## but AFAIK, there is no syscall for that
        ## can be done in two steps t5 and t3
        ## and result is t4+2**32*t2
        #display the result value.
        li $v0, 4   
        la $a0, result1
        syscall
        
        li $v0, 1  # if using mars replace 1 by 36 to print as an unsigned
        add $a0, $t5, $zero
        syscall
        
        li $v0, 4   
        la $a0, result2
        syscall
        
        li $v0, 1 # if using mars replace 1 by 36 to print as an unsigned
        add $a0, $t3, $zero
        syscall


check1:
	srl $s1, $t1, 31
	beqz $s1, check2 #so duong
	subi $t1, $t1, 1
	not $t1, $t1
check2:
	srl $s2, $t2, 31
	beqz $s2, divide #so duong
	subi $t2, $t2, 1
	not $t2, $t2
divide:
	xor $s0, $s1, $s2 
	li $t3,0
	li $t4,31
	li $t5, 0x80000000
	li $t6,1
	
divide1:	
	addi $t4,$t4,-1
	and $t7,$t1,$t5
	sll $t1,$t1,1
	sll $t3,$t3,1
	bne $t7,$t5,minus
	or $t3, $t3, $t6
	
minus:	
	subu $t3,$t3,$t2
	and $t8,$t3,$t5
	bne $t8,$t5, changeLSB 
	addu $t3,$t3,$t2
	j checkmask
	
changeLSB:
	or $t1,$t1,$t6
	j checkmask
	
checkmask:
	bgez $t4, divide1

checklast:
	beqz $s0, display
	not $t1, $t1
	addi $t1, $t1, 1
	not $t3, $t3
	addi $t3, $t3, 1
display:
	li $v0, 4   
        la $a0, result3
        syscall
        
        li $v0, 1  # if using mars replace 1 by 36 to print as an unsigned
        add $a0, $t1, $zero
        syscall
        
        li $v0, 4   
        la $a0, result4
        syscall
        
        li $v0, 1 # if using mars replace 1 by 36 to print as an unsigned
        add $a0, $t3, $zero
        syscall
        
        j endprog

outprog:
	li $v0, 4   
        la $a0, result5
        syscall
	
endprog: