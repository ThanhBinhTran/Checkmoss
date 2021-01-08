.data 
    welcome:    .asciiz "Hi, you. Do you want to multiply or divide two numbers? \nIf multiply, please enter 'm'. Otherwise, please enter 'd': "
    operation:  .space 3
    dec_hex:    .asciiz "\nNumbers: decimal or hexadecimal?\nIf decimal, please enter 'd'. Otherwise, please enter 'h': "
    dh:         .space 3
    wrong_answer: .asciiz "\nSorry, no exit this operation"
    space:      .asciiz " "
    newline:    .asciiz "\n"
    a_input:       .asciiz "\nEnter the first dec number: "
    b_input:       .asciiz "\nEnter the second dec number: "
    result:     .asciiz "\nProduct of two numbers is: "
    a_hex_input:       .asciiz "\nEnter the first hex number: "
    b_hex_input:        .asciiz "\nEnter the second hex number: "
    quotient:   .asciiz "\nQuotient is: "
    remainder:  .asciiz "\nRemainder is: "
    buffer:     .space 10
    messWrongDivide: .asciiz "\nThe division can't execute because the divisor is equal to 0"
.text
    #In loi chao
    li	$v0, 4
    la	$a0, welcome
    syscall
    #Nhap nhan hoac chia
    li	$v0, 8
    la	$a0, operation
    addi	$a1, $0, 3
    move	$t0, $a0
    syscall
            
    lb	$t1, 0($t0)
    #Xet truong input nhan hoac chia
    beq	$t1, 'm', caseM
    beq	$t1, 'd', caseD
    li	$v0, 4
    la	$a0, wrong_answer
    syscall
    j	Exit_program

    #Truong hop chon phep nhan
    caseM:
    li	$v0, 4
	la	$a0, dec_hex
	syscall
	
	li	$v0, 8
	la	$a0, dh
	addi	$a1, $0, 3
	move	$t0, $a0
	syscall
	
	lb	$t1, 0($t0)
	
	beq	$t1, 'd', decM
	beq	$t1, 'h', hexM
	li	$v0, 4
	la	$a0, wrong_answer
	syscall
	j	Exit_program
        
        # phep nhan
        # Ham multiply co cac tham so la:
        #  * $a2: so nhan
        #  * $a3: so bi nhan
	multiply: # Gia tri tra ve la $v1
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		li	$s7, 0
		slti	$t5, $a2, 0
		beq	$t5, 1, opposite
		j	continue
		opposite: sub $a2, $0, $a2
		continue:
		# Truyen tham so $a1 vao ham getSumBits
		move	$a1, $a2
		jal	getSumBits1
		addi	$t6, $v1, 1
		li	$t7, 1			# i = 0
		mloop:				# for (int i = 0; i < v1; i++)
			slt	$t3, $t7, $t6
			beq	$t3, 1, mif
			j	mExit
			mif:
				# Tryen tham so $a1 vao ham getRemainder
				move	$a1, $a2
				jal	getRemainder
				beq	$v1, 1, addtos7		
				j	DTP
				addtos7: add	$s7, $s7, $a3   # Neu t1 = 1, cong don thanh ghi so nhan vao thanh ghi tich
				DTP: srl $a2, $a2, 1		# Dich phai 1 bit thanh ghi so nhan
				sll	$a3, $a3, 1		# Dich trai 1 bit thanh ghi so bi nhan
				addi	$t7, $t7, 1
				j	mloop
		mExit:
		beq	$t5, 1, opposite1
		j	continue1
		opposite1: sub $s7, $0, $s7
		continue1:
	
		move	$v1, $s7
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr	$ra

	# Lay bit cuoi cung
	# Hma getRemainder co cac tham so la:
	#   * $a1: so nhan
	getRemainder: # Gia tri tra ve la $v1
		andi	$t0, $a1, 1
		move	$v1, $t0
		jr	$ra

	# Tinh so lan lap	
	# Ham getSumBits1 co cac tham so la:
	#   * $a1: so nhan
	getSumBits1: # Gia tri tra ve la $v1
		move	$t3, $a1
		li	$t0, 0
		Loop1:
		beq	$t3, $0, Exit1
		srl	$t3, $t3, 1
		addi	$t0, $t0, 1
		j	Loop1
		Exit1:
		li	$t2, 0
		for:
			slt	$t4, $t2, $t0
			beq	$t4, 0, forExit
			addi	$t2, $t2, 4
			j	for
			forExit:
			move	$v1, $t2
		jr	$ra
        
        #phep nhan voi so thap phan
        decM:
	#Nhap vao so a
	li	$v0, 4
	la	$a0, a_input
	syscall
	
	li	$v0, 5
	syscall
	move	$s0, $v0
	
	
	#Nhap vao so b
	li	$v0, 4
	la	$a0, b_input
	syscall
	
	li	$v0, 5
	syscall
	move	$s1, $v0
        
        move	$a2, $s0
	move	$a3, $s1
	jal	multiply
	# In ra tich hai so
	li	$v0, 4
	la	$a0, result
	syscall
	
	li	$v0, 1
	addi	$a0, $v1, 0
	syscall	
	j	Exit_program
        # Phep nhan voi so hex
        hexM:
        li	$v0, 4
        la	$a0, a_hex_input
        syscall
        
        li	$v0, 8
        la	$a0, a_hex_input
        li	$a1, 10
        syscall
        
        move	$a1, $a0
        jal	getTheNumOfSys
        move	$a2, $v1
        jal	convert_hex_to_dec
        move	$s0, $v1
        
        li	$v0, 4
        la	$a0, b_hex_input
        li	$a1, 10
        syscall
        
        li	$v0, 8
        la	$a0, a_hex_input
        syscall
        
        move	$a1, $a0
        jal	getTheNumOfSys
        move	$a2, $v1
        jal	convert_hex_to_dec
        move	$s1, $v1
        
        move	$a2, $s0
        move	$a3, $s1
        jal	multiply
        # In ra tich hai so
		li	$v0, 4
		la	$a0, result
		syscall
	
		li	$v0, 34
		addi	$a0, $v1, 0
		syscall	
		j	Exit_program
            #truong hop chon phep chia    
            caseD:
            #chon kieu nhap hex hay dec
            li	$v0, 4
            la	$a0, dec_hex
            syscall
            
            li	$v0, 8
            la	$a0, dh
            addi	$a1, $0, 3
            move	$t0, $a0
            syscall
            
            lb	$t1, 0($t0)
            
            beq	$t1, 'd', decD
            beq	$t1, 'h', hexD
            li	$v0, 4
            la	$a0, wrong_answer
            syscall
            j	Exit_program    
                #phep chia voi so thap phan
                decD:
                    #nhap so thu nhat
                    li $v0, 4
                    la $a0, a_input
                    syscall

                    li $v0, 5
                    syscall
                    move $a2, $v0

                    #nhap so thu hai
                    li $v0, 4
                    la $a0, b_input
                    syscall

                    li $v0, 5
                    syscall
                    move $s1, $v0
		    
		    #neu so chia = 0
		    beq $s1, $0, wrongDivide
		    j calculateDivide1
		    wrongDivide:
		    li $v0, 4
		    la $a0, messWrongDivide
		    syscall
		    j Exit_program  
		    
		    calculateDivide1:		
                    #bien dem kiem tra so nhap vao la so am 
                    slt $t8, $a2, $0
                    slt $t9, $s1, $0
                    #neu SBC < 0 => chuyen SBC sang > 0
                    beq $t8, 0, checkDivisor
                    #chuyen SBC sang > 0
                    sub $a2, $0, $a2
                    checkDivisor:
                        #neu SC < 0 => chuyen SC sang > 0
                        beq $t9, 0, calculate_divide2
                        #chuyen SC sang > 0
                        sub $s1, $0, $s1

                    calculate_divide2:
                    move $a1, $s1
                    jal getSumBits
                    move $s3, $v1
                    #khoi tao thuong va luu vao thanh ghi $s0
                    add $s0, $0, $0

                    #truyen argument cho ham divide
                    move $a1, $s1
                    move $a3, $s3
                    #goi ham chia
                    jal divide

                    #chuyen gia tri thuong vao $s0
                    move $s0, $v0
                    #chuyen gia tri so du vao $s1
                    move $s1, $v1

                    #gan lai gtri thuong va so du voi cac truong hop so am
                    #neu so bi chia < 0
                    beq $t8, $0, dividendGreaterThan0
                        #neu so chia < 0
                        beq $t9, $0, A
                            #so du < 0
                            sub $s1, $0, $s1
                            j printDivideResult
                        #so chia > 0
                        A:
                            #thuong > 0; so du > 0
                            sub $s0, $0, $s0
                            sub $s1, $0, $s1
                            j printDivideResult
                    dividendGreaterThan0:
                    #neu so chia < 0
                    beq $t9, $0, printDivideResult
                            #thuong < 0
                            sub $s0, $0, $s0
                            j printDivideResult
                    printDivideResult:
                    li $v0, 4
                    la $a0, quotient
                    syscall

                    li $v0, 1
                    move $a0, $s0
                    syscall

                    li $v0, 4
                    la $a0,remainder
                    syscall

                    li $v0, 1
                    move $a0, $s1
                    syscall
                    j Exit_program
                #phep chia voi so thap luc phan    
                hexD:
                li	$v0, 4
                la	$a0, a_hex_input
                syscall
                
                li	$v0, 8
                la	$a0, buffer
                li	$a1, 10
                syscall
                
                move	$a1, $a0

                #kiem tra bit cuoi co la 1 khong?
                jal checkSign
                move $t8, $v1
                #lay tong ki tu
                jal	getTheNumOfSys
                move	$a2, $v1
                addi $t7, $0, 8
                #neu khong co 8 ki tu hexa
                bne $a2, $t7, begin_convertHex1
                #neu co 8 ki tu hexa, kiem tra bit cuoi co la 1 khong
                beq $t8, $0, begin_convertHex1
                j begin_convertHex2

                begin_convertHex1:
                jal	convert_hex_to_dec
                move	$s7, $v1
                j input_hex_2

                begin_convertHex2:
                jal	convert_hex_to_dec
                move	$s7, $v1
                addi $s7, $s7, -1
                nor $s7, $s7, $0
                sub $s7, $0, $s7
                input_hex_2:
                #------------------
                li	$v0, 4
                la	$a0, b_hex_input
                syscall
                
                li	$v0, 8
                la	$a0, buffer
                li	$a1, 10
                syscall
                
                move	$a1, $a0
                #kiem tra bit cuoi co la 1 khong?
                jal checkSign
                move $t8, $v1

                jal	getTheNumOfSys
                move	$a2, $v1
                addi $t7, $0, 8

                #neu khong co 8 ki tu hexa
                bne $a2, $t7, begin_convertHex3
                #neu co 8 ki tu hexa, kiem tra bit cuoi co la 1 khong
                beq $t8, $0, begin_convertHex3
                j begin_convertHex4

                begin_convertHex3:
                jal	convert_hex_to_dec
                move	$s1, $v1
                move $a2, $s7
                j C

                begin_convertHex4:
                jal	convert_hex_to_dec
                move	$s1, $v1
                addi $s1, $s1, -1
                nor $s1, $s1, $0
                sub $s1, $0, $s1

                move $a2, $s7

                #neu so chia = 0
            C:
		    beq $s1, $0, wrongDivide
		    j calculateDivide2
		    
		    calculateDivide2:		
                    #bien dem kiem tra so nhap vao la so am 
                    slt $t8, $a2, $0
                    slt $t9, $s1, $0
                    #neu SBC < 0 => chuyen SBC sang > 0
                    beq $t8, 0, checkDivisor1
                    #chuyen SBC sang > 0
                    sub $a2, $0, $a2
                    checkDivisor1:
                        #neu SC < 0 => chuyen SC sang > 0
                        beq $t9, 0, calculate_divide3
                        #chuyen SC sang > 0
                        sub $s1, $0, $s1

                    calculate_divide3:
                    move $a1, $s1
                    jal getSumBits
                    move $s3, $v1
                    #khoi tao thuong va luu vao thanh ghi $s0
                    add $s0, $0, $0

                    #truyen argument cho ham divide
                    move $a1, $s1
                    move $a3, $s3
                    #goi ham chia
                    jal divide

                    #chuyen gia tri thuong vao $s0
                    move $s0, $v0
                    #chuyen gia tri so du vao $s1
                    move $s1, $v1

                    #gan lai gtri thuong va so du voi cac truong hop so am
                    #neu so bi chia < 0
                    beq $t8, $0, dividendGreaterThan0_1
                        #neu so chia < 0
                        beq $t9, $0, B
                            #so du < 0
                            sub $s1, $0, $s1
                            j printDivideResult1
                        #so chia > 0
                        B:
                            #thuong > 0; so du > 0
                            sub $s0, $0, $s0
                            sub $s1, $0, $s1
                            j printDivideResult1
                    dividendGreaterThan0_1:
                    #neu so chia < 0
                    beq $t9, $0, printDivideResult1
                            #thuong < 0
                            sub $s0, $0, $s0
                            j printDivideResult1
                    printDivideResult1:
                    li $v0, 4
                    la $a0, quotient
                    syscall

                    li $v0, 34
                    move $a0, $s0
                    syscall

                    li $v0, 4
                    la $a0,remainder
                    syscall

                    li $v0, 34
                    move $a0, $s1
                    syscall
                    j Exit_program

        #-----------------------
        #Ham lay tong so byte  cua chuoi Hex
        #Argument:- $a1:dia chi cua chuoi da nhap 
        getTheNumOfSys:
        #bien luu ket qua
            addi $t0, $0, 0
            for_count_sys:
                add $t1, $a1, $t0
                lb $t2, 0($t1)
                beq $t2, '\0', exit_count_syss
                addi $t0, $t0, 1
                j for_count_sys
            exit_count_syss:
            #gia tri tra ve trong thanh ghi $v1
            addi $v1, $t0, -1
            jr $ra
        #---------------------

        #----------------------------------------------
        #Ham chuyen tu he thap luc phan sang thap phan, ket qua tra ve tai $v1
        #Argument: $a1:  dia chi chuoi da nhap
        #          $a2: tong byte cua chuoi
        convert_hex_to_dec:
            #thanh ghi $s5 luu ket qua
            add $s5, $0, $0
            #bien chay vong for lon
            addi $t1, $0, -1
            for_traverse:
                addi $t1, $t1, 1
                beq $t1, $a2, exit_travere
                addi $t6, $a2, -1
                #lay dia chi cua $s0 + i
                add $t2, $a1, $t1
                #lay ki tu
                lb $t3, 0($t2)
                #so lan dich trai 4 bit la 1 neu bit do khong phai la bit co trong so thap nhat
                addi $t4, $0, 1
                #bat dau switch case
                bne $t3, '0', case_1
                    addi $s5, $s5, 0
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bit0:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bit0
                #1
                case_1:
                bne $t3, '1', case_2
                    addi $s5, $s5, 1
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bit1:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bit1        
                #2
                case_2:
                bne $t3, '2', case_3
                    addi $s5, $s5, 2
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bit2:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bit2
                #3
                case_3:
                bne $t3, '3', case_4
                    addi $s5, $s5, 3
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bit3:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bit3
                case_4:
                bne $t3, '4', case_5
                    addi $s5, $s5, 4
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bit4:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bit4        
                case_5:
                bne $t3, '5', case_6
                    addi $s5, $s5, 5
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bit5:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bit5
                case_6:
                bne $t3, '6', case_7
                    addi $s5, $s5, 6
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bit6:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bit6
                case_7:
                bne $t3, '7', case_8
                    addi $s5, $s5, 7
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bit7:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bit7
                case_8:
                bne $t3, '8', case_9
                    addi $s5, $s5, 8
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bit8:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bit8
                case_9:
                bne $t3, '9', case_A
                    addi $s5, $s5, 9
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bit9:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bit9
                case_A:
                bne $t3, 'A', case_B
                    addi $s5, $s5, 10
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bitA:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bitA
                case_B:
                bne $t3, 'B', case_C
                    addi $s5, $s5, 11
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bitB:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bitB
                case_C:
                bne $t3, 'C', case_D
                    addi $s5, $s5, 12
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bitC:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bitC
                case_D:
                bne $t3, 'D', case_E
                    addi $s5, $s5, 13
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bitD:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bitD
                case_E:
                bne $t3, 'E', case_F
                    addi $s5, $s5, 14
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bitE:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bitE
                case_F:
                    addi $s5, $s5, 15
                    beq $t1, $t6, for_traverse
                    #bien duyet
                    addi $t5, $0, 0
                    for_shift_bitF:
                        beq $t5, $t4, for_traverse
                        sll $s5, $s5, 4
                        addi $t5, $t5, 1
                        j for_shift_bitF
            exit_travere:
            #Ket qua tra ve luu vo thanh ghi $v1
            add $v1, $s5, $0
            jr $ra    
        #-----------------------------------------

#Ham divide thuc hien phep chia, gia tri thuong luu trong $v0, gia tri so du luu trong $v1
#Argument:- $a2: so bi chia
#         - $a1: so chia
#         - $a3: tong bit cua so chia
divide:
    #bien tam $t0 = 0
    #dich trai thanh ghi so chia
        add $t0, $0, $0
        for_shift_left:
            beq $t0, $a3, exit_for_shift_left
            sll $a1, $a1, 1
            addi $t0, $t0, 1
        j for_shift_left

    exit_for_shift_left:
    #khoi tao so lan chay vong lap, luu vao $t7
    addi $t7, $0, -1
    for_START:
        beq $t7, $a3, exit_for_START
        #STEP1: tru thanh ghi so du voi thanh ghi so chia, luu vao so chia
        sub $a2, $a2, $a1
        #STEP2: kiem tra so du, luu ket qua so sanh vao $t0
        slt $t0, $a2, $0
        beq $t0, $0, step_3_2
            #STEP3.1: So du < 0
            #Cong thanh ghi so du voi so chia, luu vao so du
            add $a2, $a2, $a1
            #Dich trai thanh ghi thuong 1 bit
            sll $s0, $s0, 1
            j step_4
        #STEP 3.2:
        step_3_2:
            #Dich trai thanh ghi thuong 1 bit va chinh bit thap nhat thanh 1
            sll $s0, $s0, 1
            addi $s0, $s0, 1
            j step_4
        step_4:
        #Dicch phaii 1 bit thanh ghi so chia
        srl $a1, $a1, 1
        #tang bien dem $t7 len 1
        addi $t7, $t7, 1
    j for_START
    exit_for_START:
    #luu thuong vo $v0
    move $v0, $s0
    #luu so du vo $v1
    move $v1, $a2
    jr $ra
#--------------------
#Ham checkSign kiem tra bit cuoi co phai la 1 khong
#ARgument: $a1: dia chi cua chuoi
checkSign:
    lb $t1, 0($a1)
    beq $t1, '8', result_checkSign
    beq $t1, '9', result_checkSign
    beq $t1, 'A', result_checkSign
    beq $t1, 'B', result_checkSign
    beq $t1, 'C', result_checkSign
    beq $t1, 'D', result_checkSign
    beq $t1, 'E', result_checkSign
    beq $t1, 'F', result_checkSign
    addi $v1, $0, 0
    jr $ra
    result_checkSign:
    addi $v1, $0, 1
    jr $ra

#Ham getSumBits lay tong so bit cua so chia
#Argument: $a1: gia tri so chia    
getSumBits:
    #luu thanh ghi so chia vao $t0
    addi $t0, $a1, 0
    #$t1 de luu ket qua, $t2 luu ket qua chinh thuc
    add $t1, $0, $0
    add $t2, $0, $0
#vong lap dem tong so bit trong thanh ghi so chia
    for_count:
        beq $t0, $0, exit_for_count
        addi $t1, $t1, 1
        srl $t0, $t0, 1
        j for_count
    exit_for_count:
    #lay tong bit ma chia het cho 4
    for_bit_greater4:
        slt $t3, $t2, $t1
        beq $t3, $0, return_sumBits
        addi $t2, $t2, 4
        j for_bit_greater4
    return_sumBits:
    #luu ket qua vo $v1
    move $v1, $t2
jr $ra

Exit_program:
    li $v0, 10
    syscall
