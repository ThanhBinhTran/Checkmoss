.data
	in0: .asciiz "Enter N: "
	space: .asciiz " "
.text
main:
	li $v0, 4 
	la $a0, in0 
	syscall 
	
	li $v0, 5
	syscall
	add $a1 , $v0, $0 #a1 = N
	
	beq $a1, 0, Out0
	beq $a1, 1, Out1
	beq $a1, 2, Out1
	slt $t9, $a1, $0
	beq $t9, 1, Out0
	addi $a1 , $a1, 1
	
	addi $t0, $t0, 0
	addi $t1, $t1, 1
	addi $t2, $t2, 2
	
Loop: 
	slt $s0, $t2, $a1
	beq $s0, 0, Outz
	
	addu $t3, $t1, $t0
	move $t0, $t1
	move $t1, $t3
	addi $t2 , $t2, 1
	j Loop
	
Outz: 	
	li $v0, 1
	la $a0, ($t3)
	syscall
	j Exit	
Out0:
	li $v0, 1
	addi $a0, $0, 0
	syscall
	j Exit
Out1:
	li $v0, 1
	addi $a0, $0, 1
	syscall
	j Exit

Exit:
