.data
	in0: .asciiz "Enter input: "
	inb: .asciiz "Enter b: "
	inc: .asciiz "Enter c: "
	out0: .asciiz "a = b + c = " 
	out1: .asciiz "a = b - c = "
	out2: .asciiz "a = b * c = "
	out3: .asciiz "a = b / c = "
	out4: .asciiz "Default a = "
.text
main:
	li $v0, 4 
	la $a0, in0 
	syscall 
	
	li $v0, 5
	syscall
	add $a3 , $v0, $0 #a3 = input
	
	li $v0, 4 
	la $a0, inb
	syscall 
	
	li $v0, 5
	syscall
	add $a1 , $v0, $0 #a1 = b
	
	li $v0, 4 
	la $a0, inc
	syscall 
	
	li $v0, 5
	syscall
	add $a2 , $v0, $0 #a2 = c
	
	addi $t1, $t1, 1
	addi $t2, $t2, 2
	addi $t3, $t3, 3
	addi $t4, $t4, 4
	
	beq $a3, $t1, Out1
	beq $a3, $t2, Out2
	beq $a3, $t3, Out3
	beq $a3, $t4, Out4

	li $v0, 4 
	la $a0, out4 
	syscall 
	
	add $a2, $0, $0
	li $v0, 1
	add $a0, $a2, $0	
	syscall 
	j Exit
Out1:
	li $v0, 4 
	la $a0, out0 
	syscall 
	
	li $v0, 1
	add $a0, $a1, $a2
	syscall
	j Exit

Out2: 
	li $v0, 4 
	la $a0, out1 
	syscall 
	
	li $v0, 1
	sub $a0, $a1, $a2
	syscall
	j Exit

Out3:
	li $v0, 4 
	la $a0, out2 
	syscall 
	
	li $v0, 1
	mul $a0, $a1, $a2
	syscall
	j Exit


Out4:
	li $v0, 4 
	la $a0, out3 
	syscall 
	
	li $v0, 1
	div $a0, $a1, $a2
	syscall
	j Exit
Exit:	
	
	