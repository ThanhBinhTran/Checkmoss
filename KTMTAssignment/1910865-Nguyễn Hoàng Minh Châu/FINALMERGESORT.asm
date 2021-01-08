.data 		# Data declaration
str_usortd: 	.asciiz "Unsorted Array\n"
str_sorted: 	.asciiz "\nSorted Array\n"
begin: 		.asciiz "\n\nStart Merge Sort\n"
endl: 		.asciiz "\n"
space: 		.asciiz " "
arr: 			.word 25 82 10 -24 50 33 -15 -100 -37 35 52 -50 -59 -54 13 34 -93 -85 -77 70
temp_arr: 		.word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
len: 			.word 20
.text
.globl main

main:
	la $a0, temp_arr 		# load address new array
	la $a1, arr 		# load address old array 
	lw $a2, len 		# $a2 <- size
	and $a3, $zero, $zero 	# low = 0

#################### PRINT UNSORTED ARRAY	####################
prt_unsorted: 
	li $v0, 4 			# system call code for print_str
	la $a0, str_usortd 	# address of string to print
	syscall

	la $s0, arr			# load address of arr
	lw $s1, len			# load size
	li $s2, 0			# counter i
		
loop_un:
	beq $s2, $s1, startMS	# done print unsorted, jump to print "Start Merge Sort"
	li $v0, 1			# print element
	lw $a0, 0($s0)
	syscall
	
	li $v0, 4			# print space
	la $a0, space
	syscall
	
	addi $s0, $s0, 4		# arr++
	addi $s2, $s2, 1		# i++
	j loop_un			#jump to loop_unsorted

# print message													
startMS: 
	li $v0, 4 			#print "Start Merge Sort" 
	la $a0, begin 			 
	syscall
	
	j SORT

#################### PREPARE FOR MERGE SORT 	####################
SORT:					# copy argument for mergesort function
	addi $sp, $sp, -8		# make room on the stack
	sw $a1, 8($sp) 		# save address old array
	add $a2, $a2, -1 		# $a2 <- (size - 1) <- high
	sw $a2, 4($sp) 		# save high (array - 1)
	sw $a3, 0($sp) 		# save low
	jal MERGESORT 		# jump to MERGESORT(array, high, low)

#################### PRINT SORTED ARRRAY 		####################
# prepare for loop
ptr_sorted:	
	li $v0, 4 			# print "Sorted Array"
	la $a0, str_sorted	
	syscall
	
	la $s0, arr			# load address of arr
	lw $s1, len			# load size
	li $s2, 0			# counter i
	
	
loop_sorted:
	beq $s2, $s1, END		#done print sorted, jump to END
	li $v0, 1			# print element
	lw $a0, 0($s0)
	syscall
	
	li $v0, 4			# print space
	la $a0, space
	syscall
	
	addi $s0, $s0, 4		# arr++
	addi $s2, $s2, 1		# i++
	j loop_sorted		# continue loop

#################### END PROGRAM			####################
END:
	addi $sp, $sp, 20 	# pop all items from the stack in main
	li $v0, 10 				
	syscall 			# END OF PROGRAM

#########################################################################
# The entire below function will sort array of interger using merge sort# 
# We will print each step after merge 						#
# First part is used for seperating the array					#
# The second one merge two sub arrays       	   				#
#########################################################################
MERGESORT:
	addi $sp, $sp, -20 	# make room on the stack
	sw $ra, 16($sp) 		# save return address 
	sw $s1, 12($sp) 		# save address of arr
	sw $s2, 8($sp) 		# save high
	sw $s3, 4($sp) 		# save low
	sw $s4, 0($sp) 		# save mid

#################### SEPARATE PART 			####################		
	add $s1, $a1, $0 		# $s1 <- array address (argument)
	add $s2, $a2, $0		# $s2 <- size - 1 = high (argument)
	add $s3, $a3, $0 		# $s3 <- low size (argument)
	slt $t3, $s3, $s2 	# low < high
	beq $t3, $zero, DONE 	# if ($t3 == 0) (or low >= high) branch to DONE

	add $s4, $s3, $s2 	# low + high
	div $s4, $s4, 2 		# $s4 (mid) <- (low+high)/2
	
	# MERGESORT(array, low, mid) (left part)
	or $a2, $zero, $s4 	# high <- mid
	or $a3, $zero, $s3 	# low <- low
	jal MERGESORT 		

	# MERGESORT(a, mid+1, high) (right part)
	addi $a3, $s4, 1		# low <- (mid+1)
	addi $a2, $s2, 0 		# high <- high 
	jal MERGESORT 		# call MERGESORT(a, mid+1, high) (right part)

	add $a1, $s1, $0	 	# $a1 <- old array address
	add $a2, $s2, $0	 	# $a2 <- gets high
	add $a3, $s3, $0	 	# $a3 <- low
	add $a0, $s4, $0	 	# $a4 <- mid
	jal MERGE 			# jump to merge (array, high, low, mid)

#################### DONE MERGE, JUMP TO SEPARATE	####################
DONE:
	lw $ra, 16($sp) 		# load return address
	lw $s1, 12($sp) 		# load array address
	lw $s2, 8($sp) 		# load high
	lw $s3, 4($sp) 		# load low
	lw $s4, 0($sp) 		# load mid
	addi $sp, $sp, 20 	# clear room on the stack
	jr $ra 			# jump to saved address (jump to call recursive merge)

#################### MERGE PART 			####################	
MERGE:
	addi $sp, $sp, -20 	# make room on the stack
	sw $ra, 16($sp) 		# save return address
	sw $s1, 12($sp) 		# save unsorted array address
	sw $s2, 8($sp) 		# save high
	sw $s3, 4($sp) 		# save low
	sw $s4, 0($sp) 		# save mid

	add $s1, $a1, $0	 	# $s1 <- array address 
	add $s2, $a2, $0	 	# $s2 <- high
	add $s3, $a3, $0	 	# $s3 <- low
	add $s4, $a0, $0	 	# $s4 <- mid

	add $t1, $s3, $0		# i = $t1 <- low (counter i)
	add $t2, $s4, $0 			
	addi $t2, $t2, 1 		# j = $t2 <- (mid + 1) (counter j)
	add $t3, $s3, $0 		# k = low (temp arr counter k)

#################### MERGE ELEMENTS FROM 2 SUB ARRAYS INTO TEMP ARRAY ####################
WHILE:
	slt $t4, $s4, $t1 	# if (mid < i) 
	bne $t4, $zero, while2 	# go to while2 if (i > mid) *(!0 == 1) 

	slt $t5, $s2, $t2 	# (high < j)? 
	bne $t5, $zero, while2	# go to while2 if (j > high) 

	sll $t6, $t1, 2 		# i*4
	add $t6, $s1, $t6 	# $t6 = arr + i
	lw $s5, 0($t6) 		# $s5 = arr[i]

	sll $t7, $t2, 2 		# j*4
	add $t7, $s1, $t7 	# $t7 = arr + j
	lw $s6, 0($t7) 		# $s6 = arr[j]

	slt $t4, $s5, $s6 	# (arr[i] < arr[j])?
	beq $t4, $zero, else 	# go to else if (arr[i] >= arr[j])

	sll $t8, $t3, 2 		# k*4
	la $a0, temp_arr 		# load temp_arr
	add $t8, $a0, $t8 	# $t8 = temp_arr + k
	sw $s5, 0($t8) 		# temp_arr[k] = arr[i]

	addi $t3, $t3, 1 		# k++
	addi $t1, $t1, 1 		# i++
	j WHILE			# continue loop

# a[i] > a[j]
else:	
	sll $t8, $t3, 2 		# k*4
	la $a0, temp_arr 		# load temp_arr
	add $t8, $a0, $t8 	# $t8 = temp_arr + k
	sw $s6, 0($t8) 		# temp_arr[k] = arr[j]
	addi $t3, $t3, 1 		# k++
	addi $t2, $t2, 1 		# j++
	j WHILE			# back to WHILE and keep comparing arr[i] and arr[j]  


# when (i >= mid) or j >= high we don't need to compare a[i] and a[j]
while2:  				
	slt $t4, $s4, $t1 	# (mid < i)? 
	bne $t4, $zero, while3 	# go to while3 if (i >= mid)

	sll $t6, $t1, 2 		# i*4
	add $t6, $s1, $t6 	# $t6 = arr + i
	lw $s5, 0($t6) 		# $s5 = a[i]

	sll $t8, $t3, 2 		# k*4
	la $a0, temp_arr 		# load temp_arr
	add $t8, $a0, $t8 	# $t8 = temp_arr + k
	sw $s5, 0($t8) 		# temp_arr[k] = arr[i]

	addi $t3, $t3, 1 		# k++
	addi $t1, $t1, 1 		# i++
	j while2			# continue loop

while3:
	slt $t5, $s2, $t2 	# (high < j)?
	bne $t5, $zero, start 	# go to for loop if (j >= high)

	sll $t7, $t2, 2 		# i*4
	add $t7, $s1, $t7 	# $t7 = arr + j
	lw $s6, 0($t7) 		# $s6 = arr[j]

	sll $t8, $t3, 2 		# k*4
	la $a0, temp_arr 		# load address temp_arr
	add $t8, $a0, $t8 	# $t8 = temp_arr + k
	sw $s6, 0($t8) 		# temp_arr[k] = arr[j]

	addi $t3, $t3, 1 		# k++
	addi $t2, $t2, 1 		# j++
	j while3			# continue loop

#################### COPY ELEMENTS FROM TEMP ARRAY TO OUR ARRAY	####################
# prepare for copy function	
start:				
	add $t1, $s3, $0		# i = low
	addi $t3, $s2, 1		# $t3 = high + 1 = size
#copy from temp_arr to arr
COPY:					
	slt $t5, $t1, $t3		# (i < k)? (k = high + 1 = size) 
	beq $t5, $zero, prtpgrs # merging complete when (i >= size)

	sll $t6, $t1, 2 		# $t6 = i*4
	add $t6, $s1, $t6 	# $t6 = arr + i

	sll $t8, $t1, 2 		# $t8 = i*4
	la $a0, temp_arr 		# load address temp_arr
	add $t8, $a0, $t8 	# $t8 = temp_arr + i 
	lw $s7, 0($t8) 		# $s7 = temp_arr[i]
	sw $s7, 0($t6) 		# arr[i] = temp_arr[i]
	addi $t1, $t1, 1 		# i++
	j COPY

#################### PRINT PROGRESS 			####################
#prepare
prtpgrs:				
	la $s0, temp_arr		# load adress temp_arr
	sll $s2, $a3, 2		# $s2 = 4*low
	add $s0, $s0, $s2 	# address of the left sub_arr we have just merge		
	
	la $s1, temp_arr		# load adress temp_arr
	sll $s2, $t3, 2		# $s2 = 4*k
	add $s1, $s1, $s2		# arr + size (where we stop printing)
	j pgrsloop
#print after merge and jump to DONE	
pgrsloop:
	beq $s0, $s1, printline	# when we stop printing this merging step, print a new line
	
	li $v0, 1			# load arr[i]
	lw $a0, 0($s0)
	syscall
	
	li $v0, 4			# print space
	la $a0, space
	syscall
	
	addi $s0, $s0, 4		# arr++
	j pgrsloop
		
printline:
	li $v0, 4			# print line
	la $a0, endl
	syscall
	
	j DONE			# jump to DONE
