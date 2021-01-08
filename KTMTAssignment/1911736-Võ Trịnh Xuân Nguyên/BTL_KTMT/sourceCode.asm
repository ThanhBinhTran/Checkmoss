.data
	prompt1: .asciiz "Day so ban dau la :\n"
	prompt2: .asciiz "Day so sau khi sap xep :\n"
	prompt3: .asciiz "MergeSort :\n"
	array: .word 250, 497, 40, 36, 234, 143, 172, 467, 115, 28, 66, 10, 375, 293, 243, 113, 482, 45, 442, 176
	n: .byte 20
.text
.globl main
main:
	# In day so ban dau
	la $a0, prompt1
	li $v0, 4
	syscall
	
	la $a0, array
	li $a1, 0
	lb $a2, n
	jal printArray

	la $a0, prompt3
	li $v0, 4
	syscall
	
	# mergeSort
	la $a0, array
	li $a1, 0
	lb $a2, n
	jal mergeSort
	
	la $a0, prompt2
	li $v0, 4
	syscall
	
	# in ket qua sau khi merge
	la $a0, array
	li $a1, 0
	lb $a2, n
	jal printArray
	
	# ket thuc chuong trinh
	li $v0, 10
	syscall
	
	# ham in day so ra man hinh
	# $a0 dia chi cua mang
	# $a1 start index
	# $a2 end index
printArray:
	addi $t0, $a0, 0
	addi $t1, $a1, 0
	sll $t2, $a1, 2
	add $t0, $t0, $t2
	
  Loop1:   
  	slt $t2, $t1, $a2
	beq $t2, $zero, endLoop1
	
	li $v0, 1
	lw $a0, 0($t0)
	syscall
	
	li $v0, 11
	addi $a0, $zero, 32
	syscall
	
	addi $t1, $t1, 1
	addi $t0, $t0, 4
	j Loop1
  endLoop1:
  	li $v0, 11
  	addi $a0, $zero, 10
  	syscall
  	
	jr $ra
	
	# mergeSort
	# $a0 dia chi cua mang
	# $a1 start index
	# $a2 end index
mergeSort:
	# if start index >= end index - 1 , return
	addi $t0, $a2, -1
	slt $t1, $a1, $t0
	beq $t1, $zero, return1
	
	# luu $s4-$s7 trong stack
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s4, 4($sp)
	sw $s5, 8($sp)
	sw $s6, 12($sp)
	sw $s7, 16($sp)
	
	addi $s5, $a0, 0
	addi $s6, $a1, 0
	addi $s7, $a2, 0

	add $s4, $a1, $a2
	div $s4, $s4, 2
	
	# mergeSort(array, start, mid)
	addi $a0, $s5, 0
	addi $a1, $s6, 0
	addi $a2, $s4, 0
	jal mergeSort
	
	# mergeSort(array, mid, end)
	addi $a0, $s5, 0
	addi $a1, $s4, 0
	addi $a2, $s7, 0
	jal mergeSort

	# merge(array, start, mid, end)
	addi $a0, $s5, 0
	addi $a1, $s6, 0
	addi $a2, $s4, 0
	addi $a3, $s7, 0
	jal merge
   	 
	addi $a0, $s5, 0
	addi $a1, $s6, 0
	addi $a2, $s7, 0
	
	# in ra mang sau khi merge
	jal printArray
	lw $s5, 8($sp)
   	lw $s6, 12($sp)
   	lw $s7, 16($sp)
   	lw $ra, 0($sp)
   	lw $s4, 4($sp)
   	addi $sp, $sp, 20
   return1:
	
   	jr $ra

	# merge
	# $a0 dia chi cua mang
	# $a1 start index
	# $a2 middle index
	# $a3 end index
merge:
	addi $t7, $a0, 0
	sub $t8, $a2, $a1
	sub $t9, $a3, $a2
	
	# khoi tao mang a1 kich thuoc (mid - start) * 4 bytes
	# a1[i] = array[i + start]
	li $v0, 9
	addi $a0, $t8, 0
	sll $a0, $a0, 2
	syscall
	addi $t6, $v0, 0
	
	addi $t0, $zero, 0
	addi $t4, $t7, 0
	addi $t3, $t6, 0
	
	sll $t1, $a1, 2
	add $t4, $t4, $t1
   init1:
   	slt $t1, $t0, $t8
   	beq $t1, $zero, endInit1
   	
   	lw $t2, 0($t4)
   	sw $t2, 0($t3)
   	
   	addi $t4, $t4, 4
   	addi $t3, $t3, 4
   	addi $t0, $t0, 1
   	j init1
   endInit1:
   
	# khoi tao mang a2 kich thuoc (end - mid) * 4 bytes
	# a2[i] = array[i + mid]
	li $v0, 9
	addi $a0, $t9, 0
	sll $a0, $a0, 2
	syscall
	addi $t5, $v0, 0
	
  	addi $t0, $zero, 0
	addi $t4, $t7, 0
	addi $t3, $t5, 0
  	sll $t1, $a2, 2
	add $t4, $t4, $t1
   init2:
   	slt $t1, $t0, $t9
   	beq $t1, $zero, endInit2
   	
   	lw $t2, 0($t4)
   	sw $t2, 0($t3)
   	
   	addi $t4, $t4, 4
   	addi $t3, $t3, 4
   	addi $t0, $t0, 1
   	j init2
   endInit2:
	
	# merge 2 mang a1 va a2 vao array
   	addi $t1, $zero, 0
   	addi $t2, $zero, 0
   	sll $t3, $a1, 2
	add $t7, $t7, $t3
   Loop2:
   	slt $t3, $t1, $t8
   	slt $t4, $t2, $t9
   	and $t3, $t3, $t4
   	beq $t3, $zero, endLoop2
   	
   	lw $t3, 0($t6)
   	lw $t4, 0($t5)
   	slt $a0, $t3, $t4
   	beq $a0, $zero, else
   	sw $t3, 0($t7)
   	addi $t6, $t6, 4
   	addi $t1, $t1, 1
   	j endIf1
     	else:
     	sw $t4, 0($t7)
     	addi $t5, $t5, 4
     	addi $t2, $t2, 1
     	endIf1:
     	addi $t7, $t7, 4
     	j Loop2
   endLoop2:
   
   # neu a1 con phan tu thi load vao array
   Loop3:
   	slt $t0, $t1, $t8
   	beq $t0, $zero, endLoop3
   	lw $t3, 0($t6)
   	sw $t3, 0($t7)
   	addi $t7, $t7, 4
   	addi $t6, $t6, 4
   	addi $t1, $t1, 1
   	j Loop3
   endLoop3:
   
   # neu a2 con phan tu thi load vao array
   Loop4:
   	slt $t0, $t2, $t9
   	beq $t0, $zero, endLoop4
   	lw $t3, 0($t5)
   	sw $t3, 0($t7)
   	addi $t7, $t7, 4
   	addi $t5, $t5, 4
   	addi $t2, $t2, 1
   	j Loop4
   endLoop4:
   
   	jr $ra

   	
	
	
  	
