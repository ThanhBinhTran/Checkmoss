.data
msgIn: .asciiz "input array:"
msgOut: .asciiz "\n\noutput array:"
step: .asciiz "\nstep: "
comma: .asciiz ", "
s1: .asciiz "\nstart = "
s2: .asciiz "end = "
s3: .asciiz "pivot = "
t1: .asciiz "\npivot position = "
lf: .asciiz "\n"

array: .word 12, 15, 10, 5, 7, 3, 2, 1, 31, 46, 172, 208, 13, 93, 65, 112, 1449529, 17, 92, 0
#array: .word 1312, 219, -86, -5080, -38, 1413, 1990, -1612, -19, -50, 3, 0, 24, 1449529, 91, 260, 1, 20, 13, -160
#array: .word 1413, 1990, -1612, -19, -50, 91, 1312, 219, -86, -38, 260, 1, 20, 13, -160, 3, 0, 24, -5080, 1449529
#array: .word -38, 3, 1413, -160, 260, 13, -19, 1990, 24, -1612, 219, 0, 1, 20, -50, 91, -86, 1312, 1449529, -5080
#array: .word -5080, 1449529, -86, -50, 91, 260, -1612, -19, 3, 0, 24, -38, 1413, 1990, 1, 20, 13, -160, 1312, 219
#array: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
#array: .word -5080, -1612, -160, -86, -50, -38, -19, 0, 1, 3, 13, 20, 24, 91, 219, 260, 1312, 1413, 1990, 1449529
#array: .word -5080, 1312, -160, -86, -50, -38, -19, 0, 1, 3, 13, 20, 24, 91, 219, 260, 1449529, -1612, 1990, 1413
#array: .word 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
#array: .word -160, -5080, -86, -50, -38, -19, 0, 1, 3, 13, -1612, 20, 24, 91, 219, 260, 1312, 1413, 1990, 1449529

arraySize: .word 20

.text
main:
lw $a1, arraySize
la $s0, array

#initiation
li $s1, 0		#s1 = start
subi $s2, $a1, 1	#s2 = end
li $t0, 0
li $t3, 0
add $t4, $0, $s0
#end of initiation

la $a0, msgIn
li $v0, 4
syscall			#input prompt

showStep:
la $a0, step
li $v0, 4
syscall

move $a0, $t0
li $v0, 1
syscall

la $a0, lf
li $v0, 4
syscall

#output():
output:
lw $t5, 0($t4)

bgt $t6, $t5, next	#if array[i] > array[i+1]
addi $t7, $t7, 1	#check whether array is in order

next:
move $t6, $t5

move $a0, $t5
li $v0, 1
syscall

addi $t3, $t3, 1
beq $t3, $a1, exit

li $v0, 4
la $a0, comma
syscall

sll $t4, $t3, 2
add $t4, $s0, $t4
j output

exit:
addi $t0, $t0, 1
beq $t0, 1, sorting	#t0 ==1, first output
j continue		#t0 >1, sorting output
#end of output()

sorting:
la $a0, msgOut
li $v0, 4
syscall			#output prompt

quickSort:
bge $s1, $s2, rightWing

jal partition

leftWing:
subi $s2, $t1, 1
jal quickSort

rightWing:
addi $s1, $t1, 1
subi $s2, $a1, 1
j quickSort

#partition():
partition:
move $t1, $s1		#i = low
move $t2, $s1		#j = low

sll $t4, $s2, 2
add $t4, $t4, $s0
lw $s3, 0($t4)		#pivot = array[high]

forLoop:
beq $t2, $s2, end4	#if j == high -> exit for() loop

sll $t4, $t2, 2
add $t4, $t4, $s0
lw $t6, 0($t4)

if:
bge $t6, $s3, endIf	#if array[j] >= pivot, skip swap()
j swap			#if array[j] < pivot -> swap array[i] & array[j]
cont4Loop:
addi $t1, $t1, 1

endIf:
addi $t2, $t2, 1
j forLoop

swap:
sll $t3, $t1, 2
add $t3, $t3, $s0
lw $t5, 0($t3)

sll $t4, $t2, 2
add $t4, $t4, $s0
lw $t6, 0($t4)

sw $t5, 0($t4)
sw $t6, 0($t3)
blt $t2, $s2, cont4Loop	#continue for() loop
beq $t2, $s2, contEnd4	#end for() loop

end4:
j swap

contEnd4:
li $t3, 0
move $t4, $s0
lw $t6, 0($s0)
li $t7, 0
j showStep		#print array

continue:
la $a0, s1
li $v0, 4
syscall

move $a0, $s1
li $v0, 1
syscall

li $v0, 4
la $a0, comma
syscall

la $a0, s2
syscall

move $a0, $s2
li $v0, 1
syscall

la $a0, t1
li $v0, 4
syscall

move $a0, $t1
li $v0, 1
syscall

li $v0, 4
la $a0, comma
syscall

la $a0, s3
syscall

move $a0, $s3
li $v0, 1
syscall

la $a0, lf
li $v0, 4
syscall

beq $t7, $a1, end	#end sorting right after the array is in order

jr $ra			#end of partition()

end:
li $v0, 10
syscall
