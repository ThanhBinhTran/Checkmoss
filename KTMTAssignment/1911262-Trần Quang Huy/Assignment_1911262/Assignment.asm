################################################################################################ 
###                                Problem: Quick sort algorithm                             ###		
###                                  Tr?n Quang Huy - 1911262                                ###
################################################################################################

#Data section
.data
	#Array of 20 integer
	array: .word 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
	cSpace: .asciiz " "
	cEnter: .asciiz "\n"
.text
.globl main

##########################################################
###                    main function                   ###	
##########################################################
main:
	#Initial variable
	
	#la $a0, array
	lui $a0, 0x1001						#Load address of array to a0
	ori $a0, $a0, 0
	
	addi $a1, $zero, 0					#Load left index to a1 (0)
	addi $a2, $zero, 19					#Load right index to a2 (19)
	
	#The argument for printing is the same with default
	#Don't change the argument
	
	#Print before sort
	jal Print
	
	#Sort array
	jal Quick_sort					#Call Quick_sort function and link pc to $ra
	
	#Print after sort
	jal Print
	
	#Exit
	addi $v0, $zero, 10
	syscall
######################End main function###################

##########################################################
###                   print function                   ###	
##########################################################
	#Input: $a0 - address of array
	#Output: None
Print:
#Prepare value for printing
	#arr[left]
	addi $t0, $zero, 0				#t0 = left (i)
	sll $t1, $t0, 2					#t1 = 4 * left
	add $t1, $a0, $t1				#t1 = &(arr[left])
	
	#right
	addi $t2, $zero, 19				#t2 = right
	
	#Space character
	#la $t3, cSpace					#t3 = &(" ")
	lui $t3, 0x1001
	ori $t3, $t3, 80

Print_Loop:	
#For i = left; i <= right; i++
	#Stop condition of loop (i > right)
	#bgt $t0, $t2, Print_Next
	slt $at, $t2, $t0
	bne $at, $zero, Print_Next
	
#Print arr[i]
	#Push a0 to stack
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	#Print
	lw $a0, 0($t1)
	addi $v0, $zero, 1				#Print integer
	syscall						#Call
	
	#Pop a0 from stack
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	
#Print space
	#Push a0 to stack
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	#Print
	lb $a0, 0($t3)
	
	li $v0, 11					#Print space
	syscall						#Call
	
	#Pop a0 from stack
	lw $a0, 0($sp)
	addi $sp, $sp, 4

#Loop continue
	#Increase i for next loop
	addi $t0, $t0, 1				#i++
	
	#Next number to print
	addi $t1, $t1, 4				#t1 = next num in array
	
	#Continue loop
	j Print_Loop
	
#End of loop
Print_Next:
	#Set t3 to \n 
	#la $t3, cEnter					#t3 = enter
	lui $t3, 0x1001
	ori $t3, $t3, 82
	
#Print \n
	#Push a0 to stack
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	#Print
	lb $a0, 0($t3)
	
	addi $v0, $zero, 11				#Print space
	syscall						#Call
	
	#Pop a0 from stack
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra						#Function return
	
################### End Print function ###################
	
##########################################################
###                    swap function                   ###	
##########################################################
	#Input: $a0, $a1 - address of variable (a & b)
	#Output: None
Swap:
	lw $t0, 0($a0)					#t0 = a
	lw $t1, 0($a1)					#t1 = b
	sw $t1, 0($a0)					#a = t1
	sw $t0, 0($a1)					#b = t0
	
	jr $ra						#Function return
##################### End swap function ##################	


##########################################################
###                  partition function                ###	
##########################################################
	#Input: $a0 - address of array
	#	$a1 - left index
	#	$a2 - right index
	#Output: $s0 - pos index
	
Partition:
	#Save for using s0, s1, s2
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)

	#i = left - 1
	addi $s0, $a1, -1				#s0 = left - 1 (i)
	
	#j = left
	addi $s1, $a1, 0				#s1 = left
	
	#pivot = arr[right]
	sll $t1, $a2, 2					#t1 = 4 * right
	add $t1, $a0, $t1				#t1 = &(arr[right])
	lw $s2, 0($t1)					#s2 = arr[right] (pivot)
	
	

Par_Loop:
#For j = left; j < right; j++
	#if (j >= right) End Loop
	#bge $s1, $a2, Par_Next
	slt $at, $s1, $a2
	beq $at, $zero, Par_Next
	
	#arr[j]
	sll $t3, $s1, 2					#t3 = 4 * j
	add $t3, $a0, $t3				#t3 = &(arr[j])
	lw $t3, 0($t3)					#t3 = arr[j]
	
	#if (arr[j] >= pivot) No swap
	#bge $t3, $s2, Par_Else
	slt $at, $t3, $s2
	beq $at, $zero, Par_Else
Par_If:
	addi $s0, $s0, 1				#i++
	
	#Calculate argument for swap
	sll $t4, $s0, 2					#t4 = 4 * i
	add $t4, $a0, $t4				#t4 = &(arr[i])
	
	sll $t5, $s1, 2					#t5 = 4 * j
	add $t5, $a0, $t5				#t5 = &(arr[j])
	
	#Call swap
	#Push to stack
	addi $sp, $sp, -12				
	sw $a0, 0($sp)					
	sw $a1, 4($sp)					
	sw $ra, 8($sp)					
	
	#Pass argument
	add $a0, $zero, $t4				#a0 = &(arr[i])
	add $a1, $zero, $t5				#a1 = &(arr[j])
	
	jal Swap
	
	#Pop stack
	lw $a0, 0($sp)					
	lw $a1, 4($sp)				
	lw $ra, 8($sp)				
	addi $sp, $sp, 12

Par_Else:	
	addi $s1, $s1, 1				#j++
	j Par_Loop
	
Par_Next:
#End loop

	addi $s0, $s0, 1				#i++
	
	#Calculate argument for swap
	sll $t4, $s0, 2					#t4 = 4 * i
	add $t4, $a0, $t4				#t4 = &(arr[i])
	
	sll $t5, $a2, 2					#t5 = 4 * right
	add $t5, $a0, $t5				#t5 = &(arr[right])
	
	#Call swap
	#Push to stack
	addi $sp, $sp, -12				
	sw $a0, 0($sp)					
	sw $a1, 4($sp)					
	sw $ra, 8($sp)					

	#Pass argument
	add $a0, $zero, $t4				#a0 = arr[i]
	add $a1, $zero, $t5				#a1 = arr[right]
	
	jal Swap
	
	#Pop stack
	lw $a0, 0($sp)					
	lw $a1, 4($sp)					
	lw $ra, 8($sp)					
	addi $sp, $sp ,12
	
	add $v0, $zero, $s0				#Return i
	
	#Return value for s0, s1, s2
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
		
	jr $ra						#Function return
################# End partition function #################

##########################################################
###                 Quick_sort function                ###	
##########################################################
	#Input: $a0 - address of array
	#	$a1 - left index
	#	$a2 - right index
	#Output: None
Quick_sort:
	#Save for using s0
	addi $sp, $sp, -4
	sw $s0, 0($sp)

	#Stop condition
	#bge $a1, $a2, End_Quick_sort			#If left >= right function end
	slt $at, $a1, $a2
	beq $at, $zero, End_Quick_sort

#Partition(arr, left, right)
	#Push to stack
	addi $sp, $sp, -16
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $ra, 12($sp)
	
	#pos = Partition(arr, left, right)
	jal Partition
	add $s0, $zero, $v0
	
	#Pop from stack
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	
#Quick_sort(arr, pos + 1, right)
	#Push to stack
	addi $sp, $sp, -16
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $ra, 12($sp)
	
	#Pass argument for Quick_sort recursion
	addi $a1, $s0, 1 #left = pos + 1
	
	jal Quick_sort
	
	#Pop from stack
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	
#Quick_sort(arr, left, pos - 1)
	#Push to stack
	addi $sp, $sp, -16
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $ra, 12($sp)	
	
	#Pass argument for Quick_sort recursion
	addi $a2, $s0, -1 #right -> pos - 1
	
	jal Quick_sort
	
	#Pop from stack
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	
End_Quick_sort:
	
	#Print for Demo
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	jal Print
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#Return value for s0
	lw $s0, 0($sp)
	addi $sp, $sp, 4

	jr $ra
