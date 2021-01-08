.data
	maxsize: 		.word 20
	arr:			.space 80
	N:   			.asciiz "\n"
	dis: 			.asciiz " "
	inputsize_msg: 		.asciiz "Please enter size of array: "
	invalidsize_msg:	 .asciiz "Invalid size please enter another number: "
	input_msg: 		.asciiz "Please enter an int number: "
.text
.globl main

#	BEGIN MAIN FUNC
main:
# 	enter input section
	addi 	$v0, $0, 4		#	load v0 to tell sys to print a string
	la 	$a0, inputsize_msg	#	load a0 to tell sys adress of input size msg
	syscall				# 	syscall to print input size msg
input:
	addi 	$v0, $0, 5			#	load v0 to tell sys let user enter an int
	syscall				# 	syscall for user enter a number
	
	addi 	$at, $v0, -1		#
	slti	$at, $at, 0		#	convert ble $v0,0,wrongformat to standard mips 
	bne	$at, $0, wrongformat	#		
#	ble 	$v0, 0, wrongformat	#	in case size <= 0 branch to wrongformat	

	addi 	$at, $0,20		#
	slt 	$at, $at, $v0		#	convert bgt $v0,20,wrongformat to standard mips
	bne 	$at, $0, wrongformat	#	
#	bgt	$v0, 20, wrongformat	# 	in case size >20 branch to wrongformat
 		
	move 	$t9, $v0		#	$t9 = size array 
	la 	$t1, arr		#	load adress of arr
	addi 	$t2, $0, 0			# 	init i in arr[i]
	j 	inputloop		# 	and jump to input loop after we check validation of input size
wrongformat:
	addi 	$v0, $0, 4				
	la 	$a0,invalidsize_msg		
	syscall				#	syscall to print invalid msg 	
	j	input			# 	jump back to input to user enter another size

inputloop:
	beq 	$t2, $t9, exitinputloop	#	if user enter enough element exit input loop
	addi 	$v0, $0, 4
	la 	$a0, input_msg		
	syscall				#	syscall to print msg to tell user enter arr[i]
	addi 	$v0, $0, 5
	syscall				#	syscall for user enter arr[i]
	sw 	$v0, ($t1)		#	store what user enter to address t1
	add 	$t1, $t1, 4		#	increase t1 by 4 	(an int)
	add	$t2, $t2, 1		# 	increase counter by 1 (i)
	j	inputloop		#	if t2 < t9 we continue to tell user to enter more number (i < size)

exitinputloop:
# 	end input section
# 	we start init argument for merge sort and sort from here
	la	$a0, arr		#	$a0 = first address of array
	sll 	$t0, $t9, 2		#	$t0-size array * 4	
	add	$a1, $a0, $t0		#	$a1 = last address of array
	jal	mergesort		#	mergesort function call
	addi 	$v0, $zero, 10		#	end program
	syscall		
#	END MAIN FUNC

#	BEGIN MERGESORT FUNC	
#	mergesortfunc argument( $a0 first address of array, a1 last address of array)
mergesort:
#	save data for return in stack
	addi	$sp, $sp, -16		#	call stack pointer for returning value
	sw	$ra, 0($sp)		#	return function
	sw	$a0, 4($sp)		#	put $a0 in stack
	sw	$a1, 8($sp)		#	put $a1 in stack
	
#	process for mergesort
	sub 	$t0, $a1, $a0		#	$t0 = $a1 - $a0 = size of the array we are targeting * 4 
	
	addi 	$at, $t0, -1		#
	slti 	$at, $at, 4		#	convert ble $t0, 4, mergesort end to standard mips
	bne 	$at, $0, mergesortend	#	
#	ble	$t0, 4, mergesortend	#	if there is  one element -> mergesortend

	srl	$t0, $t0, 3		#	
	sll	$t0, $t0, 2		#	$t0 = $t0 / 2
	add	$a1, $a0, $t0		#	$a1 now = middle address of array ($a0 + $t0)
	sw	$a1, 12($sp)		#	put $a1 in the stack
	
	jal	mergesort		#	recursive function of the first half of array
	
	lw	$a0, 12($sp)		#	$a0 now = middle address of array
	lw	$a1, 8($sp)		#	$1 now = last address of array
	
	jal	mergesort		#	recursive function of the second half of array
	
	lw	$a0, 4($sp)		#	$a0 now = first address of array
	lw	$a1, 12($sp)		#	$a1 now = middle address of array
	lw	$a2, 8($sp)		#	$a2 now = last address of array
	
#	merge 	
		
	add 	$t3, $zero, $a0		#	$t3 = temporary of $a1 (so we can take value of the address without changing it)
	add 	$t4, $zero, $a1		#	$t4 = temporary of $a2 (so we can take value of the address without changing it)
	
comparewhile:				
#	compare the two element (which is lower got to be put in the stack)
	lw 	$t1, 0($t3)		# 	$t1 = value of $t3 
	lw 	$t2, 0($t4)		#	$t2 = value of $t4
	beq	$t3, $a1, endfirsthalf	#	if $t3 reach the middle address of array ($a1) -> end of first half
	beq	$t4, $a2, endsecondhalf	#	if $t4 reach the last address of array ($a2) -> end of second half
	
	slt 	$at, $t1, $t2		#
	bne 	$at, $0	, lower		#	convert blt $t1, $t2, lower to standard mips
#	blt	$t1, $t2,lower		# 	if $t1 < $t2 -> put $t1 in the stack (*lower)

	b	higher			#	else put $t2 in the stack (*higher)

#	sort 2 section
lower:
	addi 	$sp, $sp, -4		#	adjust stack pointer
	lw 	$t1, 0($t3)		#	take the value $t1
	sw 	$t1, 0($sp)		#	put $t1 in the stack
	addi 	$t3, $t3, 4		#	$t3++
	j	comparewhile		#	loop to comparewhile

higher:
	addi 	$sp, $sp, -4		#	adjust stack pointer
	lw 	$t2, 0($t4)		#	take the value $t2
	sw 	$t2, 0($sp)		#	put $t2 in the stack
	addi 	$t4, $t4, 4		#	$t4++
	j	comparewhile		#	loop to comparewhile
	
#	in case any half is done we dont need to compare 2 part anymore we put the other one to stack without compare
endfirsthalf:
#	after putting all the $t1 in the stack we got to put the remaining $t2 in the stack
	beq	$t4, $a2, endbothhalf	#	if $t4 reach the last address ($a2) we are done taking them in the stack
	lw 	$t2, 0($t4)		#	take the value $t2
	addi	$sp, $sp, -4		#	adjust stack pointer
	sw	$t2, 0($sp)		#	put $t2 in the stack
	addi 	$t4, $t4, 4		#	$t4++
	j 	endfirsthalf		#	loop to endfirsthalf
	
endsecondhalf:
#	after putting all the $t2 in the stack we got to put the remaining $t1 in the stack
	beq 	$t3, $a1,endbothhalf	#	if $t3 reach the middle address ($a1) we are done taking them in the stack
	lw 	$t1, 0($t3)		#	take the value $t1
	addi 	$sp, $sp,-4		#	adjust stack pointer
	sw	$t1, 0($sp)		#	put $t1 in the stack
	addi 	$t3, $t3,4		#	$t3++
	j 	endsecondhalf		#	loop to endsecondhalf
	
endbothhalf:
#	after putting all in the stack we have to return them to the array
	sub	$t5, $a2, $a0		#	$t5 = size of the array we are targeting * 4
	add 	$sp, $sp, $t5		#	adjust the stack pointer before we return them to array
	add 	$t1, $zero, $a0		#	$t1(address of array we are targeting)

returnloop:
	beq 	$t5, $0, exit		# 	if $t5 <= 0 ->we are done returning the element to the array -> exit
	addi 	$sp, $sp,-4		# 	adjust the stack pointer
	lw 	$t6, 0($sp)		#	$t6 = value the stack points to
	sw 	$t6, 0($t1)		#	return $t6 to the array
	addi	$t1, $t1,4		#	$t1++ (arr++)
	addi 	$t5, $t5,-4		# 	$t5--
	j	returnloop		#	loop to returnloop
	
exit:
#	after done returning the value, we print all the aftermath
	sub	$t5, $a2, $a0		#	$t5 = size of array we are targeting
	add 	$sp, $sp, $t5		#	adjust stack pointer
######	
	addi 	$t7, $0, 0		#	$t7 = 0	 (counter for print loop)	
	move 	$a3, $a0 		#	$a3 = first address of array
	srl 	$t5, $t5, 2		#	$t5=$t5/4 for print
printloop:

	beq	$t7, $t5, endprintloop	# 	if $t7 = $t9 (t7 = number of elements) -> endprintloop
	lw 	$t8, 0($a3)		#	$t8 = value of the address
	addi 	$v0, $zero,1		#
	move 	$a0, $t8		#	print value
	syscall				#
	addi 	$a3, $a3,4		#	$a3++
	addi 	$t7, $t7,1		#	$t7++
	addi 	$v0, $zero,4		#	
	la 	$a0, dis		#	print " "
	syscall
	
	j printloop			#	loop to printloop
	

endprintloop:
#	after printing all the element we begin a new line (print "\n")
	sll 	$t5, $t5, 2		# 	t5= t5 * 4 for return size array
	addi 	$v0, $zero,4
	la 	$a0, N
	syscall

mergesortend:
	lw 	$ra, 0($sp)
	addi 	$sp, $sp,16
	jr 	$ra
#	END MERGESORT FUNC