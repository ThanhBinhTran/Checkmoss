	.data
colon:	.asciiz ": "			
start:	.asciiz "\n Array before in-place merge sort:\n"
end:	.asciiz "\n Array after in-place merge sort:\n"
separator:	.asciiz "|| "
length:	.word	20

a1:	.word	0
a2:	.word	0
a3:	.word	0
a4:	.word	0
a5:	.word	0
a6:	.word	0
a7:	.word	0
a8:	.word	0
a9:	.word	0
a10:	.word	0
a11:	.word	0
a12:	.word	0
a13:	.word	0
a14:	.word	0
a15:	.word	0
a16:	.word	0
a17:	.word	0
a18:	.word	0
a19:	.word	0
a20:	.word	0

Arr:	.word	a1, a2, a3, a4, a5,
		a6, a7, a8, a9, a10,
		a11, a12, a13, a14, a15,
		a16, a17, a18, a19, a20

	.text
main:	jal	getInput		# input
	
	li	$t4, 0		# count 		
	
	li	$v0, 4		# print before sorting
	la	$a0, start
	syscall
  	jal	printArray

  	li   	$a0, '\n'
	li   	$v0, 11
	syscall
	
	la	$a0, Arr		# Arr.start
	lw	$t0, length		# Arr.length
	sll	$t0, $t0, 2		# Arr.length *= 4
	add	$a1, $a0, $t0		# Arr.end
	jal	mergeSort		
	
	li	$v0, 4		# print after sorting
	la	$a0, end
	syscall
  	jal	printArray
  	
  	li	$v0, 10		# terminate prog.
  	syscall
##
# $a0 is the first address of the array
# $a1 is the last address of the array
##

mergeSort:

	addi	$sp, $sp, -16		
	sw	$ra, 0($sp)		# stack += ra
	sw	$a0, 4($sp)		# stack += Arr.start
	sw	$a1, 8($sp)		# stack += Arr.end
	
	sub 	$t0, $a1, $a0		# t0 = Arr.end - Arr.start
	
	
	addi	$t8, $0, 5		# if (1 element) return
	slt	$t7, $t0, $t8
	bne	$t7, $0, mergeSortEnd
	
	
	div	$t0, $t0, 8		
	mul	$t0, $t0, 4		
	
	add	$a1, $a0, $t0		# Arr.mid
	
	sw	$a1, 12($sp)		# stack += Arr.mid
	
	jal	mergeSort		# sort on the fisrt half of the array
	
	lw	$a0, 12($sp)		
	lw	$a1, 8($sp)		
	
	jal	mergeSort		# sort on the second half of the array
	
	lw	$a1, 12($sp)		
	lw	$a2, 8($sp)		
	lw	$a0, 4($sp)			
	jal	merge		# merge two halves
	
mergeSortEnd:
	lw	$ra, 0($sp)		
	addi	$sp, $sp, 16		
	jr	$ra			
	

merge:
	addi	$sp, $sp, -16		
	sw	$ra, 0($sp)		
	sw	$a0, 4($sp)		
	sw	$a1, 8($sp)		
	sw	$a2, 12($sp)		
	
	move	$s0, $a0		
	move	$s1, $a1		
	
mergeLoop:

	lw	$t0, 0($s0)		
	lw	$t1, 0($s1)		
	lw	$t0, 0($t0)		
	lw	$t1, 0($t1)		
	
	
	addi	$t8, $t1, 1
	slt	$t7, $t0, $t8
	bne	$t7, $0, noShift
	
	move	$a0, $s1		
	move	$a1, $s0		
	jal	shift			 
	
	addi	$s1, $s1, 4		
	
noShift:
	addi	$s0, $s0, 4		
	
	lw	$a2, 12($sp)		
	
	slt 	$t7, $s0, $a2
	beq	$t7, $0, mergeLoopEnd	
	
	slt 	$t7, $s1, $a2
	beq	$t7, $0, mergeLoopEnd	
	
	j	mergeLoop
	
mergeLoopEnd:
	jal 	printArray

	lw	$ra, 0($sp)		
	addi	$sp, $sp, 16		
	
	jr 	$ra			

shift:
	li	$t0, 10
	
	slt	$t7, $a1, $a0
	beq	$t7, $0, shiftEnd	
	
	addi	$t6, $a0, -4		
	lw	$t7, 0($a0)		
	lw	$t8, 0($t6)		
	sw	$t7, 0($t6)		
	sw	$t8, 0($a0)		
	move	$a0, $t6		
	
	j 	shift			
shiftEnd:
	jr	$ra			
	
printArray:
	addi	$sp, $sp, -20		
	sw	$t0, 0($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)
	sw	$t3, 12($sp)
	sw 	$a0, 16($sp)
	
	li	$t0, 0			
printLoop:

	beq	$t4, 0, continuePrintNumber
	beq	$t4, 20, continuePrintNumber

	bne	$t4, 1, next2
	beq	$t0, 0, print
	beq	$t0, 2, print
	j	continuePrintNumber
next2:	bne	$t4, 2, next3
	beq	$t0, 3, print
	beq	$t0, 5, print
	j	continuePrintNumber
next3:	bne	$t4, 3, next4
	beq	$t0, 2, print
	beq	$t0, 5, print
	j	continuePrintNumber
next4:	bne	$t4, 4, next5
	beq	$t0, 0, print
	beq	$t0, 5, print
	j	continuePrintNumber
next5:	bne	$t4, 5, next6
	beq	$t0, 5, print
	beq	$t0, 7, print
	j	continuePrintNumber
next6:	bne	$t4, 6, next7
	beq	$t0, 8, print
	beq	$t0, 10, print
	j	continuePrintNumber
next7:	bne	$t4, 7, next8
	beq	$t0, 7, print
	beq	$t0, 10, print
	j	continuePrintNumber
next8:	bne	$t4, 8, next9
	beq	$t0, 5, print
	beq	$t0, 10, print
	j	continuePrintNumber
next9:	bne	$t4, 9, next10
	beq	$t0, 0, print
	beq	$t0, 10, print
	j	continuePrintNumber
next10:	bne	$t4, 10, next11
	beq	$t0, 10, print
	beq	$t0, 12, print
	j	continuePrintNumber
next11:	bne	$t4, 11, next12
	beq	$t0, 13, print
	beq	$t0, 15, print
	j	continuePrintNumber
next12:	bne	$t4, 12, next13
	beq	$t0, 12, print
	beq	$t0, 15, print
	j	continuePrintNumber
next13:	bne	$t4, 13, next14
	beq	$t0, 10, print
	beq	$t0, 15, print
	j	continuePrintNumber
next14:	bne	$t4, 14, next15
	beq	$t0, 15, print
	beq	$t0, 17, print
	j	continuePrintNumber
next15:	bne	$t4, 15, next16
	beq	$t0, 18, print
	beq	$t0, 20, print
	j	continuePrintNumber
next16:	bne	$t4, 16, next17
	beq	$t0, 17, print
	beq	$t0, 20, print
	j	continuePrintNumber
next17:	bne	$t4, 17, next18
	beq	$t0, 15, print
	beq	$t0, 20, print
	j	continuePrintNumber
next18:	bne	$t4, 18, next19
	beq	$t0, 10, print
	beq	$t0, 20, print
	j	continuePrintNumber
next19:	bne	$t4, 19, continuePrintNumber
	beq	$t0, 0, print
	beq	$t0, 20, print
	j	continuePrintNumber
print:
	la   	$a0, separator
	li   	$v0, 4
	syscall
	
continuePrintNumber:				
	lw	$t1, length		
	
	slt	$t7, $t0, $t1
	beq	$t7, $0, printDone	

	sll	$t2, $t0, 2		
	
	lw	$t3, Arr($t2)		
	lw	$a0, 0($t3)		
	li	$v0, 1			
	syscall					
	
	li   	$a0, ' '			
	li   	$v0, 11
	syscall
	
	addi	$t0, $t0, 1			
	j	printLoop
printDone:
	li   	$a0, '\n'
	li   	$v0, 11
	syscall	

	lw 	$a0, 16($sp)
	lw	$t3, 12($sp)
	lw	$t2, 8($sp)
	lw	$t1, 4($sp)	
	lw	$t0, 0($sp)
	addi	$sp, $sp, 20			
	
	addi	$t4, $t4, 1
	jr	$ra
	
getInput:
	li	$t0, 0				
inputLoop:
	lw	$t1, length			
	
	slt	$t7, $t0, $t1
	beq	$t7, $0, inputDone		
	
	li	$v0, 1				
	move	$a0, $t0
	addi	$a0, $a0, 1
	syscall
	
	li	$v0, 4				
	la	$a0, colon
	syscall
	
	sll	$t2, $t0, 2
	lw	$t3, Arr($t2)			
	
	li	$v0, 5				
	syscall
	sw	$v0, 0($t3)			

	addi	$t0, $t0, 1			
	j	inputLoop

inputDone:	
	jr	$ra


