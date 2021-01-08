.data
	s1: .word 0
	s2: .word 0
	InputA: .asciiz "Nhap so thu nhat: "
	InputB: .asciiz "Nhap so thu hai: "
	InputOp: .asciiz "1.Phep cong nhap 0\n2.Phep tru nhap 1\nChon phep tinh: "
	newline: .asciiz "\n"
	#op: .word 1		# op == 0 -> add	op == 1 -> sub 
	
.text
	# s0 = A	s2 = B
	# xu li input
	la $s0, s1
	la $s2, s2
	li $v0, 4
	la $a0, InputA
	syscall
	li $v0, 6
	syscall
	swc1 $f0,0($s0)
	li $v0, 4
	la $a0, InputB
	syscall
	li $v0, 6
	syscall
	swc1 $f0,0($s2)
	li $v0, 4
	la $a0, InputOp
	syscall
	li $v0, 5
	syscall
	add $s1, $v0, $0
	#t1: op numA	t2: exp numA	t3: abs numA	t4:op numB	t5: exp numB	t6: abs numB	t7: numA	t8: numB
	#t9: temp	s1: op		s7: abs result	$s6: exp result	$s5: op result	$s4: result
	# handle num
	# get num:
	lw $t7, 0($s0)	
	lw $t8, 0($s2)
	beq $s1,0,reset
	li $s1,0
	srl $t4, $t8, 31
	not $t4, $t4
	sll $t4, $t4,31
	sll $t9, $t8, 1
	srl $t9, $t9, 1
	add $t8, $t9,$t4
	sw $t8,0($s2)
reset:
	# get op:
	srl $t1, $t7, 31
	srl $t4, $t8, 31
	# get exp:
	sll $t2, $t7, 1
	srl $t2, $t2, 24
	sll $t5, $t8, 1
	srl $t5, $t5, 24
	# get abs:
	sll $t3, $t7, 9
	srl $t3, $t3, 9
	sll $t6, $t8, 9
	srl $t6, $t6, 9
	addi $t3, $t3, 0x00800000
	addi $t6, $t6, 0x00800000
	# arrange
	slt $t9, $t2, $t5			
	bne $t9, $0, reload		# if(expA < expB) reload
	slt $t9, $t5, $t2
	bne $t9, $0, shif_ABS_B		# if(expB < expA) shif_ABS_B
	slt $t9, $t3, $t6		# expA == expB
	beq $t9, $0, continue1		# if(absA >= absB) continue
reload:	
	lw $t7, 0($s2)	
	lw $t8, 0($s0)
	j reset
shif_ABS_B:
	sub $t9, $t2, $t5
	srlv $t6, $t6, $t9
continue1:
	add $s6, $0, $t2	#set exp resutl
	# set opABS = t0
	add $a0, $0, $t1 
	add $a1, $0, $t4
	jal func
	add $a0, $0, $t0 
	add $a1, $0, $s1
	jal func
	bnez  $t0, Sub
	add $s7, $t3, $t6
	srl $t9, $s7, 24
	beqz $t9, continue2
	addi $s6, $s6, 1
	srl $s7, $s7, 1
	j continue2
Sub:	sub $s7, $t3, $t6
	# s3 = so bit dich
	li $s3, 0
	li $t9, 0x00800000
while:	and $a3, $s7, $t9
	bnez $a3, endwhile
	addi $s3, $s3, 1
	srlv $t9, $t9, $s3
	j while
endwhile:
	sllv $s7, $s7, $s3
	sub $s6, $s6, $s3
continue2:
	sll $s7, $s7, 9
	srl $s7, $s7, 9
	add $s5, $0, $t1
	sll $s5, $s5, 31
	sll $s6, $s6, 23
	add $s4, $s5, $s6
	add $s4, $s4, $s7
	
	li $v0, 2
	mtc1 $s4, $f12
	syscall		
	li $v0,10
	syscall
func:
	sub $t0, $a0, $a1
	beqz $t0, setone
	li $t0, 0
	j next
setone:	li $t0, 1
next:	jr $ra
