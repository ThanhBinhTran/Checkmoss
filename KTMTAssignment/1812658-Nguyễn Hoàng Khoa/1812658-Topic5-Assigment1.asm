.data
A:	.word	-52,   91,  -14,    7,   10,   -1,  -64,  78,   70,  -47,  -59,  -96,   44,  -38,   87,   93, -51,  -23,   83,   -5


	Size:	.word	20
	space:	.asciiz	" "
	endl:	.asciiz	"\n"
	


.text
MAIN:
	la	$s0, A					# Load addr of A
	lw	$s1, Size				# Load length of A
	jal	PrintArray				# Print array A
	
	la	$s0, A
	li	$s1, 0
	lw	$s2, Size
	sub	$s2, $s2, 1
	jal	QuickSort
	
	li	$v0, 10
	li	$a0, 0
	syscall
	
	

# Function:	PrintArray
# Purpose:	Print an array  to screen
# Agruments:	$s0: Addr of array, $s1: Length of array
# Return value:	None
PrintArray:						
	beqz	$s1, EndPrintArray
	li	$v0, 1
	lw	$a0, ($s0)
	syscall						# Print A[i]
	li	$v0, 4
	la	$a0, space
	syscall						# Print space
	add	$s0, $s0, 4
	sub	$s1, $s1, 1
	j	PrintArray				# Loop to print
	
	EndPrintArray:
	li	$v0, 4
	la	$a0, endl
	syscall						# Print newline
	
	jr	$ra					# Return



# Function:	QuickSort
# Purpose:	Sort an array
# Agruments:	$s0: Addr of array, $s1: Left bound, $s2: Right bound (0-base)
# Return value:	None
QuickSort:	
	bge	$s1, $s2, EndQuickSort			# If From>=To then return
	mul	$t0, $s1, 4
	add	$t0, $t0, $s0
	lw	$t0, ($t0)				# Let $t0 = A[From] (Pivot)
	add	$t1, $s1, 1				# Let $t1 = From+1
	move	$t2, $s2				# Let $t2 = To
	
	BigWhile:					# Start a big while
	bge	$t1, $t2, EndBigWhile			
		
		SubWhile1:				# Start sub while 1
		bge	$t1, $t2, SubWhile2		# If Left >= Right
		mul	$t3, $t1, 4
		add	$t3, $t3, $s0
		lw	$t3, ($t3)			# $t3 = A[Left]
		bge	$t3, $t0, SubWhile2		# If A[Left] >= Pivot
		add	$t1, $t1, 1
		j	SubWhile1
		
		SubWhile2:				# Start sub while 2
		bge	$t1, $t2, TrySwap		# If Left >= Right
		mul	$t4, $t2, 4
		add	$t4, $t4, $s0
		lw	$t4, ($t4)			# Let $t4 = A[Right]
		blt	$t4, $t0, TrySwap		# If A[Right]<Pivot
		sub	$t2, $t2, 1
		j	SubWhile2
		
	TrySwap:
	mul	$t3, $t1, 4
	add	$t3, $t3, $s0
	lw	$t5, ($t3)				# Let $t5 = A[Left]
	blt	$t5, $t0, BigWhile			# If A[Left] < Pivot
	mul	$t4, $t2, 4	
	add	$t4, $t4, $s0	
	lw	$t6, ($t4)				# Let $t6 = A[Right]
	bge	$t6, $t0, BigWhile			# If A[Right] >= Pivot
		
	sw	$t5, ($t4)				# Now we swap
	sw	$t6, ($t3)				#	A[Left] and A[Right]
	j	BigWhile
		
	EndBigWhile:					
	mul	$t3, $t1, 4
	add	$t3, $t3, $s0
	lw	$t5, ($t3)				# $t5 = A[Left]
	blt	$t5, $t0, Skip				# If A[Left] < Pivot
	
	sub	$t1, $t1, 1				# Left -= 1
	sub	$t3, $t3, 4
	lw	$t5, ($t3)				# Reload A[Left]
	
	Skip:
	mul	$t4, $s1, 4
	add	$t4, $t4, $s0				# $t4 = addr of Pivot
	sw	$t5, ($t4)				# Swap A[Left]
	sw	$t0, ($t3)				#	and Pivot
	
	sub	$sp, $sp, 12
	sw	$s0, 8($sp)				# Push $s0
	sw	$s1, 4($sp)				# Push $s1
	sw	$ra, ($sp)
	lw	$s1, Size
	jal	PrintArray				# Call PrintArray(A, len)
	lw	$s0, 8($sp)
	lw	$s1, 4($sp)				# Pop $s1
	lw	$ra, ($sp)
	add	$sp, $sp, 12
	
	sub	$sp, $sp, 16
	sw	$s1, 12($sp)				# Push From
	sw	$t1, 8($sp)				# Push Left
	sw	$s2, 4($sp)				# Push To
	sw	$ra, ($sp)				
							# Time to recursive, hehe
	lw	$s1, 12($sp)
	lw	$s2, 8($sp)
	sub	$s2, $s2, 1
	jal	QuickSort				# Call QuickSort(From, Left-1)
	
	lw	$s1, 8($sp)
	add	$s1, $s1, 1
	lw	$s2, 4($sp)
	jal	QuickSort				# Call QuickSort(Left+1, To)
	
	lw	$ra, ($sp)
	add	$sp, $sp, 16
	
	EndQuickSort:
	jr	$ra