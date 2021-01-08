.data
#	arr: .word 20, 3, 5, 17, 1, 9, 10, 19, 18, 6, 8, 7, 2, 12, 16, 13, 11, 4, 14, 15
#	arr: .word 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
#	arr: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
	noti1: .asciiz "Initial array: "
	noti2: .asciiz "Sorted array: "
	noti3: .asciiz "Divide: "
	noti4: .asciiz "Merge: "
	noti5: .asciiz "-----> "
	noti6: .asciiz "Enter number of elements: "
	noti7: .asciiz "Enter "
	noti8: .asciiz " elements of array:\n"
.text
	j main						# Go to main function

#######################################################################
printArray:
# Print array of integer with (without) notification in $a2 (.asciiz)
# If $a2 = 0 print no notification.
# If $a3 = 0 print nothing at the end, else print character $a3 at the end, 
# $a0 and $a1 store the address of the first and last element in array, respectively.
#######################################################################
	# Print notification
	addu $s0, $a0, $zero				# Save a0 (first)
	beqz $a2, afNoti				# if (a2 == 0), print nothing
	addiu $v0, $zero, 4				# Print string
	addu $a0, $a2, $zero				# Print notification
	syscall
afNoti:							# s0 is currently saved value of first
	# Print array
	addu $t0, $s0, $zero				# t0 = s0 = saved first
	w1:	beq $t0, $a1, endw1			# While (t0 != last) do next statement
		addiu $v0, $zero, 1			# Print integer
		lw $a0, 0($t0)				# a0 = *t0 = integer to be printed
		syscall
		addiu $v0, $zero, 11			# Print character
		addiu $a0, $zero, ' '			# Print space
		syscall
		addiu $t0, $t0, 4			# ++t0
		j w1
	endw1:	
	addiu $v0, $zero, 1				# Print integer
	lw $a0, 0($t0)					# a0 = *a1 = last element to be printed
	syscall
	# Print character a3
	beqz $a3, endPrt				# If (a3 == 0) print nothing
	addiu $v0, $zero, 11				# Print character
	addu $a0, $a3, $zero				# Print a3
	syscall
endPrt:	addu $a0, $s0, $zero				# Restore a0
	jr $ra

#######################################################################
readArray:
# Read an array.
# Return address of first and last element of array in $v0, $v1, respectively.
# Firstly read the number of elements in array and allocate memory.
# If the element is less than or equal to 0, $v0 = 0.
# Then read elements of the array.
# The allocated memory need to be unallocated using deleteArray.
#######################################################################
	# Read number of elements
	addiu $v0, $zero, 4				# Print string
	la $a0, noti6					# Print noti6
	syscall
	addiu $v0, $zero, 5				# Read integer
	syscall
	bgtz $v0, read					# If (v0 <= 0) do next statement
	addu $v0, $zero, $zero				# v0 = 0
	jr $ra						# Return
read:	addu $t2, $v0, $zero				# t2 = v0 = N (number of elements)
	sll $t0, $t2, 2					# t0 = Number of bytes to allocate
	subu $sp, $sp, $t0				# Allocate memory for array
	addu $t1, $sp, $zero				# t1 = top of stack = it (iterator)
	# Read array
	addiu $v0, $zero, 4				# Print string
	la $a0, noti7					# Print noti7
	syscall
	addiu $v0, $zero, 1				# Print integer
	addu $a0, $t2, $zero				# Print N
	syscall
	addiu $v0, $zero, 4				# Print string
	la $a0, noti8					# Print noti8
	syscall
	w6:	beq $t0, $zero, endw6			# While (t0 != 0) do next statement
		addiu $v0, $zero, 5			# Read integer
		syscall
		sw $v0, 0($t1)				# Store element
		addiu, $t1, $t1, 4			# ++it
		addiu $t0, $t0, -4			# --N (decrease number of elements to be read)
		j w6
	endw6:
	addu $v0, $sp, $zero				# Address of first element
	addiu $v1, $t1, -4				# Address of last element
	jr $ra
	
#######################################################################
deleteArray:
# Unallocate memory for an array.
# $a0 and $a1 store the address of first and last element, respectively.
# Array need to be at top of stack, i.e. $a0 == $sp
#######################################################################
	bgt $a0, $a1, endDel				# If (first > last) return
	bne $a0, $sp, endDel				# If array is not at top of stack, return
	subu $t0, $a1, $a0
	addiu $t0, $t0, 4				# t0 = Number of bytes to unallocate
	addu $sp, $sp, $t0				# Unallocate memory
endDel:	jr $ra

#######################################################################
merge:
# Merge 2 sorted array
# $a0 = first, $a1 = mid, $a2 = last
# First array is [first, mid]
# Second array is [mid + 1, last]
#######################################################################
	subu $t0, $a2, $a0
	addiu $t0, $t0, 4				# t0 = last - first + 1 (words)
	subu $sp, $sp, $t0				# Allocate memory for temp array
	addu $t1, $a0, $zero				# Initialize t1 = first, t3 = left (left itertator)
	addiu $t2, $a1, 4				# Initialize t2 = mid + 1, t3 = right (right iterator)
	addu $t3, $sp, $zero				# Initialize t3 = sp, t3 = out (output iterator)
	w2:	bgt $t1, $a1, endw2			# While (left <= mid) do next statement
		bgt $t2, $a2, endw2			# While (right <= last) do next statement
		lw $t4, 0($t1)				# t4 = *left
		lw $t5, 0($t2)				# t5 = *right
			bgt $t4, $t5, elif1		# If (*left <= *right) do next statement
			sw $t4, 0($t3)			# *out = *left
			addiu $t1, $t1, 4		# ++left
			j endif1
		elif1:	sw $t5, 0($t3)			# *out = *right
			addiu $t2, $t2, 4		# ++right
		endif1:
		addiu $t3, $t3, 4			# ++out
		j w2
	endw2:
	w3:	bgt $t1, $a1, endw3			# While (left <= mid) do next statement
		lw $t4, 0($t1)				# t4 = *left
		sw $t4, 0($t3)				# *out = *left
		addiu $t1, $t1, 4			# ++left
		addiu $t3, $t3, 4			# ++out
		j w3
	endw3:
	w4:	bgt $t2, $a2, endw4			# While (right <= last) do next statement
		lw $t5, 0($t2)				# t5 = *right
		sw $t5, 0($t3)				# *out = *right
		addiu $t2, $t2, 4			# ++right
		addiu $t3, $t3, 4			# ++out
		j w4
	endw4:
	addu $t1, $a0, $zero				# t1 = first = it (iterator of original array)
	addu $t2, $sp, $zero				# t2 = sp = out (iterator of output array)
	w5:	bgt $t1, $a2, endw5			# While (it <= last) do next statement
		lw $t3, 0($t2)				# t3 = *out
		sw $t3, 0($t1)				# *it = t3
		addiu $t1, $t1, 4			# ++it
		addiu $t2, $t2, 4			# ++out
		j w5
	endw5:
	addu $sp, $sp, $t0				# Unallocate memory for temp array
	jr $ra

#######################################################################
mergeSort:
# Sort array of integer using mergeSort.
# $a0 and $a1 store the address of the first and last element in array, respectively.
# Before each division print each subarray, separated by '|'.
# Before merging 2 subarray print each sub array, separated by '&'.
# After merging print the array.
#######################################################################
	bge $a0, $a1, endSort				# If first >= last, return
	subu $t0, $a1, $a0				
	srl $t0, $t0, 2					# t0 = last - first
	srl $t0, $t0, 1					# t0 = (last - first)/2
	sll $t0, $t0, 2
	addu $t0, $a0, $t0				# t0 = first + (last - first)/2 = middle of array
	# Print first subarray before dividing
	addiu $sp, $sp, -16				# Allocate stack for a0, a1, t0, ra
	sw $t0, 0($sp)					# save mid
	sw $a0, 4($sp)					# save first
	sw $a1, 8($sp)					# save last
	sw $ra, 12($sp)					# save ra
	addu $a1, $t0, $zero				# a1 = last of first subarray (mid)
	la $a2, noti3					# print with noti3
	addiu $a3, $zero, '|'				# last character
	jal printArray
	# Print second subarray before dividing
	addiu $a0, $a1, 4				# a0 = first of second array (mid + 1)
	lw $a1, 8($sp)					# Restore a1 = last of second subarray
	addiu $a2, $zero, 0				# No notification
	addiu $a3, $zero, '\n'				# Print '\n' at the end
	jal printArray					
	# mergeSort(first, mid)
	lw $a0, 4($sp)					# Restore a0 = first
	lw $a1, 0($sp)					# a1 = saved t0 = mid
	jal mergeSort
	# mergeSort(mid + 1, end)
	addiu $a0, $a1, 4				# a0 = mid + 1
	lw $a1, 8($sp)					# Restore a1 = last
	jal mergeSort
	# Print first array before merging
	addiu $a1, $a0, -4				# a1 = mid
	lw $a0, 4($sp)					# Restore a0 = first
	la $a2, noti4					# Print with noti4
	addiu $a3, $zero, '&'				# Print '&' at the end
	jal printArray
	# Print second array before merging
	addiu $a0, $a1, 4				# a0 = mid + 1
	lw $a1, 8($sp)					# Restore a1 = last
	addiu $a2, $zero, 0				# No notification
	addiu $a3, $zero, '\n'				# Print '\n' at the end
	jal printArray
	# merge(first, mid, last)
	addu $a2, $a1, $zero				# a2 = last
	addiu $a1, $a0, -4				# a1 = mid
	lw $a0, 4($sp)					# Restore a0 = first
	jal merge
	# Print the array after merging
							# Unchange a0 = first
	addu $a1, $a2, $zero				# a1 = last
	la $a2, noti5					# Print with noti5
	addiu $a3, $zero, '\n'				# Print '\n' at the end
	jal printArray
	# Restore value and unallocate stack
	lw $t0, 0($sp)					# restore mid
	lw $a0, 4($sp)					# restore first
	lw $a1, 8($sp)					# restore last
	lw $ra, 12($sp)					# resotre ra
	addiu $sp, $sp, 16				# Unallocate stack
endSort:
	jr $ra

#######################################################################
main:
#######################################################################
	# Read the array
	jal readArray
	beq $v0, $zero, end				# If read nothing, exit
	# Print initial array
	addu $a0, $v0, $zero				# a0 = &array[0]
	addu $a1, $v1, $zero				# a1 = &array[last}
	la $a2, noti1					# print with noti1
	addiu $a3, $zero, '\n'				# print '\n' at the end
	jal printArray
	# Sort array using mergeSort
							# Unchange a0 = first, a1 = last element of array
	jal mergeSort
	# Print sorted array
							# Unchange a0 = first, a1 = last element of array
	la $a2, noti2					# Print with noti2
							# Unchange a3 = '\n'
	jal printArray
	# Unallocate memory for the array
							# Unchange a0 = first, a1 = last element of array
	jal deleteArray
end:	addiu $v0, $zero, 10				# Exit the program
	syscall
