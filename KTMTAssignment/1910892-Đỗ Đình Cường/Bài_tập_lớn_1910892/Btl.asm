.data 
 A: .space 32
 B: .space 32
 Nhap_mode: 	.asciiz "Nhap mode ( 0 neu nhap vao 2 so thap phan và 1 neu nhap vao 2 so thap luc phan): " 
 Ghi_chu:	.asciiz "Neu nhap so thap phan se co dau o truoc vi du +5,0,-5\n"
 endl: 		.asciiz "\n" 
 Nhap_a: 	.asciiz "Nhap a: " 
 Nhap_b: 	.asciiz "Nhap b: " 
 khongthechia:	.asciiz "Khong the chia cho 0"
 tich:  	.asciiz "Tich hai so la "
 thuong: 	.asciiz "Thuong la "
 sodu: 		.asciiz "So du la "
 thanhghi: 	.asciiz  "Gia tri thanh ghi luu tru ket qua phep chia la: "
 
.text
# Nhap mode tuong ung voi hai so se nhap
	li $v0 , 4
	la $a0, Nhap_mode 
	syscall 
 
 	li $v0, 5 
 	syscall 
 	add $s7, $0, $v0
 	
 	li $v0, 4 
	la $a0, Ghi_chu 
	syscall 
# Doc input cua A (chuyen tu string sang so de tinh toan)
 	li $v0, 4	
 	la $a0, Nhap_a		
 	syscall
 
 	la $a0, A
 	li $v0, 8
 	li $a1, 32
 	syscall 
 
 	beq $s7, $0, fromDecStringToDecimal	#nhay den chuyen doi thap phan hay thap luc phan
#chuyen doi thap luc phan
fromHexaStringToDecimal:
	la $t2, A
	addi $t2, $t2, 2
  	li $t8, 1
  	li $a0, 0
  	j hexaStringToDecimalLoop 
 
hexaStringToDecimalLoop:
  	lb $t7, 0 ($t2) 
  	addi $t4, $0, 57				
  	slt $t5, $t4, $t7
  	beq $t5, $zero, inputSub48		#neu t7 be hon hoac bang char '9' tru 48
  	addi $t7, $t7, -55			#tru 55 voi cac ki tu (ABCDEF)
  	j inputHexaNormalized 
 
inputHexaNormalized:
  	slt $t5, $t7, $0
  	bne $t5, $zero, Convertfinished		#ngung viec chuyen doi khi het chuoi                   
  	sll $a0, $a0, 4				#nhan voi 16
  	add $a0, $a0, $t7			#cong vao tong
  	addi $t2, $t2, 1
  	j hexaStringToDecimalLoop 
 
inputSub48:
  	addi $t7, $t7, -48			#tru 48 voi cac ki tu (0->9)
  	j inputHexaNormalized 
#chuyen doi thap phan
fromDecStringToDecimal:
  	la $t2, A
	addi $t2, $t2, 1
  	li $t8, 1
  	li $a0, 0
  	j decStringToDecimalLoop 
 
decStringToDecimalLoop: 
  	lb $t7, 0 ($t2) 
  	addi $t7, $t7, -48 
  	slt $t5, $t7, $0
  	bne $t5, $zero, Pos_or_not
  	sll $t0, $a0, 3 
  	sll $t1, $a0, 1 
  	add $a0, $t0, $t1 
  	add $a0, $a0, $t7 
  	addi $t2, $t2, 1 
  	j decStringToDecimalLoop
#xet so duong hay am
Pos_or_not: 
  	la $t2, A 
  	lb $t7, 0 ($t2) 
  	beq $t7, '+', pos 
  	sub $a0, $0, $a0 
pos: 
Convertfinished: add $s0, $0, $a0 #chuyen doi hoan tat

# Doc input cua B (chuyen tu string sang so de tinh toan)(tuong tu voi A)
 	li $v0, 4	
 	la $a0, Nhap_b	
 	syscall
 
	la $a0, A
 	li $v0, 8
 	li $a1, 32
 	syscall 
 
 	beq $s7, $0, fromDecStringToDecimalB
 
fromHexaStringToDecimalB:
  	la $t2, A
	addi $t2, $t2, 2
  	li $t8, 1
  	li $a0, 0
  	j hexaStringToDecimalLoopB 
 
hexaStringToDecimalLoopB:
  	lb $t7, 0 ($t2) 
  	addi $t4, $0, 57		
  	slt $t5, $t4, $t7
  	beq $t5, $zero, inputSub48B	
  	addi $t7, $t7, -55		
  	j inputHexaNormalizedB 
 
inputHexaNormalizedB:
  	slt $t5, $t7, $0
  	bne $t5, $0, ConvertfinishedB	                   
  	sll $a0, $a0, 4				
  	add $a0, $a0, $t7			
  	addi $t2, $t2, 1
  	j hexaStringToDecimalLoopB 
 
inputSub48B:
  	addi $t7, $t7, -48	
  	j inputHexaNormalizedB 
 
fromDecStringToDecimalB:
  	la $t2, A
	addi $t2, $t2, 1
  	li $t8, 1
  	li $a0, 0
  	j decStringToDecimalLoopB 
 
decStringToDecimalLoopB: 
  	lb $t7, 0 ($t2) 
  	addi $t7, $t7, -48 
  	slt $t5, $t7, $0
  	bne $t5, $zero, Pos_or_notB
  	sll $t0, $a0, 3 
  	sll $t1, $a0, 1 
  	add $a0, $t0, $t1 
  	add $a0, $a0, $t7 
  	addi $t2, $t2, 1 
  	j decStringToDecimalLoopB 
Pos_or_notB: 
  	la $t2, A 
  	lb $t7, 0 ($t2) 
  	beq $t7, '+', posB
  	sub $a0, $0, $a0 
posB: 
ConvertfinishedB: add $s1, $0, $a0
  	la $a0, tich
  	li $v0, 4
  	syscall
# Phep nhan
 	lui $a0, 0		# Ket qua 
 	li $t2, 0		# $t2 = 0
 	add $t0, $s0, $0
 	add $t1, $s1, $0
loopmul:
 	beq $t2, 32, endmul	# Duyet qua 32 bit
 	addi $t2, $t2, 1	# Tang bien dem $t2
 	sll $t3, $t0, 31
 	srl $t3, $t3, 31	# Lay phan tu cuoi cung cua $t3
 	beq $t3, 1, Nhan	# Kiem tra 1 hoac 0
 	sra $t0, $t0, 1		# Dich phai $t0
 	sll $t1, $t1, 1		# Dich trai $t1
 	j loopmul
Nhan:	
 	addu $a0, $a0, $t1	# Cap nhat ket qua
 	sra $t0, $t0, 1		# Dich phai $t0
 	sll $t1, $t1, 1		# Dich trai $t1
 	j loopmul
 	
endmul:	
	#in gia tri phep nhan
	beq $s7, 0, printDec
	li $v0, 34
	syscall
	j finishmul
	printDec: 
	li $v0, 1
	syscall
	
finishmul:
	la $a0, endl
	li $v0, 4
	syscall

# Phep chia

# khong the chia cho 0
 bne $s1,$0,label
 la $a0, khongthechia
 li $v0,4
 syscall 
 j end

label:	# truong hop so chia khac 0
	slt $t5, $s0, $0 
	beq $t5, $zero, p 
	slt $t5, $0, $s1 
	bne $t5, $zero, np
	# truong hop so bi chia < 0 va so chia < 0
	subu $s0,$0,$s0
	subu $s1,$0,$s1
	addu $s6,$0,$s1
        addi $t1,$0,16  # tao bien i = 32 de co 32 vong lap
	sll $s0,$s0,16	# dich trai so bi chia 16 bit
	srl $s0,$s0,16	# dich phai so bi chia 16 bit
	sll $s1,$s1,16	# dich trai so chia di 16 bit
loop11:	
	beq  $t1,$0,x11
	subi $t1,$t1,1
	sll $s0,$s0,1
		
	subu $t2,$s0,$s1 
	slt $t5, $t2, $0 
	bne $t5, $zero, loop11
	add $s0,$t2,$0
	addi $s0,$s0,1
	j loop11
	
x11: 
	sra $s3,$s0,16
	sll $s2,$s0,16
	sra $s2,$s2,16
	beq $s3,$0,tuan
	addi $s2,$s2,1
	subu $s3,$s6,$s3
tuan:
	j print
	j end
	np: # truong hop so bi chia < 0 va so chia > 0
	subu $s0,$0,$s0
	addu $s6,$s1,$0
	addi $t1,$0,16  # tao bien i = 32 de co 32 vong lap
	sll $s0,$s0,16	# dich trai so bi chia 16 bit
	srl $s0,$s0,16	# dich phai so bi chia 16 bit
	sll $s1,$s1,16	# dich trai so chia di 16 bit
loops:	
	beq $t1,$0,xs
	subi $t1,$t1,1
	sll $s0,$s0,1
	subu $t2,$s0,$s1 
	slt $t5, $t2, $0 
	bne $t5, $zero, loops
	add $s0,$t2,$0
	addi $s0,$s0,1
	j loops
	
xs: 
	sra $s3,$s0,16
	sll $s2,$s0,16
	sra $s2,$s2,16
	subu $s2,$0,$s2
	beq $s3,$0,mam
	subi $s2,$s2,1
	subu $s3,$s6,$s3
mam:
	j print
	j end
p:  # truong hop so bi chia >= 0
	#bgtz $s1,pp # truong hop so bi chia >= 0 va so chia < 0
	slt $t5, $0, $s1 
	bne $t5, $zero, pp
	subu $s1,$0,$s1
	addi $t1,$0,16  # tao bien i = 32 de co 32 vong lap
	sll $s0,$s0,16	# dich trai so bi chia 16 bit
	srl $s0,$s0,16	# dich phai so bi chia 16 bit
	sll $s1,$s1,16	# dich trai so chia di 16 bit
loopss:	
	beq $t1,$0,xss
	subi $t1,$t1,1
	sll $s0,$s0,1
		
	subu $t2,$s0,$s1 
	slt $t5, $t2, $0 
	bne $t5, $zero, loopss
	add $s0,$t2,$0
	addi $s0,$s0,1
	j loopss
	
xss: 
	sra $s3,$s0,16
	sll $s2,$s0,16
	sra $s2,$s2,16
	subu $s2,$0,$s2
	j print
	j end
		
		
pp: # truong hop so bi chia va so chia lon hon 0
	addi $t1,$0,16  # tao bien i = 32 de co 32 vong lap
	sll $s0,$s0,16	# dich trai so bi chia 16 bit
	srl $s0,$s0,16	# dich phai so bi chia 16 bit
	sll $s1,$s1,16	# dich trai so chia di 16 bit
loop:	
	beq $t1,$0,x
	subi $t1,$t1,1
	sll $s0,$s0,1
		
	subu $t2,$s0,$s1 
	slt $t5, $t2, $0 
	bne $t5, $zero, loop
	add $s0,$t2,$0
	addi $s0,$s0,1
	j loop
	
x: 
	sra $s3,$s0,16
	sll $s2,$s0,16
	sra $s2,$s2,16
			
			
print:	
	# in phan thuong
	la $a0, thuong
	li $v0, 4
	syscall
	add $a0, $s2, $0
	beq $s7, 0, printDec2
	li $v0, 34
	syscall
	j nextdiv
	printDec2: 
	li $v0, 1
	syscall
	nextdiv:
	la $a0,endl
	li $v0,4
	syscall
	
	
	# in phan du
	la $a0, sodu
	li $v0, 4
	syscall
	add $a0,$s3,$0
	beq $s7, 0, printDec3
	li $v0, 34
	syscall
	j nextdiv2
	printDec3: 
	li $v0, 1
	syscall
	nextdiv2:
	la $a0,endl
	li $v0,4
	syscall
	
	#dieu chinh $s0
	addi $s0,$0,0
	add $s0,$s2,$s0
	sll $s0,$s0,16
	add $s0,$s0,$s3
	la $a0,thanhghi
	li $v0,4
	syscall
	add $a0, $s0, $0
	li $v0, 34
	syscall	
end: 	
li $v0,10
syscall
 	





