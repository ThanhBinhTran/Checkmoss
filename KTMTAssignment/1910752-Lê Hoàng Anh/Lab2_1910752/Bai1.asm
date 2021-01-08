.data
	out0: .asciiz "Enter a number: "
	out1: .asciiz "Computer Science and Engineering, HCMUT" 
	out2: .asciiz "Computer Architecture 2020"
.text
main:
	li $v0, 4 
	la $a0, out0 
	syscall 
	
	li $v0, 5
	syscall
	add $a0 , $v0, $0
	
	addi $t0, $t0 , 2
	div $a0, $t0
	mfhi $t9	#Copy the remainder from register HI to $t1
	addi $t8, $t8, 1
	beq $t8, $t9, Print1 #If the remainder is equal to 1, jump to print
	beq $t9, -1, Print1 #If t0 is less than 0, remainder is -1, jump to print
	li $v0, 4
	la $a0, out2	 
	syscall
	j Exit
Print1:  
	li $v0, 4
	la $a0, out1	
	syscall 
Exit: