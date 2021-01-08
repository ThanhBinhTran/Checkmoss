.data
	topic: .asciiz "Sap xep mang 20 phan tu theo kieu Quicksort\n"
	truoc: .asciiz "Mang chua sap xep:\n"
	sau: .asciiz "Mang da sap xep:\n"
	num: .word 20
	arr: .word 453 7  645 7 -546 0 -547 34546 768 234 245 657 2343 2325 67 576 345 243 -45657 4657
	space: .asciiz " "
	endline: .asciiz "\n"
	buoc: .asciiz "Trang thai hien tai cua mang:\n"
.text
	.globl main
main:
	lw $a1, num
	la $a0, topic
	li $v0, 4
	syscall
	la $a0, truoc
	li $v0, 4
	syscall
	jal xuat
	la $a0, endline
	li $v0, 4
	syscall	
	addi $s0, $0, 0
	addi $s1, $a1, -1
	jal quicksort
	la $a0, sau
	li $v0, 4
	syscall
	jal xuat
	j exit
quicksort: 
	# $s0 - lowindex (l)
	# $s1 - highindex (h)
	# $s2 - partitionindex (p)
	# $s3 - pivot
	# $a1 - num
	# $a2 - arr
	# Store lowindex, highindex, partitionindex to Stack Pointer ($sp) of each recursive
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $ra, 12($sp)
	# if(low >= high) goto endquicksort
	slt $t9, $s0, $s1
	beq $t9, $0, endquicksort
	# asign i = -1
	addi $s2, $s0, -1
	# $s3: pivot = arr[h]
	sll $s3, $s1, 2
	add $s3, $s3, $a2
	lw $s3, 0($s3)
	##############
	la $a0, buoc
	li $v0, 4
	syscall
	jal xuat
	la $a0, endline
	li $v0, 4
	syscall
	#################
	addi $t0, $s0, 0	# j=low
partition:
	# if(j > h) goto endpartition
	slt $t9, $s1, $t0
	bne $t9, $0, endpartition
	# $t1 = arr[j]
	sll $t1, $t0, 2
	add $t1, $t1, $a2
	lw $t1, 0($t1)
	
	slt $t9, $s3, $t1
	beq $t9, $0, swap
	beq $t0, $s1, swap	# if(i==h) goto swap
	# j++
	addi $t0, $t0, 1
	j partition
swap:
	# i++
	addi $s2, $s2, 1
	# load temp value to $t3
	sll $v0, $t0, 2
	add $v0, $v0, $a2
	lw $t3, 0($v0)
	# load temp value to $t5
	sll $v1, $s2, 2
	add $v1, $v1, $a2
	lw $t5, 0($v1)

	sw $t3, 0($v1)
	sw $t5, 0($v0)
	
	addi $t0, $t0, 1
	j partition
endpartition:
	# recursive quicksort left
	addi $s1, $s2, -1
	lw $s0, 0($sp)
	jal quicksort
	# recursive quicksort right
	addi $s0, $s2, 1
	lw $s1, 4($sp)
	jal quicksort
endquicksort:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	
	jr $ra
xuat:
	addi $t0, $0, 0
	la $a2, arr
	for:
		beq $t0, $a1, endfor
		sll $t2, $t0, 2
		add $t2, $t2, $a2
		lw $t2, 0($t2)
		addi $a0, $t2, 0
		li $v0, 1
		syscall
		la $a0, space
		li $v0, 4
		syscall
		addi $t0, $t0, 1
		j for
	endfor:
		jr $ra
exit:
	li $v0, 10
	syscall