.data
    inputModePromt: .asciiz "Input mode (0 for decimal input and 1 for hexadecimal input): "
    operationModePromt: .asciiz "operation mode (0 for multiplication input and 1 for division): "
    productPromt: .asciiz "Product: "
    quotientPromt: .asciiz "Quotient: "
    remainderPromt: .asciiz "Remainder: "
    getNumberPromt: .asciiz "Number: "
    faultPromt: .asciiz "The input is incorrect \n"
    endl: .asciiz "\n"
    hexMem: .space 9
    all1: .word 0xffffffff

.text
getInputMode:
    # Ask for mode
    li $v0, 4 
    la $a0, inputModePromt
    syscall
    li $v0, 5 
    syscall
    addi $s0, $v0, 0

    # Change mode accordingly
    beqz $s0, decInput
    beq $s0, 1, hexInput
    # Incorrect mode, loop back to until getting the right input mode
    j getInputMode

# Decimal input mode
decInput:
    li $v0, 4 
    la $a0, getNumberPromt
    syscall
    li $v0, 5
    syscall
    xori $s2, $v0, 0

    li $v0, 4 
    la $a0, getNumberPromt
    syscall
    li $v0, 5
    syscall
    xori $s3, $v0, 0
   
    j getOperationMode

# Hexadecimal input mode
hexInput:
    jal getHexNumber
    xori $s2, $v0, 0
    jal getHexNumber
    xori $s3, $v0, 0

    j getOperationMode

getOperationMode:
    # Ask for mode
    li $v0, 4 
    la $a0, operationModePromt
    syscall
    li $v0, 5 
    syscall
    addi $s1, $v0, 0

    xori $a0, $s2, 0
    xori $a1, $s3, 0

    # Change mode accordingly
    sll $s0, $s0, 1
    add $s0, $s0, $s1
    # 00: dec-mul, 01: dec-div, 10: hex-mul, 11: hex-div
    beq $s0, 0, toMul
    beq $s0, 1, toDiv
    beq $s0, 2, toMulu
    beq $s0, 3, toDivu
    # Incorrect mode, loop back to until getting the right operation mode
    j getOperationMode

toMul:
    jal mul

    xori $a0, $v0, 0
    li $v0, 1
    syscall

    j endProgram

toDiv:
    jal div

    xori $a0, $v0, 0
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, endl
    syscall

    li $v0, 1
    xori $a0, $v1, 0
    syscall
    j endProgram

toMulu:
    jal mulu

    xori $a0, $v0, 0
    li $v0, 1
    syscall
    
    j endProgram
    
toDivu:
    jal divu

    xori $a0, $v0, 0
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, endl
    syscall

    li $v0, 1
    xori $a0, $v1, 0
    syscall
    j endProgram


getHexNumber:
    li $v0, 4 
    la $a0, getNumberPromt
    syscall
    la $a0, hexMem
    addi $a1, $zero, 10 
    li $v0, 8 
    syscall

    li $v0, 0
    li $t1, 0
    # get value from string
    getHexLoop:
        lb $t0, hexMem($t1)
        addi $t1, $t1, 1
        beq $t0, 10,endGetHexLoop
        beq $t0, '0', char0
        beq $t0, '1', char1
        beq $t0, '2', char2
        beq $t0, '3', char3
        beq $t0, '4', char4
        beq $t0, '5', char5
        beq $t0, '6', char6
        beq $t0, '7', char7
        beq $t0, '8', char8
        beq $t0, '9', char9
        beq $t0, 'a', charA
        beq $t0, 'A', charA
        beq $t0, 'b', charB
        beq $t0, 'B', charB
        beq $t0, 'c', charC
        beq $t0, 'C', charC
        beq $t0, 'd', charD
        beq $t0, 'D', charD
        beq $t0, 'e', charE
        beq $t0, 'E', charE
        beq $t0, 'f', charF
        beq $t0, 'F', charF
        j fault
    endGetHexLoop:

    jr $ra

    # Convert from char to int
    char0:
        sll $v0, $v0, 4
        addiu $v0, $v0, 0
        j getHexLoop
    char1:
        sll $v0, $v0, 4
        addiu $v0, $v0, 1
        j getHexLoop
    char2:
        sll $v0, $v0, 4
        addiu $v0, $v0, 2
        j getHexLoop
    char3:
        sll $v0, $v0, 4
        addiu $v0, $v0, 3
        j getHexLoop
    char4:
        sll $v0, $v0, 4
        addiu $v0, $v0, 4
        j getHexLoop
    char5:
        sll $v0, $v0, 4
        addiu $v0, $v0, 5
        j getHexLoop
    char6:
        sll $v0, $v0, 4
        addiu $v0, $v0, 6
        j getHexLoop
    char7:
        sll $v0, $v0, 4
        addiu $v0, $v0, 7
        j getHexLoop
    char8:
        sll $v0, $v0, 4
        addiu $v0, $v0, 8
        j getHexLoop
    char9:
        sll $v0, $v0, 4
        addiu $v0, $v0, 9
        j getHexLoop
    charA:
        sll $v0, $v0, 4
        addiu $v0, $v0, 10
        j getHexLoop
    charB:
        sll $v0, $v0, 4
        addiu $v0, $v0, 11
        j getHexLoop
    charC:
        sll $v0, $v0, 4
        addiu $v0, $v0, 12
        j getHexLoop
    charD:
        sll $v0, $v0, 4
        addiu $v0, $v0, 13
        j getHexLoop
    charE:
        sll $v0, $v0, 4
        addiu $v0, $v0, 14
        j getHexLoop
    charF:
        sll $v0, $v0, 4
        addiu $v0, $v0, 15
        j getHexLoop
        
    # Check fault for hexInput
    fault:
        li $v0, 4 
        la $a0, faultPromt
        syscall
        j getHexNumber

mul:
    ori $t0, $a0, 0
    ori $t1, $a1, 0
    ori $t2, $zero, 32
    ori $t3, $zero, 1
    ori $t5, $zero, 0

    beqz $t0, mulEnd
    beqz $t1, mulEnd
    mulLoop:
        and $t4, $t3, $t1
        beqz $t4, mulLoopNoAdd
        addu $t5, $t5, $t0

        mulLoopNoAdd:
        subi $t2, $t2, 1
        sll $t0, $t0, 1
        sll $t3, $t3, 1
        beqz $t2, mulEnd
    j mulLoop

mulEnd:
    ori $v0, $t5, 0
    ori $t0, $v0, 0
    jr $ra

mulu:
    j mul

div:
    # save $s0 and $ra to stack.
    subi $sp, $sp, 8
    sw $s0, 8($sp)
    sw $ra, 4($sp)
    
    lw $t2, all1

    # turn a into positive.
    slt $t0, $a0, $zero
    beq $t0, 0, sd_pos_a
    # sub $a0, $zero, $a0
    xor $a0, $a0, $t2
    addiu $a0, $a0, 1
    sd_pos_a:

    # turn b into positive.
    slt $t1, $a1, $zero
    beq $t1, 0, sd_pos_b
    # sub $a1, $zero, $a1
    xor $a1, $a1, $t2
    addiu $a1, $a1, 1
    sd_pos_b:

    # calculate the sign of q.
    xor $s0, $t0, $t1

    jal divu

    # give q the right sign.
    beq $s0, 0, divSignQ
    # sub $v0, $zero, $v0
    lw $t2, all1
    subiu $v0, $v0, 1
    xor $v0, $v0, $t2
    divSignQ:

    # get $s0 and $ra from stack then return.
    lw $s0, 8($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra

divu:
    # i = t0 = 0
    li $t0, 0
    # r = q = 0
    li $v0, 0
    li $v1, 0

    # while i < 32:
    divuLoop:
        beq $t0, 32, divuLoopEnd

        # r = r*2 + a[i]
        srl $t1, $a0, 31
        sll $v1, $v1, 1
        addu $v1, $v1, $t1

        # t = $t0 = (r >= b)
        sge $t1, $v1, $a1
        # q = q*2 + t
        sll $v0, $v0, 1
        addu $v0, $v0, $t1

        # if t > 0: r -= b
        beq $t1, 0, divuLoopNoSub
        subu $v1, $v1, $a1

        divuLoopNoSub:
        # ++i, a <<= 1
        addi $t0, $t0, 1
        sll $a0, $a0, 1
        j divuLoop
    divuLoopEnd:

    jr $ra

endProgram:
