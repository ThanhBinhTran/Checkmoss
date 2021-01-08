# Chuong trinh cong tru 2 so thuc dang chuan voi do chinh xac don
# Input: 2 so thuc A, B
# Output: ket qua phep cong, tru 2 so thuc

################################# Data segment ###########################
.data
	nhapa: .asciiz "Nhap so thuc A: "
	nhapb: .asciiz "Nhap so thuc B: "
	kqcong: .asciiz "A + B = "
	kqtru: .asciiz "\nA - B = "
	loi: .asciiz "Loi! Gia tri nhap vuot nguong!"
	kqloi: .asciiz "!!!Ket qua vuot nguong !!!"
	
################################ Text segment #############################

.text
.globl main
main:
	la $a0, nhapa		# nhap A 
	li $v0, 4
	syscall
	li $v0, 6
	syscall
	mfc1 $s0, $f0 		# dua A vao $s0
	
	move $a0, $s0
	jal ktnhap		# kiem tra A
	
	la $a0, nhapb		# nhap B
	li $v0, 4
	syscall
	li $v0, 6
	syscall
	mfc1 $s1, $f0 		# dua B vao $s1
	
	move $a0, $s1
	jal ktnhap		# kiem tra B
	
	move $a1, $s0
	move $a2, $s1
	
	# thuc hien phep cong
	la $a0, kqcong	
	li $v0, 4
	syscall
	
	li $a3, 0		# tinh A + B
	jal tinhtoan
	
	bnez $v1, congloi	# kiem tra ket qua
	mtc1 $v0, $f12		# in ket qua
	li $v0, 2
	syscall

congloi:	
	# thuc hien phep tru
	la $a0, kqtru	
	li $v0, 4
	syscall
	
	li $a3, 1		# tinh A - B
	jal tinhtoan
	
	bnez $v1, truloi	# kiem tra ket qua
	mtc1 $v0, $f12		# in ket qua
	li $v0, 2
	syscall

truloi:
	li $v0, 10		# ket thuc chuong trinh
	syscall
	
	
	
############################## ham kiem tra ################################################
ktnhap:				# ham kiem tra so thuc $a0 co nam trong nguong cho phep hay khong
	li $t0, 255
	sll $t1, $a0, 1
	srl $t1, $t1, 24	# dua exponent cua so thuc vao $t1
	bne $t1, $t0, hople	# kiem tra so thuc
	
	la $a0, loi		# hien thi thong bao loi
	li $v0, 4
	syscall
	li $v0, 10		# dung chuong trinh
	syscall
hople:
	jr $ra			# ket thuc ham
	
	
	
############################# ham tinh toan ###############################################
tinhtoan:			# A = $a1, B = $a2, $a3 quyet dinh phep toan (0 -> cong, 1 -> tru)
	
	beqz $a2, Bzero		# kiem tra B = 0
	beqz $a1, Azero		# kiem tra A = 0
	
	# lay bit dau:	A -> $t2 ; B -> $t5
	srl $t2, $a1, 31	# dua bit dau cua A vao $t2
	
	srl $t5, $a2, 31	# dua bit dau cua B vao $t5
	
	beqz $a3, tieptuc	# kiem tra phep toan
	
	xor $t5, 1		# doi dau cua B de thuc hien phep tru
	
tieptuc:
	# lay exponent:	A -> $t3 ; B -> $t6
	sll $t3, $a1, 1
	srl $t3, $t3, 24	# dua exponent cua A vao $t3
	
	sll $t6, $a2, 1
	srl $t6, $t6, 24	# dua exponent cua B vao $t6
	
	# lay fraction + 1:	A -> $t4 ; B -> $t7
	li $t0, 1
	sll $t0, $t0, 23
	
	li $t4, 0
	beqz $a1, A0		# A = 0 -> $t4 = 0
	sll $t4, $a1, 9
	srl $t4, $t4, 9		# dua fraction cua A vao $t4
	or $t4, $t4, $t0	# cong 1

A0:	li $t7, 0
	beqz $a2, B0		# B = 0 -> $t7 = 0
	sll $t7, $a2, 9
	srl $t7, $t7, 9		# dua fraction cua B vao $t7
	or $t7, $t7, $t0	# cong 1
B0:	
	# dieu chinh dau cham
	bgt $t6, $t3, Blon
	
Alon:	beq $t3, $t6, dieuchinh	# while (exponentA > exponentB) dieu chinh exponentB
	addi $t6, $t6, 1
	srl $t7, $t7, 1 
	j Alon
	
Blon:	beq $t3, $t6, dieuchinh	# while (exponentB > exponentA) dieu chinh exponentA
	addi $t3, $t3, 1
	srl $t4, $t4, 1
	j Blon
dieuchinh:			# hoan tat dieu chinh
				# $t3, $t6 o dang m.n voi m la 9 bit dau va n la 23 bit cuoi
			
	move $t8, $t3		# gan exponent cua ket qua cho $t8
	bne $t2, $t5, khacdau	
				# A va B cung dau
	move $t0, $t2		# gan bit dau cua ket qua cho $t0
	add $t9, $t4, $t7	# $t9: he so cua ket qua
	j chuanhoakq
	
khacdau:			# A va B khac dau
	blt $t4, $t7, Anho
				# |A| >= |B|
	move $t0, $t2		# gan bit dau cua ket qua cho $t0
	sub $t9, $t4, $t7	# $t9: he so cua ket qua
	j chuanhoakq
Anho:				# |A| < |B|
	move $t0, $t5		# gan bit dau cua ket qua cho $t0
	sub $t9, $t7, $t4	# $t2: he so cua ket qua

chuanhoakq:			# chuan hoa ket qua
	beqz $t9, bang0		# kiem tra ket qua bang 0
	
	srl $t1, $t9, 23	# $t3: phan nguyen cua he so ket qua
	beqz $t1, giam
	
tang:	srl $t1, $t1, 1		
	beqz $t1, chuanhoaxong
	srl $t9, $t9, 1		# chinh fracment
	addi $t8, $t8, 1	# tang exponent cua ket qua
	j tang

giam:	sll $t9, $t9, 1		# chinh fracment
	srl $t1, $t9, 23
	addi $t8, $t8, -1	# giam exponent cua ket qua
	bnez $t1, chuanhoaxong
	j giam
	
chuanhoaxong:			# kiem tra va dich chuyen ket qua
	li $t1, 255
	beq $t8, $t1, loikq	# kiem tra ket qua 
	sll $t0, $t0, 31
	sll $t8, $t8, 23
	sll $t9, $t9, 9
	srl $t9, $t9, 9
	j trave
	
loikq:	la $a0, kqloi		# thong bao ket qua vuot nguong
	li $v0, 4
	syscall
	li $v1, 1
	jr $ra
	
Azero:	move $v0, $a2
	beqz $a3, Atiep
	li $t1, 1
	sll $t1, $t1, 31
	xor $v0, $v0, $t1
Atiep:	li $v1, 0
	jr $ra
	
Bzero:	move $v0, $a1		# tra ve A khi B bang 0
	li $v1, 0
	jr $ra
	
bang0:	li $v0, 0		# tra ve ket qua bang 0
	li $v1, 0
	jr $ra
	
trave:
	or $v0, $t0, $t8	# ket qua phep tinh => $v0 va tra ve
	or $v0, $v0, $t9
	li $v1, 0
	
ketthuc:			# ket thuc ham
	jr $ra
