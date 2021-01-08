#MergeSort
.data
	#Allocate 20 elements to test easily.
	arr:	.word -360, 0, 255, 94, 5, 100, 56, 204, -35, 10, 2525, 14, 1, -358, 68, 24, 5, -999, 23, 11
	sepa:	.asciiz ", "
	marklow:   .asciiz "Merge from index "
	markhigh:	.asciiz " to index "
	#Allocate 50 integer for temp array, modify if you want more.
	#Note that each temp array has at least (N + 1)/2 elements, where N is size of original array.
	.align 2
	arr1:  .space 200
	arr2:  .space 200
.text

	la	$a0, arr
	#20 elements array has low index: 0, high index: 19
	add	$a1, $0, $0
	addi	$a2, $0, 19
	
	#store low, high index to print each step in recursive function
	add	$s1, $0, $a1
	add	$s2, $0, $a2
	
	jal	printArray
	jal	mergeSort
	#jal	printArray
	
	#terminate program
	addi	$v0, $0, 10
	syscall
	
mergeSort:

	#MergeSort Algorithm
	#$a0 -> array's address
	#$a1 -> low index
	#$a2 -> high index
	
	#if (high == low), array is sorted
	beq	$a2, $a1, doNothing
		#$a3 = mid = (low + high) / 2
		add	$a3, $a1, $a2
		srl	$a3, $a3, 1
		
		
		addi	$sp, $sp, -16
		sw	$a1, 0($sp)
		sw	$a2, 4($sp)
		sw	$a3, 8($sp)
		sw	$ra, 12($sp)
		#change argument so that ($a1, $a2) = (low, mid)
		add	$a2, $a3, $s0
		#call mergeSort(arr, low, mid)
		jal	mergeSort
		lw	$a1, 0($sp)
		lw	$a2, 4($sp)
		lw	$a3, 8($sp)
		lw	$ra, 12($sp)
		#change argument so that ($a1, $a2) = (mid + 1, high)
		addi	$a1, $a3, 1
		#call mergeSort(arr, mid + 1, high)
		jal	mergeSort
		lw	$a1, 0($sp)
		lw	$a2, 4($sp)
		lw	$a3, 8($sp)
		lw	$ra, 12($sp)
		#call merge(arr, low, mid, high)
		jal	merge
		lw	$a1, 0($sp)
		lw	$a2, 4($sp)
		lw	$a3, 8($sp)
		lw	$ra, 12($sp)
		addi	$sp, $sp, 16
	doNothing:
	jr	$ra
merge:
	#Merge 2 array, arr[low..mid], arr[mid + 1..high] into 1 array
	#$a0 -> array's address, $a1 -> low, $a2 -> high, $a3 -> mid
	
	# Mark merged subarray
	sw	$a0, 0($sp)
	la	$a0, marklow
	li	$v0, 4
	syscall
	move	$a0, $a1
	li	$v0, 1
	syscall
	la	$a0, markhigh
	li	$v0, 4
	syscall
	move	$a0, $a2
	li	$v0, 1
	syscall
	
	add	$a0, $0, '\n'
	addi	$v0, $0, 11
	syscall
	
	lw	$a0, 0($sp)
	
	
	#$t0 = N1 = mid - low + 1
	sub	$t0, $a3, $a1
	addi	$t0, $t0, 1
	#t1 = N2 = high - mid
	sub	$t1, $a2, $a3
	#t2 = arr1's address, $t3 = arr2's address
	la	$t2, arr1
	la	$t3, arr2
	
	#Copy array to temp array
	sll	$t4, $a1, 2
	add	$t4, $a0, $t4	#address of arr[low]
	sll	$t5, $a3, 2
	add	$t5, $a0, $t5	#address of arr[mid]
	copy1:
		#bgt	$t4, $t5, finish1
		slt	$at, $t5, $t4
		bne	$at, $0, finish1
		
		lw	$t6, 0($t4)
		sw	$t6, 0($t2)
		
		addi	$t4, $t4, 4
		addi	$t2, $t2, 4
		j	copy1
	finish1:
	
	addi	$t4, $a3, 1
	sll	$t4, $t4, 2
	add	$t4, $a0, $t4	#address of arr[mid + 1]
	sll	$t5, $a2, 2
	add	$t5, $a0, $t5	#address of arr[high]
	copy2:
		#bgt	$t4, $t5, finish2
		slt	$at, $t5, $t4
		bne	$at, $0, finish2
		
		lw	$t6, 0($t4)
		sw	$t6, 0($t3)
		
		addi	$t4, $t4, 4
		addi	$t3, $t3, 4
		j	copy2		
	finish2:
	
	#t2 = arr1's address, $t3 = arr2's address, $t0 = N1, $t1 = N2
	la	$t2, arr1
	la	$t3, arr2
	
	#Merge Ascending
	#store $a0
	sw	$a0, -4($sp)
	#init $t4 = i = $t5 = j = 0; $a0 = arr[low]
	add	$t4, $0, $0
	add	$t5, $0, $0
	sll	$t6, $a1, 2
	add	$a0, $a0, $t6
	
	#while (i < N1 && j < N2)
	while1:
		beq	$t4, $t0, finishWhile1
		beq	$t5, $t1, finishWhile1
		lw	$t6, 0($t2)	#$t6 = arr1[i]
		lw	$t7, 0($t3)	#$t7 = arr2[j]
		#bgt	$t6, $t7, assignFromArr2 (if arr1[i] > arr2[j])
		slt	$at, $t7, $t6
		bne	$at, $0, assignFromArr2
		
		sw	$t6, 0($a0)	#arr[next] = arr1[i]
		addi	$t2, $t2, 4	
		addi	$t4, $t4, 1	#i++
		j	update
		assignFromArr2:
		sw	$t7, 0($a0)	#arr[next] = arr2[j]
		addi	$t3, $t3, 4
		addi	$t5, $t5, 1	#j++
		update:
		addi	$a0, $a0, 4	#next++		
		
		j	while1
	finishWhile1:
	
	#while (i < N1), add 
	while2:
		beq	$t4, $t0, finishWhile2
		lw	$t6, 0($t2)
		sw	$t6, 0($a0)
		addi	$t2, $t2, 4	
		addi	$t4, $t4, 1
		addi	$a0, $a0, 4
		j	while2
	finishWhile2:
	#while (j < N2)
	while3:
		beq	$t5, $t1, finishWhile3
		lw	$t6, 0($t3)
		sw	$t6, 0($a0)
		addi	$t3, $t3, 4	
		addi	$t5, $t5, 1
		addi	$a0, $a0, 4
		j	while3
	finishWhile3:
	#restore $a0 and return
	lw	$a0, -4($sp)
	
	#Below block is used for print array after each step, this can be removed.
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$a1, 4($sp)
	sw	$a2, 8($sp)
	add	$a1, $0, $s1
	add	$a2, $0, $s2
	jal	printArray
	lw	$ra, 0($sp)
	lw	$a1, 4($sp)
	lw	$a2, 8($sp)
	addi	$sp, $sp, 12	
	
	jr	$ra	
printArray:
	#Print array
	#$a0 -> array's address
	#$a1 -> low index
	#$a2 -> high index
	
	#store $a0
	sw	$a0, -4($sp)
	
	#$t7 = low
	add	$t7, $a1, $0
	#$t6 = address of current element
	sll	$t6, $a1, 2
	add	$t6, $t6, $a0
	
	printLoop:
		#bgt	$t7, $a2, exitPrint
		slt	$at, $a2, $t7
		bne	$at, $0, exitPrint
		
		lw	$a0, 0($t6)
		addi	$v0, $0, 1
		syscall
		
		beq	$t7, $a2, loopUpdate		
		printSeparate: #", "
			la	$a0, sepa
			addi	$v0, $0, 4
			syscall
		loopUpdate:
			#address += 4, low++
			addi	$t6, $t6, 4
			addi	$t7, $t7, 1
		
		j	printLoop
	exitPrint:
		#print('\n')
		add	$a0, $0, '\n'
		addi	$v0, $0, 11
		syscall
		
		#restore $a0 and return
		lw	$a0, -4($sp)
		jr	$ra
		
	
	
