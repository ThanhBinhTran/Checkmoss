.data
	Intro: .asciiz "Please enter the mode!:\nMode=0 corresponds to computation in decimal, Mode=1 corresponds to computation in hexadecimal\n"
	getA:    .asciiz "Please enter the first dec-format number (multiplicand and dividend):"
        getB:    .asciiz "Please enter the second dec-format number (multiplier and divisor):"
        thuong:	 .asciiz "\nQuotient of division in hexadecimal:"
        du: .asciiz "\nReminder of division in hexadecimal: "
        bitcao: .asciiz "\nUpper 32 bits"
	bitthap: .asciiz "\nLower 32 bits:"
	introResultMUL: .asciiz "\n Result of multiplication in decimal:"        
	integerArray: .word 0:64
	am: .asciiz "-"
	Error: .asciiz "\n Invalid division! Divisor can't equal zero \n"
	enterA: .asciiz "Please enter the first hex-format number (multiplicand and dividend) with full 8 bits: "
	enterB: .asciiz "Please enter the second hex-format number (multiplier and divisor) with full 8 bits: "
	multiplicationResult: .asciiz "Result of multiplication in hexadecimal: "
	numberA: .asciiz "00000000"
	numberB: .asciiz "00000000"
	dectoHexResult: .asciiz "00000000"
	enter: .asciiz "\n"
	cantDivide: .asciiz "Invalid division! Divisor can't equal zero"
	divideQuotient: .asciiz "Quotient of division in hexadecimal: "
	divideReminder: .asciiz "Reminder of division in hexadecimal: "
	hexHead: .asciiz "0x"
.text
main:	
	#introduction
	li  $v0,4           
    	la  $a0,Intro       
    	syscall
    	
    	li  $v0,5           
    	syscall             
    	add  $t7,$v0,$0
    	beq $t7,1,playWithHex
	#computation in decimal
    	PlayWithDEC:  
	#Enter the first dec-format number and save on $s0 
	li  $v0,4           
    	la  $a0,getA        
    	syscall             
    	li  $v0,5           
    	syscall             
    	add $s0,$v0,$0 
    	
    	#Enter the second dec-format number and save on $s1
    	li  $v0,4           
    	la  $a0,getB        
    	syscall             
    	li  $v0,5           
    	syscall             
    	add  $s1,$v0,$0
    	
    	#Check for positive and negative numbers 
    	#Assign sign of $s0 to $t0
    	#Assign absolute value of $s0 to $t0 
    	slt $t0,$s0,$0
    	beq $t0,1,resolve_$s0
    	j END_Check_$s0
    	resolve_$s0:
    		sub $s0,$0,$s0
    	END_Check_$s0:
    	
    	
    	#Assign sign of $s0 to $t0
    	#Assign absolute value of $s0 to $t0 
    	slt $t1,$s1,$1
    	beq $t1,1,resolve_$s1
    	j END_Check_$s1
    	resolve_$s1:
    		sub $s1,$0,$s1
    	END_Check_$s1:
    	
    	#Division of two unsigned number
    	addu $a0,$s0,$0
    	addu $a1,$s1,$0
    	#Call Division function
    	jal DIV
    	#Print result of division
    	j Print_RESULT_DIV
    	BackInDEC:

  	#Multiplication of two unsigned number  	
      	addu $a0,$s0,$0
    	addu $a1,$s1,$0
    	#Call Multiplication function
    	jal Multiply
    	
 	#32 higher bits is assigned to $s2
 	#32 lower bits is assigned to $s3
    	addu $s2,$v0,$0
    	addu $s3,$v1,$0
    	#Print result of multiplication
    	li  $v0,4           
    	la  $a0,introResultMUL   
    	syscall
    	j Print_RESULT_MUL
    	# End program
    	j END_GAME
    	
    	DIV:
    	#Store all registers of division function in stack 
    	addi $sp, $sp, -4
    	sw $s2,0($sp)
    	addi $sp, $sp, -4
    	sw $s3,0($sp)
    	addi $sp, $sp, -4
    	sw $t3,0($sp)
    	addi $sp, $sp, -4
    	sw $t4,0($sp)
    	addi $sp, $sp, -4
    	sw $t5,0($sp)
    	addi $sp, $sp, -4
    	sw $t6,0($sp)
    	#32 higher bits is assigned to $s2
    	#32 lower bits is assigned to $s3
    	#Result=(Remainder,Quotient)
    	#initialization
    	#Quotient=0
    	#Remainder=the dividend
    	addu $s2,$0,$0
    	addu $s3,$0,$a0
    	#$t3=0 ; count variable
    	addu $t3,$0,$0

    	DO_division:
    		#Check condition
    		
    		slti $t4,$t3,32
    		addu $t3,$t3,1
    		bne $t4,1,END_DO_division
    		
    		#shift result to the left one bit
    		srl $t5,$s3,31
    		sll $s3,$s3,1
    		sll $s2,$s2,1
    		or $s2,$s2,$t5
    		#If remainder more than or equal to divisor, lowest bit of quotient is assigned to 1
    		#else jum Do_division
    		slt $t6,$s2,$a1
    		beq $t6,1,DO_division
    		sub $s2,$s2,$a1
    		or $s3,$s3,1
    		j DO_division
    	END_DO_division:
	
       	addu $v0,$s3,$0 #quotient
    	addu $v1,$s2,$0 #remainder
    	
	#get back the value for the stack
	lw $t6,0($sp)
    	addi $sp, $sp, 4
    	lw $t5,0($sp)
    	addi $sp, $sp, 4
    	lw $t4,0($sp)
    	addi $sp, $sp, 4
    	lw $t3,0($sp)
    	addi $sp, $sp, 4
    	lw $s3,0($sp)
    	addi $sp, $sp, 4
    	lw $s2,0($sp)
    	addi $sp, $sp, 4
    	jr $ra
    	
    	#Multiplication function
    	Multiply:
    		#Store all registers of division function in stack 
    		addi $sp, $sp, -4
    		sw $s2,0($sp)
    		addi $sp, $sp, -4
    		sw $s3,0($sp)
    		addi $sp, $sp, -4
    		sw $t3,0($sp)
    		addi $sp, $sp, -4
    		sw $t4,0($sp)
    		addi $sp, $sp, -4
    		sw $t5,0($sp)
    		addi $sp, $sp, -4
    		sw $t6,0($sp)
    		# multiplicand=$a0
    		# multiplier=$a1
    		#32 higher bits is assigned to $s2=$a0
    		#32 lower bits is assigned to $s3=$a1
    		#result=($s2,$s3)
    		addu $s2,$0,$0
    		addu $s3,$0,$a1
    		# $t3=0 count variable
    		addu $t3,$0,$0
    		DO_Multiply:
    			#check condition
    			slti $t4,$t3,32
    			addi $t3,$t3,1
    			bne $t4,1,End_Multiply
    			#if the lowest bit of result is 0, i shift only result to the left one bit
    			#else i calculate new result=old result+the multiplicand and shift result to the left one bit
    			and $t5,$s3,1
    			beq $t5,0,dich
    			addu $s2,$s2,$a0
    			dich:
    				#convert result = (31 bits, 31 bits) (demonstration in the report)
    				and $t6,$s2,1
    				sll $t6,$t6,31
    				srl $s2,$s2,1
    				srl $s3,$s3,1
    				or $s3,$s3,$t6	
    			j DO_Multiply
    		End_Multiply:
    		
    		addu $v0,$s2,$0 #32 higher bits 
    		addu $v1,$s3,$0 #32 lower bit
		#get back the value for the stack
    		lw $t6,0($sp)
    		addi $sp, $sp, 4
    		lw $t5,0($sp)
    		addi $sp, $sp, 4
    		lw $t4,0($sp)
    		addi $sp, $sp, 4
    		lw $t3,0($sp)
    		addi $sp, $sp, 4
    		lw $s3,0($sp)
    		addi $sp, $sp, 4
    		lw $s2,0($sp)
    		addi $sp, $sp, 4
    		jr $ra
    		
    	Print_RESULT_DIV:
    		#Print result of division
    		
    		#determine sign of quotient and remainder
    		#sign of quotient=(sign of dividend) xor (sign of divisor)=$t3
    		#sign of remainder=(sign of quotient) xor (sign of divisor)=$t4
    		
    		addu $s2,$v0,$0
    		addu $s3,$v1,$0
    		xor $t3,$t0,$t1 
    		xor $t4,$t1,$t3
    		#if divisor is equal zero, i throw error
    		beq $s1,0,Exception
    		j Next_print_div	
    		Exception:
    			li  $v0,4           
    			la  $a0,Error      
    			syscall
    			j BackInDEC
    		Next_print_div:
    			
    		
		#print value of quotient (sign and absolute value)
    		li  $v0,4           
    		la  $a0,thuong      
    		syscall
    		beq $s2,0,End_print_sign_$s0 
    		beq $t3,1,Print_sign_$s0
    		j End_print_sign_$s0
    		Print_sign_$s0:
    			li  $v0,4           
    			la  $a0,am      
    			syscall
    		End_print_sign_$s0:	
    		li  $v0,1           
    		add  $a0,$s2,$0      
    		syscall 
    		
    		
    		#print value of remainder (sign and absolute value)
    		
    		li  $v0,4           
    		la  $a0,du      
    		syscall
    		beq $s3,0,End_print_sign_$s1
    		beq $t4,1,Print_sign_$s1
    		j End_print_sign_$s1
    			Print_sign_$s1:
    				li  $v0,4           
    				la  $a0,am      
    				syscall
    		End_print_sign_$s1:
    		li  $v0,1          
    		addu  $a0,$s3,$0    
    		syscall
    		#back main function to print result of multiplication
    		j BackInDEC
    		
    	Print_RESULT_MUL:
    		#$s2: 32 higher bits
    		#$s3: 32 lower bits 
    		#convert result to form (31 bits,31 bits) (demonstration in the report)
    		srl $t5,$s3,31
    		sll $s2,$s2,1
    		sll $s3,$s3,1
    		srl $s3,$s3,1
    		or $s2,$s2,$t5
    		#$t5 is count variable of result to store value into array
    		addu $t5,$0,$0 
    		la $s7,integerArray
    		DO_Sep:
    			#performs division by 32 higher bits			
    			addu $a0,$0,$s2
    			addiu $a1,$0,10
    			
    			jal DIV
    			addu $s2,$v0,$0 #quotient of 32 higher bits
    			addu $t7,$v1,$0 #remainder of 32 higher bits
    			
    			#performs division by 32 higher bits	
    			addu $a0,$0,$s3
    			addiu $a1,$0,10
    		
    			jal DIV
    			addu $s3,$v0,$0 #quotient of 32 lower bits
    			addu $s4,$v1,$0 #remainder of 32 lower bits
    			
    			
    			#move $t8,$v0 #thuong cua 2^31/10
    			#move $t9,$v1 #du cua 2^31/10
    			#When i divide 2^31 into 10
    			#quotient:214748364
    			#remainder:8
    			addiu $t8,$0,214748364
    			addiu $t9,$0,8
			#$t6=0 is count variable
       			addiu $t6,$0,0
       			#calculate K=(remainderof 32 higher bits + remainders of 32 lower bits)/10
       			#quotient of K is added into $s3 (quotient of 32 lower bits)
    			DO_SUM:
    				sltu $t4,$t6,$t7
    				bne $t4,1,END_DO_SUM
    				addu $t6,$t6,1 
    				addu $s3,$s3,$t8
    				addu $s4,$s4,$t9
    				j DO_SUM
    			END_DO_SUM:
    			
    			addu $a0,$0,$s4
    			addiu $a1,$0,10
    			jal DIV
    			addu $s3,$s3,$v0
    			add $s4,$v1,$0
    			
    			
   			#save result into arry $s7
    			
    			sw $s4,0($s7)
    			addi $s7,$s7,4
    			addiu $t5,$t5,4
    			
			#if $s2==0 and $s3==0, i break loop
    			bne $s2,$0,DO_Sep
    			bne $s3,$0,DO_Sep
    			j END_SEP
    		END_SEP:
    		Print_MUL:
    			#print result of multiplication
    			beq $s0,0,DO_Print_MUL
    			beq $s1,0,DO_Print_MUL
    			#print sign of result
    			xor $t8,$t0,$t1
    			beq $t8,1,Print_sign_RES_MUL
    			#if result==0, i don't need print sign of result
    			j End_print_sign_RES_MUL
    			Print_sign_RES_MUL:
    				li  $v0,4           
    				la  $a0,am      
    				syscall
    			End_print_sign_RES_MUL:
    		DO_Print_MUL:

    			#print value in array (absolute value)
    			slt $t4,$0,$t5
    			bne $t4,1,END_GAME
    			subi $t5,$t5,4
    			subi $s7,$s7,4
    			lw $t6,0($s7)
    			li  $v0,1         
			add  $a0,$t6,$0
			syscall 
			#back main function
			j DO_Print_MUL
    			
    		j END_GAME
    	j END_GAME
    	
    	playWithHex:
		#read A
	addi $v0, $zero, 4
	la $a0, enterA
	syscall
  
  	addi $v0, $zero, 8
  	la $a0, numberA
  	addi $a1, $zero, 9
  	syscall
  	
  	addi $v0, $zero, 4
  	la $a0, enter
  	syscall
	#Convert A into Dec
	la $a0, numberA
	jal fromHexaStringToDecimal
	add $s0, $v0, $zero
	
	#read B
	addi $v0, $zero, 4
	la $a0, enterB
	syscall
	
	addi $v0, $zero, 8
	la $a0, numberB
	addi $a1, $zero, 9
	syscall
	
	addi $v0, $zero, 4
  	la $a0, enter
  	syscall
	#Convert B into Dec
	la $a0, numberB
	jal fromHexaStringToDecimal
	add $s1, $v0, $zero

	#Multiply
	add $a0, $s0, $zero
	add $a1, $s1, $zero
	jal multiplyHex
	add $t7, $v0, $zero
	add $t8, $v1, $zero
	
	#print multiply result
	addi $v0, $zero,4
	la $a0, multiplicationResult
	syscall
	addi $v0, $zero, 4
  	la $a0, hexHead
  	syscall
	add $a0, $t7, $zero
	jal  fromDecimalToHexa
	addi $v0, $zero, 4
	la $a0, dectoHexResult
	syscall
	add $a0, $t8, $zero
	jal  fromDecimalToHexa
	addi $v0, $zero, 4
	la $a0, dectoHexResult
	syscall
	
	addi $v0, $zero, 4
  	la $a0, enter
  	syscall
	#Divide 
	beqz $s1, invalidDivision
	add $a0, $s0, $zero
	add $a1, $s1, $zero
	jal divideHex
	add $t0, $v0, $zero
	add $t9, $v1, $zero
	addi $v0, $zero,4
	la $a0, divideQuotient
	syscall
	addi $v0, $zero, 4
  	la $a0, hexHead
  	syscall
	add $a0, $t0, $zero
	jal  fromDecimalToHexa
	addi $v0, $zero, 4
	la $a0, dectoHexResult
	syscall
	addi $v0, $zero, 4
  	la $a0, enter
  	syscall
  	addi $v0, $zero,4
	la $a0, divideReminder
	syscall
	addi $v0, $zero, 4
  	la $a0, hexHead
  	syscall
	add $a0, $t9, $zero
	jal  fromDecimalToHexa
	addi $v0, $zero, 4
	la $a0, dectoHexResult
	syscall
	j exitProgramme
	
	invalidDivision:
	addi $v0, $zero, 4
	la $a0, cantDivide
	syscall
	
	exitProgramme:
	addi $v0, $zero, 10
	syscall
	
	
fromHexaStringToDecimal:
   	 # start counter
    	addi   $t8, $zero,, 1                      # start our counter
   	 addi   $v0, $zero, 0                      # output number
   	 j    hexaStringToDecimalLoop

	hexaStringToDecimalLoop:
    		lb   $t7, 0($a0)
   		ble  $t7, '9', inputSub48       # if t7 less than or equal to char '9' inputSub48
    		addi $t7, $t7, -55              # convert from string (ABCDEF) to int
    		j    inputHexaNormalized
    		
		inputHexaNormalized:
    			blt  $t7, $zero, convertHexaStringToDecimalFinish  # print int if t7 < 0
   			sll  $v0, $v0, 4              # t8 = t8 * t6
    			add  $v0, $v0, $t7              # add t7 to v0
    			addi $a0, $a0, 1                # increment array position
   			 j    hexaStringToDecimalLoop

		inputSub48:
   			 addi $t7, $t7, -48              # convert from string (ABCDEF) to int
   			 j    inputHexaNormalized
	convertHexaStringToDecimalFinish:
	jr $ra

	

multiplyHex:
	add $v0, $zero, $zero
	add $v1, $a1, $zero
	addi $t0, $zero, 32
	li $s2, 0

	multiplyHexLoop:
		beqz $t0, doneMultiplyHex
		andi $t1, $v1, 1
		bnez $t1, if_m0equal1
		beqz $s2, if_qEqual0
		add $v0, $v0, $a0
		
		if_qEqual0:
			j exit_MultiplyHexIf
		if_m0equal1:
			bnez $s2, if_qEqual1
			sub $v0, $v0, $a0
		if_qEqual1:
		exit_MultiplyHexIf:
			add $s2, $t1, $zero
			andi $t2, $v0, 1
			sll $t2, $t2, 31
			sra $v0, $v0, 1
			srl $v1, $v1, 1
			or $v1, $v1, $t2
			addi $t0, $t0, -1
			j multiplyHexLoop
	doneMultiplyHex:
	jr $ra


fromDecimalToHexa:
	addi $t0, $0, 8 # Counter
	la $t3, dectoHexResult
	
	decimalToHexaLoop:
		beqz $t0, convertDecimalToHexaFinish # Branch to exit if counter is equal to zero
		srl $t1, $a0, 28 # $t1 dong vai tro la thanh ghi da dung
		sll $a0, $a0, 4
		or $a0, $a0, $t1 # rotate 4 bits to the left
		and $t4, $a0, 0xf # mask with 1111
		addi $t1, $t4, -1
		slti $t1, $t1, 9
		beq $t1, 1, decimalToHexaSum # if less than or equal to nine, branch to sum
		addi $t4, $t4, 55 # if greater than 9 , add 55
		
		j decimalToHexaEnd
		
		decimalToHexaSum:
			addi $t4, $t4, 48 #add 48 to result
			
		decimalToHexaEnd:
			sb $t4, 0($t3) # store hex digit into result
			addi $t3, $t3, 1 # increment address counter
			addi $t0, $t0, -1 # decrement loop counter
		j decimalToHexaLoop
	convertDecimalToHexaFinish:
	jr $ra

divideHex:
    	srl $t8, $a0, 31
	srl $t9, $a1, 31
	beqz $t8, ifDividendPositive
		sub $a0, $zero, $a0
		beqz $t9, ifDivisorPositive0
			sub $a1, $zero, $a1
			add $t8, $zero, $zero
			addi $t9, $zero, 1
			j exitIfDivideHex
		ifDivisorPositive0:
			addi $t8, $zero, 1
			addi $t9, $zero, 1
		      	j exitIfDivideHex
	ifDividendPositive:
		beqz $t9, ifDivisorPositive1
			sub $a1, $zero, $a1
			addi $t8, $zero, 1
			add $t9, $zero, $zero
			j exitIfDivideHex
		ifDivisorPositive1:
			add $t8, $zero, $zero
			add $t9, $zero, $zero
	exitIfDivideHex:
    	addu $s2,$0,$0
    	addu $s3,$0,$a0
    	#$t3=0 ; count variable
    	addu $t3,$0,$0
 
    	DivisionHexLoop:
    		#Check condition
 
    		slti $t4,$t3,32
    		addu $t3,$t3,1
    		bne $t4,1,ExitDivisionHexLoop
 
    		#shift result to the left one bit
    		srl $t5,$s3,31
    		sll $s3,$s3,1
    		sll $s2,$s2,1
    		or $s2,$s2,$t5
    		#If remainder more than or equal to divisor, lowest bit of quotient is assigned to 1
    		#else jum DivisionHexLoop
    		slt $t6,$s2,$a1
    		beq $t6,1,DivisionHexLoop
    		sub $s2,$s2,$a1
    		or $s3,$s3,1
    		j DivisionHexLoop
    	ExitDivisionHexLoop:
 
       	addu $v0,$s3,$0 #quotient
    	addu $v1,$s2,$0 #remainder
    	beqz $t8, ifQuotientPositive
		sub $v0, $zero, $v0
	ifQuotientPositive:
	beqz $t9, ifReminderPositive
		sub $v1, $zero, $v1
	ifReminderPositive:
	jr $ra
END_GAME:
