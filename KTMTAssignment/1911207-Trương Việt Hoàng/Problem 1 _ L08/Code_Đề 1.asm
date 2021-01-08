##########-----Nhân, chia 2 so nguyen-----##########
################### Data segment ###################
.data
mode:	.word	0 # =10 neu nhap he 10, =16 neu nhap he 16
str1:	.space	11
str2:	.space	11	
log_err:	.asciiz	"Input error!"
Quotient: .asciiz "Quotient: "
Remainder: .asciiz "Remainder: "
Product: .asciiz "Product: "
hexQuotient: .asciiz "0x00000000"
hexRemainder:.asciiz "0x00000000"
hexProduct: .asciiz "0x00000000"
ZeroDivide: .asciiz "The divisor must be a non-zero number\n"
endLine: .asciiz "\n"
log_err2:	.asciiz	"Out of range!\n"


################### Code segment ###################
.text
.globl main
#$s3 chua gia tri so thu nhat nhap vào
#$s4 chua gia tri so thu hai nhap vào

	j main

#$a0 la tham so truyen vao
nhan10:	sll $t0, $a0, 3
	sll $t1, $a0, 1	
	add $v0, $t0, $t1
	jr $ra
	
#$a0 la tham so truyen vao
nhan16:	sll $v0, $a0, 4
	jr $ra

#return $v1
conv16:	la $t1, ($a0)	
	addi $t1, $t1, 2	#$t1 = addr(str[i])
	lb $t2, 0($t1)	#$t2 = str[i]
	addi $v1, $0, 0	#$v1=0
	move $a0, $v1
	
loop1:	beq $t2, 10, endConv16
	move $a0, $v1
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal nhan16		#$v1 *= 16
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	move $v1, $v0
	
if1a:	blt $t2, 48, error
	bgt $t2, 57, if1b
	addi $a0, $t2, -48
	j endif1
	
if1b:	blt $t2, 65, error
	bgt $t2, 70, error
	addi $a0, $t2, -55
		
endif1:	add $v1, $v1, $a0
	addi $t1, $t1, 1	#i->i+1
	lb $t2, 0($t1)	#$t2 = str[i]
	j loop1	

endConv16:	la $t0, mode
	lw $t2, 0($t0)
	beq $t2, 10, error 
	addi $t1, $0, 16
	sw $t1, 0($t0)
	jr $ra

#return $v1	
conv10:	la $t3, ($a0)
	lb $t2, 0($t3)	#$t2 = str[i]
	addi $v1, $0, 0	#$v1=0
	move $a0, $v1
	
loop2:	beq $t2, 10, endConv10
	move $a0, $v1
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal nhan10		#$v1 *= 10
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	move $v1, $v0
	
if2:	blt $t2, 48, false
	bgt $t2, 57, false
	addi $a0, $t2, -48
	
endif2:	add $v1, $v1, $a0
	addi $t3, $t3, 1	#i->i+1
	lb $t2, 0($t3)	#$t2 = str[i]
	j loop2	
false:	addi $v0, $0, 0
	jr $ra
endConv10:	la $t0, mode
	lw $t2, 0($t0)
	beq $t2, 16, error 
	addi $t1, $0, 10
	sw $t1, 0($t0)
	addi $v0, $0, 1#
	jr $ra
main: 	
#Input, check mode (10 or 16)
	#Nhap 2 strings, báo loi va exit neu khong convert sang he 10/16 duoc 
	#2 chuoi neu là so nhung không cùng 1 he 10/16 cung báo loi
	#cap nhat bien 'mode' neu thành công
	#Luu y: convert chuoi sang so nguyên he 10 save vào $s3, $s4
	la $a0, str1
	li $a1, 20
	li $v0, 8
	syscall	#Nhap chuoi thu nhat
	la $s5, str1	#addr cua str1 -> $s5
	lb $t1, 0($s5)
	
	addi $t8, $0, 0
	bne $t1, 45, next1 
	addi $s5, $s5,1
	addi $t8, $0, 1	#so nhap vao am -> $t8 =1, nguoc lai =0

next1:	la $a0, ($s5)
	jal conv10
	move $t0, $v0 #
	bne $t0, 0,next2 #
	
	lb $t0, 0($s5)
	lb $t1, 1($s5)
	bne $t0, 48, error
	bne $t1, 120, error
	
	la $a0, ($s5)
	jal conv16
next2:	move $s3, $v1
	bne $t8, 1, next3
	sub $s3, $0, $s3

next3:	
	la $a0, str2
	li $a1, 20
	li $v0, 8
	syscall	#Nhap chuoi thu hai
	la $s6, str2	#addr cua str2 -> $s6
	lb $t1, 0($s6)
	
	addi $t8, $0, 0
	bne $t1, 45, next4
	addi $s6, $s6,1
	addi $t8, $0, 1	#so nhap vao am -> $t8 =1, nguoc lai =0

next4:	la $a0, ($s6)
	jal conv10
	move $t0, $v0 #
	bne $t0, 0,next5 #
	
	lb $t0, 0($s6)
	lb $t1, 1($s6)
	bne $t0, 48, error
	bne $t1, 120, error
	
	la $a0, ($s6)
	jal conv16

next5:	move $s4, $v1
	bne $t8, 1, callFunctions
	sub $s4, $0, $s4

callFunctions:
	la $t9, mode
	lw $a3, 0($t9) # a3 = 10 neu la DEC, 16 neu la HEX
	move $a0, $s3
	move $a1, $s4
	
	bne $a1, 0, callDivide
	la $a0, ZeroDivide
	li $v0, 4
	syscall
	j callMultiply
	
callDivide:
	jal divide
	

# in ra gia tri thuong
printQuotient:
	move $s6, $v0
	li $v0, 4
	la $a0, Quotient
	syscall
	
	move $a0, $s6
	la $a1, hexQuotient
	jal OUTPUT

#xuong dong
printEndline1:
	la $a0, endLine
	li $v0, 4
	syscall

#in ra gia tri cua so du
printRemainder:
	la $a0, Remainder
	li $v0, 4
	syscall
	
	move $a0, $v1
	la $a1, hexRemainder
	jal OUTPUT
	
#xuong dong
printEndline2:
	la $a0, endLine
	li $v0, 4
	syscall
	
#phep nhan
callMultiply:
	move $a0, $s3
	move $a1, $s4
	jal phepnhan


	j exit

error:	la $a0, log_err
	li $v0, 4
	syscall	
exit:	li $v0, 10
	syscall

##########################################################################################################
divide:	#a0 is A
	#a1 is B
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $t0, $a0 # t0 is A / quotient / 32 lest
	move $t1, $a1 # t1 is B
	andi $t2, 0 # t2 is remainder

#check A
	slti $t3, $t0, 0 # neu A < 0 => t3 = 1
	abs $t0, $t0	#Lay tri tuyet doi cua A
	slti $t4, $t1, 0# neu B < 0 => t4 = 1
	abs $t1, $t1	# lay tri tuyet doi cua B


	li $t5, 0 #bien dem
loop:
	addi $t5, $t5, 1 #t5 = t5 + 1
	jal DichTraiSoDu
	sub $t2, $t2, $t1 # lay bit cao cua so du voi so chia, luu vao bit cao cua so d
	blt $t2, 0, khoiPhuc# neu t2 < 0 => khoi phuc lai t2
chinhBit:
	ori $t0, $t0, 1 #neu t2 >= 0 => chinh bit thap thanh 1
	j endKP
khoiPhuc:
	add $t2, $t2, $t1
endKP:
	blt $t5, 32, loop # neu t5 < 32, tiep tuc vong lap

#kiem tra dau cua ket qua
	jal SignCheck
	move $a0, $t0
#in ra gia tri cua thuong
	move $v0, $t0 # v0 la thuong
	move $v1, $t2# v1 la so du
	lw $ra, 0($sp)
	addi $sp, $sp, 4
enddivide:
	jr $ra

#================================================================================================================================================	
	
SignCheck:
	
quotientCheck:
	beq $t3, $t4, remainderCheck
	sub $t0, $0, $t0
remainderCheck:
	beq $t3, 0, endSignCheck
	sub $t2, $0, $t2
endSignCheck:
	jr $ra

#dich trai 64bit so du	
DichTraiSoDu:
	sll $t2, $t2, 1
	sll $t6, $t0, 1
	srl $t6, $t6, 1
	sub $t6, $t0, $t6
	sll $t0, $t0, 1
	beqz $t6, end
	addi $t2, $t2, 1
end:
	jr $ra

#=================================================================================================================================================
OUTPUT:

	beq $a3, 10, printDec
printHex:
	move $s7, $a1
	addi $s7, $s7, 9
	move $t8, $a0
loophex:	
	move $t7, $t8
	srl $t8, $t8, 4
	sll $t8, $t8, 4
	sub $t7, $t7, $t8
	srl $t8, $t8, 4
	bgt $t7, 9, else
if:	
	addi $t7, $t7, 48
	sb $t7, 0($s7)
	j endif
else:
	addi $t7, $t7, 55
	sb $t7, 0($s7)
endif:
	subi $s7, $s7, 1
	bnez $t8, loophex
	
	li $v0, 4
	move $a0, $a1
	syscall
	j endoutput
printDec:
	li $v0, 1
	syscall
	
endoutput:	
	jr $ra
		
#=======================================================================================================================================

phepnhan:
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	move $s3, $a0
	move $s4, $a1
	slt $t1, $s3, $0 #so bi nhan<0 $t1=1 va nguoc lai
	slt $t2, $s4, $0
	andi $t3, $t3, 0
	andi $t4, $t4, 0
start:
	andi $t5,$s4,1 #kiem tra bit cuoi cung cua thanh ghi so nhan
	beqz $t5, dich #bit cuoi bang 0
	beq $t5,1,congdon #bit cuoi bang 1

dich:
	sll $s3,$s3,1
	srl $s4,$s4,1
	addi $t4,$t4,1 #tang i
	bne $t4,32,start #kiem tra i voi 32
	beq $t4,32,kiemtra


printProduct:
	la $a0, Product
	li $v0, 4
	syscall
	
	move $v0, $t3
	move $a0, $t3
	la $a1, hexProduct
	jal OUTPUT

exitNhan:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
congdon:
	addu $t3,$t3,$s3
	j dich


kiemtra:
	
	
	slt $t5,$t3,$0
	#kiem tra so bi nhan va so nhan
	add $t6,$t1,$t2 #$t6=2 2 so am
		#$t6=1 1 so am 1 so duong
		#$t6=0 2 so duong

	add $t6,$t6,$t5 

	beq $t6,3,error2
	beq $t6,2,printProduct
	beq $t6,1,error2
	beq $t6,0,printProduct


error2:
	la $a0, log_err2
	li $v0, 4
	syscall	
	j exitNhan
