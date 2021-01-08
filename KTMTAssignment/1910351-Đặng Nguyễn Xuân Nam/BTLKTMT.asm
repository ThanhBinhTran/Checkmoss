.data 
	arr: .space 80 
	size: .word 20
	mess1: .asciiz "Input array of 20 integers: "
	mess2: .asciiz "Current array: "
	mess3: .asciiz ", "
	mess4: .ascii "\n"
	
.text 
#arr -> a0
#size -> a1
#low -> a2 || high ->a3
#patition return v0

# ============================ main =========================

#call readInput to read 20 elements and save them to arr respectively
jal readInput 

#load address of arr and load word size of arr
la $a0, arr
lw $a1, size

#let $a2 = 0 and $a3 = size of arr - 1
add $a2, $0, $0 
addi $a3, $a1, -1

#call quickSort to start quicksort in this arr
jal quickSort

#call printOutput to print arr after sorting (from the smallest to the biggest)
jal printOutput

#end program
addi $v0, $0, 10 
syscall 

#============================ end main =========================

#============================ read Input =======================
readInput:
	#display string: 
	la $a0, mess1
	addi $v0, $0, 4
	syscall

	#"Input array of 20 integers: "
	add $t0, $0, $0
	lw $t1, size 
	la $t2, arr
	
	#jump to read_loop to read each element of arr
	j read_loop
	
	
	read_loop:
		#branch instruction, stop when entering enough 20 elements; continue if not enough
		beq $t0, $t1, exit_read_loop
		
		#read element and save to $v0
		addi $v0, $0, 5
		syscall
		
		#$t0 increase by 1 and $t2 increase by 4 (go to the next element of arr)
		sw $v0, ($t2)
		addi $t0, $t0, 1 #i++
		addi $t2, $t2, 4 #pointer++
		
		#continue loop 
		j read_loop
	
	#stop reading and saving elements	
	exit_read_loop: 
		jr $ra

#=====================End Read Input=====================#

#==================Print Output===========================#		
printOutput:
	#display string: "Current array: "
	la $a0, mess2
	addi $v0, $0, 4
	syscall
	
	#save data to stack
	addi $sp, $sp, -8 
	sw $ra 0($sp)
	sw $t5 4($sp)
	
	#set $t4 = 0 and $t5 = size of array
	addi $t4, $0, 0
	lw $t5, size 
	la $t6, arr
	
	#start printing
	j print_loop
	
	print_loop:
		#branch with printing, like readling
		beq $t4, $t5, exit_print_loop
		lw $a0 ($t6)
		
		addi $v0, $0, 1
		syscall
		
		#$t4 increase by 1 and $t6 increase by 4 (go to the next element of arr)
		addi $t4, $t4, 1 #i++
		addi $t6, $t6, 4 #pointer++
		
		#if this is not the last element of array, print comma(,) between two elements
		slt $t7, $t4, $t5
		bne $t7, $0, print_dau_phay
		
		#print next element
		back_to_print_loop:
		j print_loop
	
	#print comma (,) between two elements of arr
	print_dau_phay:
		la $a0, mess3
		addi $v0, $0, 4
		syscall 
		j back_to_print_loop
		
	#stop printing arr
	exit_print_loop:
		la $a0, mess4
		addi $v0, $0, 4
		syscall
		
		la $a0, arr
		lw $a1, size
		
		#load data from stack
		lw $ra, 0($sp)
		lw $t5 4($sp)
		addi $sp, $sp, 8
		
		jr $ra
		
#===================== End print Output ===============#

#===================== Partition ======================#

Partition:
	add $t1, $0, $a2 	# pivot = low || t1 = pivot
	sll $t7, $t1, 2  
	add $t4, $a0, $t7 
	lw $t4, 0($t4)
	addi $t2, $t1, 1		#t2 = i	
	add $t3, $0, $a3		#t3 = j
	
i_be_hon_j: 
	#condition for patition: i<=j
	slt $t7, $t3, $t2
	bne $t7, $0, end_partition

#i inscreases by 1 until ith element of arr is greater or equal than pivot-th element of arr
i_plus_plus:
	slt $t7, $t3, $t2
	bne $t7, $0, j_minus_minus
	sll $t7, $t2, 2
	add $t5,$a0,$t7 		#get arr[i]
	lw $t5,0($t5) 		#arr[i]
	#if arr[i] > arr[pivot] then jump
	slt $t7, $t4, $t5
	bne $t7, $0, j_minus_minus
	addi $t2,$t2,1 		#i++
	j i_plus_plus
	
#j descreases by 1 until ith element of arr is less or equal than pivot-th element of arr
j_minus_minus:
	slt $t7, $t3, $t2
	bne $t7, $0, swap
	sll $t7,$t3,2
	add $t6,$a0,$t7 		#add arr[j]
	lw $t6,0($t6) 		#arr[j]
	#blt $t6,$t4, swap 	#if arr[j]< arr[pivot] then jump
	slt $t7, $t6, $t4
	bne $t7, $0, swap
	addi $t3,$t3,-1
	j j_minus_minus

#exchange place of two element with i and j found in i_plus_plus and j_minus_minus function when i is less than j; 
#then continue with increasing i and decreasing j if i < j, stop end parition if not
swap:
	#neu i > j
	slt $t7, $t3, $t2
	bne $t7, $0, i_be_hon_j
	sll $t7,$t2,2
	add $t5,$a0,$t7 #get arr[i]
	sll $t7,$t3,2
	add $t6,$a0,$t7 #get arr[j]
	lw $t8,0($t5) #t8 = arr[i]
	lw $t9,0($t6) #t9 = arr[j]
	sw $t8,0($t6)
	sw $t9,0($t5)
	j i_be_hon_j

#end partition and take pivot to the next step of quicksort	
end_partition:
	sll $t7,$t3,2
	add $t6,$a0,$t7 #get arr[j]
	sll $t7,$t1,2
	add $t4,$a0,$t7 #get arr[pivot]
	lw $t8,0($t6) #t8 = arr[j]
	lw $t9,0($t4) #t9 = arr[pivot]
	sw $t8,0($t4) 
	sw $t9,0($t6)
	la $v0,0($t3) #return j 
	jr $ra

#==========================end partition ===================#

#===========================Quick sort=====================#			

quickSort:
	#save data to stack	
	addi $sp,$sp,-16
	sw $ra, 12($sp)
	sw $a2,8($sp)
	sw $a3,4($sp)
	sw $t0,0($sp)
	
	#stop this function
	slt $t7, $a2, $a3
	beq $t7, $0, end_quick_sort
	
	#call partition if pivot is greater than smallest index and less than biggest index in sub of arr quicksorting
	jal Partition
	add $t0,$v0,$zero
	
	addi $sp, $sp, -4	# store
	sw $ra, 0($sp)
	jal printOutput
	lw $ra, 0($sp)		#restore
	addi $sp, $sp, 4
	
	#call quicksort of arr from smallest index to pivot - 1
	addi $a3,$t0,-1
	jal quickSort
	
	#call quicksort of arr from pivot + 1 to biggest index
	addi $a2,$t0,1
	lw $a3,4($sp)
	jal quickSort

#stop quicksort and return main function
end_quick_sort:
	#stop quicksort and load data saved in stack
	lw $t0,0($sp)
	lw $ra, 12($sp)
	lw $a2,8($sp)
	lw $a3,4($sp)
	addi $sp,$sp,16
	jr $ra
	
#========================end Quick sort=====================#
