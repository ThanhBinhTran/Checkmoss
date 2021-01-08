.data
    myarray:.space 80  			# create space for aray with 20 word elements
    st:.asciiz "Enter the 20 Elements:\n"
    spa: .asciiz " "				# space char
    eol: .asciiz "\n"				# end of line
.text    
    addi $v0,$0,4				# promp array input
    la $a0,st					
    syscall
    addi $t0, $0, 0				# set counter/index to 0
    addi $t1, $0, 80				# Get array size
    jal inputArray				# input array 
inputArray:    	
    beq $t0, $t1, exit    				# check loop condition
    addi $v0, $0, 5				# input from user
    syscall
    
    sw $v0, myarray($t0)			# store user's value to array
    add $t0,$t0,4				# incement counter/index
    j inputArray				# loop the function 

exit:
   	la	$a0, myarray		# Load the start address of the array
	add	$t0, $0, $t1		# Load the array length
	add	$a1, $a0, $t0		# Calculate the array end address
	jal	mergesort		# Call the merge sort function
  	add 	$v0, $0, 10
  	syscall				# We are finished sorting
	
	
# Recrusive mergesort function
#
# @param $a0 first address of the array
# @param $a1 last address of the array
##
mergesort:

	addi	$sp, $sp, -16		# Adjust stack pointer
	sw	$ra, 0($sp)		# Store the return address on the stack
	sw	$a0, 4($sp)		# Store the array start address on the stack
	sw	$a1, 8($sp)		# Store the array end address on the stack
	sub 	$t0, $a1, $a0		# Calculate the difference between the start and end address 
					# (i.e. number of elements * 4)
	ble	$t0, 4, mergedone	# If the array only contains a single element, just return
	srl	$t0, $t0, 3		# Divide the array size by 8 to half the number of elements 
					# (shift right 3 bits)
	sll	$t0, $t0, 2		# Multiple that number by 4 to get half of the array size
					# (shift left 2 bits)
	add	$a1, $a0, $t0		# Calculate the midpoint address of the array
	sw	$a1, 12($sp)		# Store the array midpoint address on the stack
	jal	mergesort		# Call recursively on the first half of the array
	lw	$a0, 12($sp)		# Load the midpoint address of the array from the stack
	lw	$a1, 8($sp)		# Load the end address of the array from the stack
	jal	mergesort		# Call recursively on the second half of the array
	
	lw	$a0, 4($sp)		# Load the array start address from the stack
	lw	$a1, 12($sp)		# Load the array midpoint address from the stack
	lw	$a2, 8($sp)		# Load the array end address from the stack
	
	jal	merge			# Merge the two array halves
	
mergesortend:				

	lw	$ra, 0($sp)		# Load the return address from the stack
	addi	$sp, $sp, 16		# Adjust the stack pointer
	jr	$ra			# Return 
	
##
# Merge two sorted, adjacent arrays into one using 2 subarrray
#
# @param $a0 First address of first array
# @param $a1 First address of second array
# @param $a2 Last address of second array
##
merge:
	addi	$sp, $sp, -16		# Adjust the stack pointer
	sw	$ra, 0($sp)		# Store the return address on the stack
	sw	$a0, 4($sp)		# Store the start address on the stack
	sw	$a1, 8($sp)		# Store the midpoint address on the stack
	sw	$a2, 12($sp)		# Store the end address on the stack
	sub 	$t6, $a1, $a0		# Calculate first half size	
	sub	$t7, $a2, $a1		# Calculate second half size
	
	addi	$v0, $0, 9	
	add 	$a0, $0, $t6		# Create array[$t6]	
	syscall
	add	$s0, $0, $v0		# Move address of newly created array to $s0
	
	addi	$v0, $0, 9
	add 	$a0, $0, $t7		# Create array[$t7]
	syscall	
	add	$s1, $0, $v0		# Move address of newly created array to $s1
	lw	$a0, 4($sp)		# Reload start address
	addi	$t0, $0, 0		# Create index
	la	$s2, ($s0)		# Create working copy of array $s0
	la	$s3, ($s1)		# Create working copy of array $s1
copyData1:				# Copy data from first half to array $s0
	bge	$t0, $t6, copy1done	# Check loop condition			 
	lw	$t1, 0($a0)		# Assign element at index $t0 to element in array $s0
	sw	$t1, 0($s2)
	addi	$a0, $a0, 4		# Increase index and both of array's address
	addi	$s2, $s2, 4		
	addi	$t0, $t0, 4
	j 	copyData1		# Loop again
copy1done:
	lw	$a0, 4($sp)		# Reload the start address of the original array
	addi	$t0, $0, 0		# Reset index to 0
copyData2:				# Copy data from second half to array $s1
	bge	$t0, $t7, copy2done	# Check loop condition	
	lw	$t1, 0($a1)		# Assign element at index $t0 to element in array $s1
	sw	$t1, 0($s3)
	addi	$a1, $a1, 4		# Increase index and both of array's address
	addi	$s3, $s3, 4
	addi	$t0, $t0, 4
	j	copyData2		# Loop again
copy2done:
	addi	$t0, $0, 0		# Create index for array $s0
	addi	$t1, $0, 0		# Create index for array $s1
	la	$s2, ($s0)		# Reset to begining of array $s0 
	la	$s3, ($s1)		# Reset to begining of array $s1 
	lw	$a0, 4($sp)		# Reload the start address of the original array
mergeloop:				# Merging 2 array $s0, $s1 to original array
	bge	$t0, $t6, remain1	# Loop condition: $t0 < $t6($s0 size) && $t1 < $t7($s1 size)
	bge	$t1, $t7, remain1
	lw	$t2, 0($s2)		# Load value of current element in array $s0 to $t2
	lw	$t3, 0($s3)		# Load value of current element in array $s1 to $t3
	bgt	$t2, $t3, else		# Compare 2 value of 2 subarray, the smaller one will be add to 
					# original array and continue with the next one in the same subarray 
	sw	$t2, 0($a0)		# Store value of current element in array $s0 to the 
					# current position of original array
	addi 	$t0, $t0, 4		# Increment index $t0
	addi	$a0, $a0, 4		# Move onto the next element of the original array 
	addi	$s2, $s2, 4		# Move onto the next element of array $s0 
	j	mergeloop
else:	
	sw	$t3, 0($a0)		# Store value of current element in array $s1 to the 
					# current position of original array
	addi 	$t1, $t1, 4		# Increment index $t1
	addi	$a0, $a0, 4		# Move onto the next element of the original array
	addi	$s3, $s3, 4		# Move onto the next element of array $s0 
	j	mergeloop		# Loop again
	
remain1:				# Copy the remaining elements of array $s0 to original array
	bge	$t0, $t6, remain2	# Loop condition
	lw	$t2, 0($s2)		# Assign $s0's current value to current element of original array
	sw	$t2, 0($a0)
	addi 	$t0, $t0, 4		# Increase index and move to the next element of both array
	addi	$a0, $a0, 4
	addi	$s2, $s2, 4
	j	remain1			# Loop again
remain2:				# Copy the remaining elements of array $s0 to original array
	bge	$t1, $t7, mergedone	# Loop condition
	lw	$t3, 0($s3)		# Assign $s1's current value to current element of original array
	sw	$t3, 0($a0)
	addi 	$t1, $t1, 4		# Increase index and move to the next element of both array
	addi	$a0, $a0, 4
	addi	$s3, $s3, 4
	j	remain2			
mergedone:
	jal	print			# Each time a merge finished, print the array
	jr	$ra			# Return	
print:					# print the array
	la 	$a0, myarray		# load address of array
	addi	$t0, $0, 0		# initialize the starting index
	addi 	$t1, $0, 80		# length of array 
	jal	prloop
prloop:
	bge	$t0, $t1, prend		# if index >= length, jump to prend
	lw 	$a0, myarray($t0)	# print element at index 
	li 	$v0, 1
	syscall
	la 	$a0, spa		# print a space betwwen printing an element
	addi 	$v0, $0, 4
	syscall
	addi	$t0, $t0, 4		# incement index
	b	prloop			# loop
prend:  
	la 	$a0, eol		# Get to new line
	addi 	$v0, $0, 4
	syscall 	
	lw	$ra, 0($sp)		# Load the return address
	addi	$sp, $sp, 16		# Adjust the stack pointer
	jr 	$ra			# Return


