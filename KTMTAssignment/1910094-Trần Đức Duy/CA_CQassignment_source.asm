#########################
#		MERGE SORT		#
#########################

	.data
array:		.word		-384905  -497203  -535486  -9350460  -534473  -623844  -615493  -783840  
length:		.word		8
tmp_size:	.word		10
tmp: 		.space	 	100
msg:		.asciiz		"Array: "
endl:		.asciiz		"\n"
space:		.asciiz		"  "

	.text
main:
	la		$a0, array		# a0 = start of array		
	lw		$t0, length		# t0 = length
	sll		$t0, $t0, 2		# t0 * 4
	add		$a1, $a0, $t0		# a1 = end of array
	jal 		print			# Print initial array
	jal		mergesort		# Call merge sort
	li		$v0, 10			# Terminate program
	syscall
# end of main

mergesort:
	addi		$sp, $sp, -16		# Allocate stack
	sw		$ra, 12($sp)		# Save return address
	sw		$a0, 8($sp)		# Save start pointer
	sw		$a1, 4($sp)		# Save end pointer
	
	sub		$t0, $a1, $a0		# Calculate lenght * 4
	addi		$t9, $t0, -4				
	slti		$t9, $t9, 1
	bne		$t9, $zero, mergesort_end
	
    	sra		$t1, $t0, 3		# Calculate length / 2
    	sll		$t1, $t1, 2					#
    	add		$a2, $a0, $t1		# Calculate mid pointer
    	sw		$a2, 0($sp)		# Store in stack
    	lw		$a0, 8($sp)		# a0 = start
    	lw		$a1, 0($sp)		# a1 = mid
    	jal		mergesort		# Call merge sort on first half			
    	lw		$a0, 0($sp)		# a0 = mid
    	lw		$a1, 4($sp)		# a1 = end
    	jal		mergesort		# Call merge sort on second half
    	lw		$a0, 8($sp)		# a0 = start
    	lw		$a1, 0($sp)		# a1 = mid
    	lw		$a2, 4($sp)		# a2 = end
    	jal		merge			# Merge two arrays

###		Print processing array		
		lw		$a0, 8($sp)	# a0 = start
		lw		$a1, 4($sp)	# a1 = mid
		jal		print		# then print (partly) sorted array
	mergesort_end:
	lw		$ra, 12($sp)		# Save return address
	lw		$a0, 8($sp)		# Save start pointer
	lw		$a1, 4($sp)		# Save end pointer
	addi	$sp, $sp, 16			# Restore stack
	jr		$ra			# Return
# end of mergesort	

merge:

	# a0 start
	# a1 mid
	# a2 end
	
	add 	$s0, $a0, $0 		#Copy start to S0
	add 	$s1, $a1, $0 		#Copy mid to S1
	add	$s2, $a2, $0		#Copy end to S2
	
copy:
	la 	$s3, tmp		#address of tmp S3
	addiu	$t0, $zero, 0		#init index t0
	sub	$t1, $s1, $s0		#size 
	srl	$t1, $t1, 2
	copyloop:
		slt	$t7, $t0, $t1	# bool
		beqz 	$t7, endcopy
		sll	$t2, $t0, 2
		add	$t2, $t2, $s0	# address a[i]
		lw	$t2, 0($t2)	# value a[i] t2
		sw	$t2, 0($s3)	# copy to tmp
		addi	$t0, $t0, 1	# inc index a[]
		addi 	$s3, $s3, 4	# inc address tmp
		j 	copyloop
endcopy:
	
	
mergeProcess:
	add 	$t0, $s0, $0		# p
	add	$t1, $s1, $0		# mid
					# s3 is end address of tmp
	la	$t2, tmp		# load start address of tmp - L
					# s2 is end address of a[]
	
mergeLoop:
	slt	$t9, $t2, $s3
	beq	$t9, $zero, endmergeLoop	# if t2 >= s3, end merge loop
	slt	$t9, $t1, $s2
	beq	$t9, $zero, endmergeLoop	# if t1 >= s2, end merge loop
	lw	$t4, 0($t2)
	lw	$t5, 0($t1)
	if:
		slt	$t9, $t5, $t4		# if t4 > t5, 
		bne	$t9, $zero, else	# jump to else
		sw	$t4, 0($t0)		#copy tmp
		add	$t2, $t2, 4
		add	$t0, $t0, 4
		j 	endif
	else:
		sw	$t5, 0($t0)		#copy second half
		add	$t1, $t1, 4
		add	$t0, $t0, 4
	endif:
	j	mergeLoop
endmergeLoop: 
	
firstSegLoop:
	slt	$t9, $t2, $s3			# if t2 >= s3,
	beq	$t9, $zero, endFirstSegLoop	# end first seg loop
	lw	$t4, 0($t2)
	sw	$t4, 0($t0)
	add 	$t2, $t2, 4
	add	$t0, $t0, 4
	j	firstSegLoop
endFirstSegLoop:

secondSegLoop:
	slt	$t9, $t1, $s2			# if t1 >= s2,
	beq	$t9, $zero, endSecondSegLoop	# end second seg loop
	lw	$t4, 0($t1)
	sw	$t4, 0($t0)
	add 	$t1, $t1, 4
	add	$t0, $t0, 4
	j	secondSegLoop
endSecondSegLoop:

endmerge:
	jr	$ra

#End Merge implement
##########################################################
print:
	addi	$sp, $sp, -12			# Allocate stack
	sw	$ra, 8($sp)			# Save return address
	sw	$a0, 4($sp)			# Save start pointer
	sw	$a1, 0($sp)			# Save end pointer
	li	$v0, 4				# Print "Array: "
	la	$a0, msg			#
	syscall					#
	lw	$s0, 4($sp)			# Copy start pointer
	lw	$s1, 0($sp)			# Copy end pointer
	print_loop:
		slt		$t9, $s0, $s1			# if s0 >= s1,
		beq		$t9, $zero, print_loop_end	# end print loop
		lw		$t0, 0($s0)			# t0 = element
		li		$v0, 1				# Print t0
		addi		$a0, $t0, 0			#
		syscall						#
		li		$v0, 4				# Print space
		la		$a0, space			#
		syscall						#
		addi		$s0, $s0, 4			# Increment start pointer
		j		print_loop			#
	print_loop_end:
	li		$v0, 4					# Print \n
	la		$a0, endl				#
	syscall							#
	lw		$ra, 8($sp)				# Save return address
	lw		$a0, 4($sp)				# Save start pointer
	lw		$a1, 0($sp)				# Save end pointer
	addi		$sp, $sp, 12				# Restore stack pointer
	jr		$ra					#
# end of print

	

	
	


