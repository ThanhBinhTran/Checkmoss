.data
	strIn: .asciiz "Computr Architecture CSE-HCMUT"
	strOut: .asciiz "Find e in the string? \n"
.text
main:
	la $a1, strIn
	add $t8, $0 , $0
	
Loop:	
	lb $t9, 0($a1)
	beq $t9, '\0', Ex
	beq $t9, 'e' , Exit
	addi $a1, $a1, 1
	addi $t8, $t8, 1
	j Loop
	
Ex:  	addi $t8 , $0 , -1

	
Exit:   	
	li $v0, 4 
	la $a0, strOut 
	syscall 
	
	li $v0, 1
	add $a0, $t8, $0
	syscall
