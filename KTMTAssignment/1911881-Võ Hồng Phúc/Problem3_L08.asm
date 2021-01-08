#1911881 VoHongPhuc
#1911185 TruongHongHoa
#1912267 DinhLeTran


.data
	Nhap1: .asciiz "Nhap so thuc 1: "
	Nhap2: .asciiz "Nhap so thuc 2: "
	Over: .asciiz "Overflow"
	Under: .asciiz "Underflow"
.text
	li $v0, 4
	la $a0, Nhap1
	syscall
	li $v0, 6
	syscall
	mov.s $f1, $f0
	mfc1 $t0, $f1
	
	li $v0,4
	la $a0, Nhap2
	syscall
	li $v0, 6
	syscall
	mov.s $f2, $f0
	mfc1 $a0, $f2

#exception
	beq		$t0, 0, result		
	beq		$a0, 0, result

	sll    $t1, $t0, 9        #t1 holds fraction par
	sll    $t2, $t0, 1
	srl    $t2, $t2, 24      #t2 holds exponent par
	addi   $t2, $t2, -127
	srl    $t3, $t0, 31       #t3 holds the sign bit
	sll		$a1, $a0, 9
	sll		$a2, $a0, 1
	srl		$a2, $a2, 24
	addi	$a2, $a2, -127
	srl		$a3, $a0, 31
#tinh sign				
	xor $t6, $t3, $a3		
#tinh bias
	add $t7, $t2, $a2
	addi $t7, $t7, 127		
#add 1 vô frac
	srl 	$t1, $t1, 1
	addi 	$t1, $t1, 0x80000000
	srl 	$a1, $a1, 1
	addi 	$a1, $a1, 0x80000000
#multiple frac
	mulu  $t8, $t1, $a1
#chuan hoa bit
	mfhi $s0
	bleu $s0, 0x7fffffff, result
	addi $t7, $t7, 1
	bgt $t7, 254, over
	blt $t7, 1, under	
	srl $s0, $s0, 1			
result:
	sll $s0, $s0, 2
	srl $s0, $s0, 9
	sll $t6, $t6, 31
	sll $t7, $t7, 23 
	add $t6, $t6, $t7
	add $t6, $t6, $s0
		mtc1 $t6, $f12
		li $v0, 2
		syscall
	j exit
over:
	la $a0, Over
	lw $a0, 0($a0)
	li $v0, 4
	syscall
	j exit
under:
	la $a0, Under
	lw $a0, 0($a0)
	li $v0, 4
	syscall
	j exit
exit:
