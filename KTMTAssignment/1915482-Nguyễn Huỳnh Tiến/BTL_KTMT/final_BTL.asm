######################################################################################
##################################### Merge Sort #####################################
######################################################################################
.data
    	myarray: .word 20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
    	str: .asciiz "Input array: "
    	s0: .word 1:20
    	s1: .word 1:20
.text    
    	li $v0, 4    		# cout << "Input array: ";
    	la $a0, str
    	syscall
    	la $t8, myarray		
    	addi $t7, $0, 20
    	jal print
    
    	#la $a0, numArray
    	la $a0, myarray		# load address of the first element
    	addi $a1, $a0, 76	# load address of the last element
    	jal mergesort
    	li $v0, 10
    	syscall

mergesort: 
   	addi $sp, $sp, -16 
   	sw $ra, 0($sp) 		# store the return address
   	sw $a0, 4($sp)  	# store the array start address respectively the left
   	sw $a1, 8($sp)  	# store the array end address respectively the right 
   	##
   	sub $t0, $a1, $a0 	# $t0 = r - l
   	slt $t9, $0, $t0 	# $t9
   	beq $t9, 0, return_mergesort # if r - l <= 0 (0 byte) return ### da chinh
   	# calculate middle address
   	srl $t0, $t0, 3   	# (r-l)/2
   	sll $t0, $t0, 2
   	add $a1, $t0, $a0   	# l+(r-l)/2 = address of middle
   	sw $a1, 12($sp) 	# store the array middle address
   
   	jal mergesort 		# recursively call on the first half of the array
   
   	# prepare for the next mergesort call
   	lw $a0, 12($sp) 	# load middle address
   	addi $a0, $a0, 4  	# middle + 1
   	lw $a1, 8($sp)  	# load address of the last element
   
   	jal mergesort 		# recursively call on the second half of the array
   
   	# prepare for merge call
   	lw $a0, 4($sp) 		# load address of the first element
   	lw $a1, 12($sp) 	# load the middle address
   	lw $a2, 8($sp)  	# load address of the last element
   	##
   	jal merge                   
	add $t7, $t1, $t2
        srl $t7, $t7, 2
        jal print
  	return_mergesort:
     	lw $ra , 0($sp) 	# restore return address
     	addi $sp, $sp, 16 	# pop the stack
     	jr $ra  		# return
     
merge:  
   	addi $sp, $sp, -16 	# adjust the stack
   	sw $ra, 0($sp)		# store the return address
   	sw $a0, 4($sp)		# store the start address
   	sw $a1, 8($sp)		# store the midpoint address
   	sw $a2, 12($sp)		# store the end address
   	addi $t8, $a0, 0	# store orginal address
   	# $t1 = n1 = m - l + 1 is the number of elements of the first half
   	sub $t1, $a1, $a0
   	addi $t1, $t1, 4
   
   	# $t2 = n2 = r - m is the number of elements of the second half
   	sub $t2, $a2, $a1
   
   	# create arrays $s0 and $s1
   	# $t3 = i = 0, $t4 = j = 0
   	addi $t3, $0, 0
   	addi $t4, $0, 0
   	la $s0, s0
   	la $s1, s1
	addi $a1, $a1, 4 
loop_copy1:
	slt $t9, $t3, $t1	# $t9
	beq $t9, 0, exit_copy1
	add $s5, $a0, $t3
	lw $t5, 0($s5)
	sw $t5, 0($s0)
	addi $s0, $s0, 4
	addi $t3, $t3, 4
	j loop_copy1
exit_copy1:

loop_copy2:
	slt $t9, $t4, $t2      # $t9
	beq $t9, 0, exit_copy2
	add $s5, $a1, $t4
	lw $t5, 0($s5)
	sw $t5, 0($s1)
	addi $s1, $s1, 4
	addi $t4, $t4, 4
	j loop_copy2
exit_copy2:
	la $s0, s0
   	la $s1, s1
	addi $t3, $0, 0
   	addi $t4, $0, 0 
loop1:
	slt $t5, $t3, $t1
	slt $t6, $t4, $t2
	add $t0, $t5, $t6
	bne $t0, 2, exit_loop1
   	
   	lw $s2, 0($s0)		# $s2 = L[i]
   	lw $s3, 0($s1)		# $s3 = R[j]
   	slt $t9, $s3, $s2	# $t9
   	beq $t9, 1, else_loop1
	sw $s2, 0($a0)
	addi $s0, $s0, 4
	addi $t3, $t3, 4
	j end_compare
else_loop1:
	sw $s3, 0($a0)
	addi $s1, $s1, 4
	addi $t4, $t4, 4
end_compare:
	addi $a0, $a0, 4
   	j loop1
exit_loop1:

loop2:
	lw $s2, 0($s0)		# $s2 = L[i]
	slt $t9, $t3, $t1	# $t9
	beq $t9, 0, exit_loop2
	sw $s2, 0($a0)
	addi $t3, $t3, 4
	addi $a0, $a0, 4
	addi $s0, $s0, 4
	j loop2
exit_loop2:

loop3:
   	lw $s3, 0($s1)		# $s3 = R[j]
   	slt $t9, $t4, $t2
	beq $t9, 0, exit_loop3
	sw $s3, 0($a0)
	addi $t4, $t4, 4
	addi $a0, $a0, 4
	addi $s1, $s1, 4
	j loop3
exit_loop3:
        
	lw $ra, 0($sp) 		# restore return address
     	addi $sp, $sp, 16 	# pop the stack
     	jr $ra  		# return
print:
    	add $t1, $0, $t8	# load the start address 
    	addi $t2, $0, 0  	# i = 0
loop:
	slt $t9, $t2, $t7
        beq $t9, 0, exit1
        lw  $t3, 0($t1)
        addi $t1, $t1, 4
        li $v0, 1      		# print integer
        move $a0, $t3
        syscall
        addi $a0, $0, ' '
        li $v0, 11
        syscall
        addi $t2, $t2, 1 	# counter
        j loop
exit1: 
        addi $a0, $0, '\n'
        li $v0, 11
        syscall
        jr $ra
