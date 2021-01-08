.data
ArrayBeforeSort:.asciiz		"Array before sort: "
ArrayAfterSort:	.asciiz		"Array after sort: "
Space:		.asciiz		" "
endl:		.asciiz 	"\n"
temp: 		.word 0:100 	# int temp[100] 
array:		.word 1,2,3,4,70,8,7,5,3,2,1,3,5,7,23,1,12,3,54,20
size: 		.word 20

.text
#################### MAIN FUNCTION ####################
Main:	
	la $a0, array		# load pointer to array
	addi $a1, $0, 0 	# $a1 = left	
	lw  $a2, size		# load size
	add $a2, $a1, $a2 	# $a2 = right + 1
	sub $a2, $a2, 1		# $a2 = right
	
	la  $a0, ArrayBeforeSort# Print("Array before sort: ")
	li  $v0, 4
	syscall
	jal Print
			
	la $a0, array		# load pointer to array
	jal Mergesort		# Merge(array, left, right)
	la  $a0, ArrayAfterSort	# Print("Array after sort: ")
	li  $v0, 4		
	syscall		
	jal Print		# Print(array, left, right)
	li  $v0, 10		# Exit.
	syscall
	
#################### MERGESORT FUNCTION ####################
Mergesort: 			# void Merge(int[] array, int left, int right)

### if (left >= right) Return; ###
		bge $a1, $a2, Return	# if (left >= right) Return;
		
######################		
### Save parameter ###
######################

		addi, $sp, $sp, -16 	# creat space in stack to save: return adress, left, right, mid
		sw, $ra, 12($sp)	# save return address
		sw, $a1, 8($sp)	       	# save left
		sw, $a2, 4($sp)        	# save right
		add $s0, $a1, $a2	# mid = left + right
		sra $s0, $s0, 1		# mid = (left + right) / 2
		sw $s0, 0($sp) 		# save mid

#######################
### Recursive call: ###
#######################

	### Mergesort(array, left, mid)		###
		add $a2, $s0, $0 		# $a2 = mid
		jal Mergesort			# Mergesort(array, left, mid)

	### Mergesort(array, mid + 1, right) ###
		lw $a1, 0($sp)			# $a1 = mid
		addi $a1, $a1, 1		# $a1 = mid + 1
		lw $a2, 4($sp) 			# $a2 = right
		jal Mergesort 			# Mergesort(array, mid+1, right)

####################
### Merge 2 half ###
####################

		lw, $a1, 8($sp) 		# $a1 = left
		lw, $a2, 4($sp)  		# $a2 = right
		lw, $a3, 0($sp) 		# $a3 = mid
		jal Merge			# Merge(arr, left, mid, right) 	

#####################
### Return result ###
#####################

		jal Print
		la $a0, array
		lw $ra, 12($sp)			# restore $ra from stack
		addi $sp, $sp, 16 		# restore stack
	Return:		
		jr  $ra
	
#################### MERGE FUNCTION ####################	
Merge:
##########################
##### int temp[100]; #####
##########################
		la $t0, temp
#############################################		
## for (int i = left; i <= mid; i++)	   ##
##	temp[i] = array[i]; 		   ##
#############################################
		add  $s0, $a1, $0 	# i = left
	for1:
		bgt $s0, $a3, endfor1	# if(i > mid) endloop
	### temp[i] = array[i] ###
		sll $t4, $s0, 2		# $t4 = i*4
		add $t1, $a0, $t4	# $t1 = &array[i]
		add $t2, $t0, $t4	# $t2 = &temp[i]
		lw $t3, 0($t1)		# $t3 = array[i]
		sw $t3, 0($t2)		# array[i] =  $t3
		addi $s0, $s0, 1	# i++
		j for1
	endfor1:

##################################################
##   for (int j = 1; j <= right - mid; j++) 	##
##	temp[right - j + 1] = array[j + mid];   ##
##################################################
		li $s0, 1 		# j = 1
		sub $s1, $a2, $a3	# $s1 = right - mid
	for2:
		bgt $s0, $s1, endfor2	# if(j > mid) endloop

	### temp[right-j+1] = array[j+mid] ###
		sub $t4, $a2, $s0	# $t4 = right - j
		addi $t4, $t4, 1	# $t4 = right - j + 1
		sll $t4, $t4, 2		# $t4 = (right - j + 1)*4
		add $t1, $t0, $t4	# $t1 = &temp[right-j+1]
		
		add $t4, $a3, $s0	# $t4 = mid + j
		sll $t4, $t4, 2		# $t4 = (mid + j)*4
		add $t2, $a0, $t4	# $t2 = &array[j+mid]
		
		lw $t3, 0($t2)		# $t3 = array[j+mid]
		sw $t3, 0($t1)		# temp[right-j+1] =  $t3
		
		addi $s0, $s0, 1	# i++
		j for2
	endfor2:
##################################################################
##   for (int i = left, j = right, k = left; k <= right; k++)	##
##  	if (temp[i] < temp[j]) left[k] = temp[i++];	   	##
##	else left[k] = temp[j--];				##
##################################################################
       	
		add $s0, $a1, $0	# i = left
		add $s1, $a2, $0	# j = right
		add $s2, $a1, $0	# k = left
	for3:
		bgt $s2, $a2, endfor3	# if(k > right) endloop
		sll $t4, $s0, 2		# $t4 = i*4
		add $t1, $t0, $t4	# $t1 = &temp[i]
		lw $t5, 0($t1)		# $t5 = temp[i]
		sll $t4, $s1, 2		# $t4 = j*4
		add $t2, $t0, $t4	# $t2 = &temp[j]
		lw $t6, 0($t2)		# $t6 = temp[j]
		sll $t4, $s2, 2		# $t4 = k*4
		add $t3, $a0, $t4	# $t3 = &array[k]
		bgt $t5, $t6, else

	### if (temp[i] <= temp[j])    ##
	##	array[k] = temp[i++]; ###
		sw $t5, 0($t3)		# array[k] = temp[i]
		addi $s0, $s0, 1	# i++
		addi $s2, $s2, 1	# k++
		j for3

	### else A[k] = temp[j--]; ###
	else:
		sw $t6, 0($t3)		# array[k] = temp[j]
		subi $s1, $s1, 1	# j--
		addi $s2, $s2, 1	# k++	
		j for3
		
	endfor3:

	jr $ra

#################### PRINT FUNCTION ####################
Print:
	add $t0, $a1, $zero 	# $t0 = left
	add $t1, $a2, $zero	# $t1 = right
	la  $t4, array		# load the address of the array into $t4
	
Print_Loop:
	blt  $t1, $t0, Exit	# if $t1 < $t0, go to Exit
	sll  $t3, $t0, 2	# $t0 * 4 to get the offset
	add  $t3, $t3, $t4	# add the offset to the address of array to get array[$t3]
	lw   $t2, 0($t3)	# load the value at array[$t0] to $t2
	move $a0, $t2		# move the value to $a0 for printing
	li   $v0, 1	
	syscall
	
	addi $t0, $t0, 1	# $t0 = $t0 + 1
	la   $a0, Space		# Prints a space between the numbers
	li   $v0, 4	
	syscall
	j    Print_Loop		# Go to next iteration of the loop
Exit:	
	la $a0, endl
	li $v0, 4
	syscall
	jr $ra			# jump to the address in $ra; Go back to main
