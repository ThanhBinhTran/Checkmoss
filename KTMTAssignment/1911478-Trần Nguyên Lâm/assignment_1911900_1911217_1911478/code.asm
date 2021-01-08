#------------------------------------#
# Authored by: Nhom BlackBird     #
# Purpose Quicksort in MIPS         #
# Dinh Gia Quang - 1911900	# 
# Tran Pham Thai Hoa - 1911217 `	#
# Tran Nguyen Lam   - 1911478		#
#------------------------------------#

.data # data site

array:  .space 80  		# 80 bytes to store 20 elements integer 4 byte
enter:  .asciiz "\n"
input:  .asciiz "Mang cac phan tu ban dau la: "
PartitionStr: .asciiz "Partition lan "
Pivotis: .asciiz "PivotIndex: "
tempstr: .asciiz ": "
outputstr: .asciiz "Mang cac phan tu sau khi sap xep la: "
.text # code size
.globl main

main:
la 	$s1, array   	# load address of array
li 	$t1, 0   	# i = 0 

InputLoop:
	li 	$v0, 5      	# set reading integer mode

	syscall 
	add 	$a0, $0, $v0
	sw 	$a0, 0($s1) 	# save elements into array at i index
	addi 	$t1, $t1, 1 	# i = i + 1
	addi    $s1, $s1, 4     # add address by 4
	slti   	$t2, $t1, 20 	# if  i = 20, break loop
	bne 	$t2, 0, InputLoop  # Loop
##############
#print array after partition
	
	li   	$v0, 4		# print string
	la 	$a0, input
	syscall
	
	la 	$s1, array
	li 	$s0, 0			# i = 0
	
	
OutputLoop:
	li 	$v0, 1 
	lw 	$a0, 0($s1)
	syscall
	
	# print space, 32 is ASCII code for space
	li 	$a0, 32
	li 	$v0, 11  		# syscall number for printing character
	syscall

	addi 	$s0, $s0, 1 		# i = i + 1
	addi    $s1, $s1, 4     	# add address by 4
	slti   	$s6, $s0, 20 		# if  i = 20, break loop
	bne 	$s6, 0, OutputLoop  	# Loop
	
	li      $v0, 4
	la      $a0, enter
	syscall  
##############
la 	$t0, array 	# Moves the address of array into register $t0.
addi 	$a0, $t0, 0 	# Set argument 1 to the array.
addi    $a3, $a0, 80    # end of array
addi    $t2, $0, 0	# count numPartition
jal 	quicksort 	# Call quick sort
##############
#print array after partition
	
	li   	$v0, 4		# print string
	la 	$a0, outputstr
	syscall
	
	la 	$s1, array
	li 	$s0, 0			# i = 0
	
	
OutputLoop2:
	li 	$v0, 1 
	lw 	$a0, 0($s1)
	syscall
	
	# print space, 32 is ASCII code for space
	li 	$a0, 32
	li 	$v0, 11  		# syscall number for printing character
	syscall

	addi 	$s0, $s0, 1 		# i = i + 1
	addi    $s1, $s1, 4     	# add address by 4
	slti   	$s6, $s0, 20 		# if  i = 20, break loop
	bne 	$s6, 0, OutputLoop2  	# Loop
	
	li      $v0, 4
	la      $a0, enter
	syscall  
##############

	
li	$v0, 10		# end
syscall

################

swap:				

	addi 	$sp, $sp, -12		# Make stack room for 3

	sw 	$a0, 0($sp)		# Store a0
	sw 	$a1, 4($sp)		# Store a1  = a
	sw 	$a2, 8($sp)		# store a2  = b

	sll 	$s5, $a1, 2 		# s5 = 4a
	add 	$s5, $a0, $s5		# s5 = arr + 4a
	lw 	$s3, 0($s5)		# s3  t = arr[a]

	sll 	$s6, $a2, 2		# s6 = 4b
	add 	$s6, $a0, $s6		# s6 = arr + 4b
	lw 	$s4, 0($s6)		# s4 = arr[b]

	sw 	$s4, 0($s5)		# arr[a] = arr[b]
	sw 	$s3, 0($s6)		# arr[b] = t 


	addi 	$sp, $sp, 12		# Restoring the stack size
	jr 	$ra			# jump back to the caller
	
###################

partition: 			
	addi 	$sp, $sp, -12		# Make room for 3

	sw 	$a0, 0($sp)		# store a0
	sw 	$a3, 4($sp)         	# store end of arr
	sw 	$ra, 8($sp)		# store return address
	
	
	sub  	$s2, $a3, $a0		# s2 = 4*size = end - start
	srl  	$s2, $s2, 2		# s2 = size
	addi 	$t3, $0, 1 		# t3 = left index = 1
	addi 	$s2, $s2, -1 		# s2 = size - 1
	
	addi 	$t4, $s2, 0		# t4 = right index
	
	sub  	$t5, $a3, $a0      	# t5 = 4*size = end - start
	srl  	$t5, $t5, 2		# t5 = size
	beq  	$t5, 2, Then1 		# if (size = 2) jump to Then1
	j    	breakIf1		# else jump to breakIf1
Then1:	
	lw   	$t6, 0($a0)  		# t6 = arr[0]
	lw   	$t7, 4($a0)		# t7 = arr[1]
	slt  	$t5, $t6, $t7		# t5 = 1 if arr[0] < arr[1], else t5 = 0 
	beq 	$t5, 0, ElseIf2		# if arr[0] > arr[1] jump to ELseIf2 to swap arr[0] and arr[1]
	addi 	$t4, $0, 0        		
	j 	endPartition
	
ElseIf2:
	addi 	$a1, $0, 0 		# a1 = 0
	addi 	$a2, $0, 1		# a2 = 1
	addi 	$t4, $0, 1        	
	jal 	swap 
	j 	endPartition
	 
breakIf1:
	lw  	$t1, 0($a0)		# t1 = arr[low] //pivot
Loop:
	slt 	$t5, $t3, $t4       	# t5 = 1 if leftIndex < rightindex, else t5 = 0
	beq	$t5, 0, OutLoop		# if leftIndex < rightindex jump to OutLoop
	
While1:
	sll 	$t5, $t3, 2		#t5 = 4*leftindex
	add 	$t5, $t5, $a0		#t5 = arr + 4*leftindex
	lw  	$t7, 0($t5)		#t7 = arr[leftindex]
	
	
	slt 	$t5, $t7, $t1       	# t5 = 1 if arr[leftindex] < pivot
	sle     $t6, $t3, $s2		# leftindex < size
	and     $t5, $t5, $t6		# t5 = (arr[leftindex] < pivot && i < size)
	beq 	$t5, 0, OutWhile1		# if t5 = 0 break While1 and jump to OutWhile1
	addi 	$t3, $t3, 1        	# else leftindex = leftindex + 1
	j 	While1
OutWhile1:
While2:
	sll 	$t5, $t4, 2		# t5 = 4*rightindex
	add 	$t5, $t5, $a0		# t5 = arr + 4*rightindex
	lw 	$t6, 0($t5)		# t6 = arr[rightindex]	
			
	slt 	$t5, $t1, $t6       	# t5 = 1 if pivot < arr[rightindex]
	slt 	$t7, $0, $t4        	# t7 = 1 if 0 < rightindex
	and 	$t5, $t5, $t7       	# t5 = (pivot < arr[rightindex] && 0 < rightindex)
	beq 	$t5, 0, OutWhile2     	# if t5 = 0 break While2 and jump to OutWhile2
	addi 	$t4, $t4, -1        	# else rightindex = rightindex - 1
	j 	While2
OutWhile2:		
	slt 	$t5, $t3, $t4       	# t5 = 1 if leftindex < rightindex
	beqz 	$t5, OutIf1 		
	move 	$a1, $t3		# if t5 = 1 then swap arr[rightindex] and arr[leftindex]
	move 	$a2, $t4
	jal 	swap
OutIf1:	
	j 	Loop
OutLoop:	
	slt 	$t5, $t4, $t3       	# t5 = 1 if rightindex < leftindex
	beq 	$t5, 0, OutIf2		
	move 	$a1, $0			# if t5 = 1 then swap arr[0] and arr[rightindex]
	move 	$a2, $t4
	jal 	swap
OutIf2:	
endPartition:
	#print array after partition
	add    	$s7, $a0, $0		# s7 = arr
	addi 	$t2, $t2, 1		#count numPartition
	li 	$v0, 4     
	la 	$a0, PartitionStr
	syscall 
	
	li      $v0, 1
	move    $a0, $t2
	syscall 
	
	li      $v0, 4
	la 	$a0, tempstr	
	syscall 
	
	li 	$s0, 0			# i = 0
	move    $s1, $s7
	sub  	$s3, $a3, $s1      	# t5 = 4*size = end - start
	srl  	$s3, $s3, 2		# t5 = size
OutputLoop1:
	li 	$v0, 1 
	lw 	$a0, 0($s1)
	syscall
	
	# print space, 32 is ASCII code for space
	li 	$a0, 32
	li 	$v0, 11  		# syscall number for printing character
	syscall

	addi 	$s0, $s0, 1 		# i = i + 1
	addi    $s1, $s1, 4     	# add address by 4
	slt   	$s6, $s0, $s3 		# if  i = size, break loop
	bne 	$s6, 0, OutputLoop1  	# Loop
	
	li      $v0, 4
	la      $a0, enter
	syscall  
	
	li 	$v0, 4
	la      $a0, Pivotis
	syscall
	
	li 	$v0, 1
	move 	$a0, $t4
	syscall
	
	li      $v0, 4
	la      $a0, enter
	syscall 
	
	
# end of print results
	move    $a0, $s7
	sll 	$t5, $t4, 2		# t1 = rightindex*4
	add 	$v0, $a0, $t5        	# return start + pivotindex
	lw 	$ra, 8($sp)		# return address
	addi	$sp, $sp, 12		# restore the stack
	jr 	$ra			# junp back to the caller

########################
quicksort:
	addi $sp, $sp, -12		# Make room for 3

	sw $a0, 0($sp)			# a0
	sw $a3, 4($sp)			# end of array
	sw $ra, 8($sp)			# return address
	

	slt $t5, $a0, $a3		# t1=1 if start < end, else 0
	beq $t5, $zero, endif		# if low >= high, endif

	jal partition			# call partition 
	
	
	move $a3, $v0			#a2 = pivotaddress
	jal quicksort			#call quicksort(start, pivot)

	addi $v0, $v0, 4		#pivotad = pivotad + 4
	move $a0, $v0
	lw   $a3, 4($sp)		#a2 = high
	jal quicksort			#call quicksort

 endif:

 	lw $a0, 0($sp)			#restore a0
 	lw $a3, 4($sp)			#restore end of address
 	lw $ra, 8($sp)			#restore return address
 	
 	addi $sp, $sp, 12		#restore the stack
 	jr $ra				#return to caller
