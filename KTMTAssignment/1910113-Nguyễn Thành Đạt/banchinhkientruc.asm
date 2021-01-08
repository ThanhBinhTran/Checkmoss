.data 
	array: .word -295,-158,-152,154,895,12,28,37,-359,482,112,278,417,-435,196,28,-575,149,3738,7
	newline: .asciiz"\n Quicksort: "
	space: .asciiz"  "
	Sorted: .asciiz"\n Sorted: "
.text
	la $a0, array
	li $a1, 0
	li $a2, 19
	jal quicksort
	jal printafter
	li $v0, 10
	syscall
#########################################	
quicksort:
		addi $sp, $sp, -16		# mo rong stack
		sw $a0, 0($sp)			
		sw $a1, 4($sp)
		sw $a2, 8($sp)			#day gia tri doi so vao stack
		sw $ra, 12($sp)
	
		bge $a1, $a2, exit		# if( low < high)
			jal print		# print
			jal partition		# partition(array, low, high)
			addi $sp, $sp, -4	# mo rong stack
			sw $v0, 0($sp)		# day gia tri v0 vao stack
			addi $a2, $v0, -1
			jal quicksort		# quicksort(array, low, pivot -1) 
			addi $a1, $v0, 1
			lw $v0, 0($sp)
			addi $sp, $sp, 4
			lw $a2, 8($sp)
			jal quicksort		## quicksort(array, pivot +1, high) 
	exit:
		lw $a0, 0($sp)
		lw $a1, 4($sp)
		lw $a2, 8($sp)
		lw $ra, 12($sp)			#tra lai gia tri cho doi so, khoi phuc stack
		addi $sp, $sp, 16
		jr $ra
########################################
partition:
	addi $sp, $sp, -16			# mo rong stack
	sw $a0, 0($sp)
	sw $a1, 4($sp)				# day gia tri vao stack
	sw $a2, 8($sp)
	sw $ra, 12($sp)
	
	sll $t0, $a2, 2
	add $t0, $t0, $a0			#int pivot = arr[high]; 
	lw $t0, 0($t0)
	
	addi $t1, $a1, -1       		#int i = (low - 1);
	add $t2, $0, $a1   			#int j = low
	
	Loop:	
		bge $t2, $a2, exitpar  		 #j < high
		sll  $t3, $t2, 2
		add $t3, $a0, $t3					
		lw $t3, 0($t3)						
		bge $t3, $t0, exitif		#array[j] < pivot
			addi $t1, $t1, 1				
			add $a1, $0, $t1					
			add $a2, $0, $t2				
			jal swap		#swap(a0, i, j)
			lw $a1, 4($sp)					
			lw $a2, 8($sp)					
		exitif:								
		addi $t2, $t2, 1
		j Loop
	exitpar:
		addi $a1, $t1, 1
		lw $a2, 8($sp)
		jal swap			#swap(a0, a1, a2)
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)				#tra lai gia tri cho doi so, tra lai stack
	lw $ra, 12($sp)
	addi $v0, $t1, 1					
	addi $sp, $sp, 16	
	jr $ra								
#####################################################
swap:
	sll $t5, $a1, 2				
	add $t5, $t5, $a0			 
	lw $s5, 0($t5)
	
	sll $t6, $a2, 2
	add $t6, $t6, $a0		# ham swap hai so
	lw $s6, 0($t6)
	
	sw $s5, 0($t6)
	sw $s6, 0($t5)
	jr $ra
#####################################################
printafter:				# ham in day so sau khi sort
	la $a0, Sorted
 	li $v0, 4
 	syscall
	li $s0, 0
 	la $s1, array
	la $a0, array
 	loop:
 		beq $s0, 20, exitp	
 		lw $a0 , 0($s1)
 		li $v0, 1
 		syscall
 		li $v0, 4
 		la $a0, space
 		syscall
 		add $s0, $s0, 1
 		add $s1, $s1, 4
 	j loop
 	exitp:
	jr $ra
#########################################################################
print:					# ham in cac day so  truoc khi vao partition
	addi $sp, $sp, -24		# mở rộng stack

	sw $a0, 0($sp)			# array
	sw $a1, 4($sp)			# low
	sw $a2, 8($sp)			# high
	sw $ra, 12($sp)
	sw $t1, 16($sp)
	sw $v0, 20($sp)
	la $a0, newline
 	li $v0, 4
 	syscall
	la $a3, array
	mul $t1, $a1, 4
	add $a3, $a3, $t1
 	loopn:
 		bgt $a1, $a2, exitnp
 		lw $a0 , 0($a3)
 		li $v0, 1
 		syscall
 		li $v0, 4
 		la $a0, space
 		syscall
 		add $a1, $a1, 1
 		add $a3, $a3, 4
 	j loopn
 exitnp:
	lw $a0, 0($sp)			
	lw $a1, 4($sp)			
	lw $a2, 8($sp)			#tra lai gia tri cho doi so va bien, khoi phuc stack
	lw $ra, 12($sp)
	lw $t1, 16($sp)
	lw $v0, 20($sp)
 	addi $sp, $sp, 24
 	jr $ra

	
	
	
	
	
	
