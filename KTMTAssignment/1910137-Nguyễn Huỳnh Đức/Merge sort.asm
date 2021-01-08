.data
arr: .word 	14, -789, 854, 90, 944, 990, 567, -145, 670, 365,
		257, -304, -195, 169, 862, -350, 256, 587, 199, -313
size: .word 20

check: .asciiz "After Merge: "
.text

.globl main
main:	
	la $a0, arr
	lw $a1, size
	jal mergeSort

	addi $v0, $0, 10
	syscall
####################################################################################	
	
####################################################################################
#	mergeSort's prototype: a0 = arr, a1 = size
#		+ arr is the first element's address in array
#		+ size is the size of full array
####################################################################################	
mergeSort:                         	
	#ble $a1, 1, exitMergeSort     	#stop condition for recursion
	addi $t0, $a1, -1
	slti $t0, $t0, 1
	bne $t0, $0, exitMergeSort
	
	addi $sp, $sp, -20		#push ra, a0, a1, s0, s1 into stack
	sw $ra, 16($sp)			#
	sw $a0, 12($sp)			#
	sw $a1, 8($sp)			#
	sw $s0, 4($sp)			#
	sw $s1, 0($sp)			#

	srl $s1, $a1, 1			#s1 is the middle index (it is also the size of the first array)
	sll $s0, $s1, 2			#
	add $s0, $s0, $a0		#s0 is the middle address
	
	lw $a0, 12($sp)			#
	addi $a1, $s1, 0		#
	jal mergeSort     		#recursion with a0 = arr, a1 = size / 2
	
	addi $a0, $s0, 0		#
	lw $a1, 8($sp)			#
	sub  $a1, $a1, $s1		#
	jal mergeSort    		#recursion with a0 = arr + size / 2, a1 = size - (size / 2)
	
	lw $a0, 12($sp)			#
	lw $a2, 8($sp)			#
	addi $a1, $s1, 0 		#
	jal merge        		#call merge function with a0 = arr, a1 = size / 2, a2 = size
	
	la $a0, check			#
	li $v0, 4			#
	syscall				#
	lw $a0, 12($sp)			#
	lw $a1, 8($sp)			#
	jal print			#print step
	
	lw $ra, 16($sp)			#
	lw $a0, 12($sp)			#
	lw $a2, 8($sp)			#
	lw $s0, 4($sp)			#
	lw $s1, 0($sp)			#
	addi $sp, $sp, 20		#pop ra, a0, a1, s0, s1 out of stack
	
exitMergeSort:
	jr $ra
####################################################################################
	
	
####################################################################################
#	Merge's prototype: a0 = arr, a1 = middle , a2 = size
#		+ arr is the first element's address in array
#		+ middle is the first element's index in the second array
#		+ size is the size of full array
####################################################################################
merge:	
	#bge $a1, $a2, exitMerge		#stop condition
	slt $t0, $a1, $a2
	beq $t0, $0, exitMerge
	
	addi $sp, $sp, -12		#push s0, s1, s2 into stack
	sw $s0, 8($sp)			#
	sw $s1, 4($sp)			#
	sw $s2, 0($sp)			#
				
	sll $s2, $a1, 2			#a0 = arr, a1 = middle index, a2 = size
	sub $sp, $sp, $s2		#call stack for a tempoary array
	add $s0, $0, $sp		#s0 is the temporary array
	
	#li $t0, 0			#t0 is the index for loop
	add $t0, $0, $0
	bCopy:	beq $t0, $a1 eCopy	#loop and copy first array to temporary array
		
		sll $t1, $t0, 2
		add $t1, $a0, $t1
		lw $t1, 0($t1)		#load elemental value to t1 every loop
		
		sll $t2, $t0, 2
		add $t2, $s0, $t2
		sw $t1, 0($t2)
		addi $t0, $t0, 1
		j bCopy
	eCopy:	
	
	add $s1, $a0, $0 		#point to the current merged address
	
	li $t0, 0			#t0 is the index for counting merged position in the first array
	add $t1, $0, $a1		#t1 is the index for counting merged position in the second array
	bMer: 	beq $t0, $a1, eMer	
		beq $t1, $a2, eMer
		
		sll $t2, $t0, 2		#
		sll $t3, $t1, 2		#
		add $t2, $t2, $s0	#
		add $t3, $t3, $a0	#
		lw $t2, 0($t2)		#load the value arr[t0] to t2
		lw $t3, 0($t3)		#load the value arr[t1] to t3
		
		if1:	#bgt $t2, $t3, else1	#if t2 <= t3, then store t2 into array
			slt $t4, $t3, $t2
			bne $t4, $0, else1
			
			sw $t2, 0($s1)		#
			addi $t0, $t0, 1	#
			addi $s1, $s1, 4	#
			j exit1			#
		else1:	sw $t3, 0($s1)		#else, store t3 into array
			addi $t1, $t1, 1	#
			addi $s1, $s1, 4	#	
		exit1:	j bMer			#
	eMer:					
	
	bMer1:	beq $t0, $a1, eMer1		#push the rest elements of the first arry into array
						#
		sll $t2, $t0, 2			#
		add $t2, $t2, $s0		#
		lw $t2, 0($t2)			#
						#
		sw $t2, 0($s1)			#
		addi $t0, $t0, 1		#
		addi $s1, $s1, 4		#
		j bMer1				#
	eMer1:					#
	
	bMer2: 	beq $t1, $a2, eMer2		#push the rest elements of the second arry into array
						#
		sll $t3, $t1, 2			#
		add $t3, $t3, $a0		#
		lw $t3, 0($t3)			#
						#
		sw $t3, 0($s1)			#
		addi $t1, $t1, 1		#
		addi $s1, $s1, 4		#
		j bMer2				#
	eMer2:					#
	
	add $sp, $sp, $s2		#release the temporary array in stack
	
	lw $s0, 8($sp)			#
	lw $s1, 4($sp)			#
	lw $s2, 0($sp)			#
	addi $sp, $sp, 12		#pop s0, s1, s2 out of stack
exitMerge:	
	jr $ra
####################################################################################	
	
####################################################################################
#	print's prototype: a0 = arr, a1 = size
#		+ arr is the first element's address in array
#		+ size is the size of full array
####################################################################################
print:										   
	add $s0, $a0, $0		#copy the arr to s0
	addi $t0, $0, 0			#t0 is the index for loop
	loopP:	beq $t0, $a1, exitP	
	
		sll $t1, $t0, 2		#
		add $t1, $t1, $s0	#
		lw $a0, 0($t1)		#load arr[t0] to a0
		addi $v0, $0, 1		#
		syscall 		#print arr[t0]
		
		addi $a0, $0, ' '	#
		addi $v0, $0, 11	#
		syscall			#print character ' '
		
		addi $t0, $t0, 1
		j loopP
	exitP:
	
	addi $a0, $0, '\n'			#
	addi $v0, $0, 11			#
	syscall 			#print character '\n'
	
	jr $ra
####################################################################################	
		
		
	
	
