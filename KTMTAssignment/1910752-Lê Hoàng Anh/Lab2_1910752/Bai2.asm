.data
	in0: .asciiz "Enter a: "
	in1: .asciiz "Enter b: " 
	in2: .asciiz "Enter c: "
	out0: .asciiz "a = b * c = "
	out1: .asciiz "a = b + c = "
.text
main:
	li $v0, 4 
	la $a0, in0 
	syscall 
	
	li $v0, 5
	syscall
	add $a1 , $v0, $0 #a1 = a
	
	li $v0, 4 
	la $a0, in1 
	syscall 
	
	li $v0, 5
	syscall
	add $a2 , $v0, $0 #a2 = b
	
	li $v0, 4 
	la $a0, in2
	syscall 
	
	li $v0, 5
	syscall
	add $a3 , $v0, $0 #a3 = c
	
	addi $t5, $t5 , -5 #t5 = -5
	addi $t3, $t3 , 3 #t3 = 3
	addi $t0, $0, 1 #t0 = 1
	
	slt $s0, $a1, $t5 #if a > -5
	slt $s1, $t3, $a1 #if a < 3
	
	beq $s0, $t0, true
	beq $s1, $t0, true
	beq $a1, $t3, true
	
	li $v0, 4 
	la $a0, out1 
	syscall 
	
	add $a1, $a2, $a3	
	li $v0, 1
	add $a0, $a1, $0
	syscall
	j Exit
	
true:  	
	li $v0, 4 
	la $a0, out0 
	syscall 
	
	mul $a1, $a2, $a3
	li $v0, 1
	add $a0, $a1, $0	
	syscall 
Exit:
	
	