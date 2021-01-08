.data 
	arr: .word 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
	endl: .byte '\n'
	comma: .asciiz ", "
	.align 2
	temp: .space 40
.text
	la $a1, arr #start
	addi $a2, $a1, 76 #end = start + 4 * 19
	addi $sp, $sp, -8 #stack
	sw $a1, 0($sp) #save start to stack
	sw $a2, 4($sp) #save end to stack
	jal MERGE_SORT
	lw $a1, 0($sp)
	lw $a2, 4($sp) 
	j EXIT
RETURN:
	jr $ra	
	
MERGE_SORT:
	sub $t0, $a2, $a1 #end - start
	blez $t0, RETURN
	addi $t0, $t0, 4 #size
	addi $t1, $0, 8
	divu $t0, $t1 #size / 8
	mfhi $t2 #remainder
	mflo $t3 #mid
	bne $t2, 0, CONTINUE #t0 / 4 is not even
	addi $t3, $t3, -1 #t0 /4 is even -> mid - 1
CONTINUE:
	mul $t3, $t3, 4	#mid = mid * 4
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)
	sw $t3, 24($sp)
	add $a2, $a1, $t3
	
	jal MERGE_SORT	#mergeSort(start, start + mid);
	
	lw $ra, 0($sp)			
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	lw $t3, 24($sp)
	add $a1, $a1, $t3 #a1 = a1 + mid
	addi $a1, $a1, 4
	
	jal MERGE_SORT	#mergeSort(start + mid + 1, end);
	
	lw $ra, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	lw $t3, 24($sp)
	add $a3, $0, $a2 #end
	add $a2, $a1, $t3 #start + mid
	
	jal MERGE
	
	lw $ra, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	lw $t3, 24($sp)
	addi $sp, $sp, 28
	
	j RETURN
	
MERGE:
	sub $t0, $a2, $a1 #middle - left
	addi $t0, $t0, 4 #size_1
	addi $t1, $0, 0 #i
	add $t2, $a1, $0 #left
	la $t3, temp #half
FOR_LOOP:
	lw $t4, 0($t2)
	sw $t4, 0($t3)
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	addi $t3, $t3, 4
	slt $at, $t1, $t0 
	bne $at, $zero, FOR_LOOP #i < size_1
	add $t2, $a1, $0 #p = left
	la $t3, temp #p1 = half
	add $t5, $t3, $t0 #ep1 = half + size_1
	add $t6, $a2, 4 #p2 = mid + 1
	addi $t4, $a3, 4 #right + 1
	
WHILE_1:
	beq $t5, $t3, WHILE_2 #p1 != ep1
	beq $t4, $t6, WHILE_2 #p2 != right + 1
	lw $t7, 0($t3) #*p1
	lw $t8, 0($t6) #*p2
	slt $at, $t8, $t7 
	bne $at, $zero, IF_2
IF_1:
	sw $t7, 0($t2) #*p = *p1
	addi $t2, $t2, 4	#p++
	addi $t3, $t3, 4	#p1++
	j WHILE_1
IF_2:
	sw $t8, 0($t2) #*p = *p2
	addi $t2, $t2, 4	#p++
	addi $t6, $t6, 4	#p2++
	j WHILE_1
WHILE_2:
	beq $t5, $t3, WHILE_3 #p1 != ep1
	lw $t7, 0($t3) #t7 = *p1
	sw $t7, 0($t2) #*p = *p1
	addi $t2, $t2, 4	#p++
	addi $t3, $t3, 4	#p1++
	j WHILE_2
WHILE_3:
	beq $t4, $t6, PRINT #p2 != right + 1
	lw $t8, 0($t6)#t8 = *p2
	sw $t8, 0($t2) #*p = *p2
	addi $t2, $t2, 4	#p++
	addi $t6, $t6, 4	#p2++
	j WHILE_3
PRINT:
	sub $t9, $a3, $a1	#end - start
	addi $t9, $t9, 4	#end - start + 1
	addi $t1, $0, 0 #i
	add $t2, $a1, $0
FOR_PRINT:
	lw $a0, 0($t2)
	addi $v0, $0, 1
	syscall
	addi $t1, $t1, 4
	addi $t2, $t2, 4
	slt $at, $t1, $t9 
	beq $at, $zero, PRINT_ENDL
	la $a0, comma
	addi $v0, $0, 4
	syscall
	j FOR_PRINT
PRINT_ENDL:
	lb $a0, endl
	addi $v0, $0, 11
	syscall
	jr $ra
EXIT:
