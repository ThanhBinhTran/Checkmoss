.data
n:		.word	20
output1:	.asciiz	"\nMang ban dau: "
output2:	.asciiz	"\nMang da sap xep: "
output3:	.asciiz	"\nMERGE: "
output4:	.asciiz "\nSORT:  "
xuongdong:	.asciiz	"\n"
left:		.asciiz	"\n left: "
right:		.asciiz	"\t right: "
mid:		.asciiz	"\t  mid: "
khoangtrang:	.asciiz	"    "
daungan:	.asciiz " | "
array:		.word	0:20
arraykq:	.word	944,-51,2,6,843,16,-546,84,321,-64,501,351,-130,144,511,66,788,833,910,50
.text
.globl main
main:
lw		$s0, n			# s0 = n = 20

jal 		NhapMang		# Nhap cac phan tu cua mang
jal 		XuatMangchuaSort	# Xuat mang chua Sort
jal 		GanGiaTri
jal 		MSORT			# Merge Sort
jal 		XuatMangdaSort		# Xuat mang da Sort

j 		Exit			# Ket thuc


NhapMang:
# Khoi tao	
	addi 	$t1, $0, 0	# $t1 = 0	
	la	$a1, array	# $a1 = address of array	
	la	$a2, arraykq	# $a2 = address of arraykq 				# Phuc vu cho viec in tung buoc
NhapPhanTu:
# Kiem tra so lan lap ( Lap 20 lan => Thoat )	
	slt	$t2, $t1, $s0	
	beq	$t2, $0, KetThucNhap    
# Nhap so thuc và luu vào array[i]
	#lwnhi
tudongnhap:	
	lw	$s1,($a2)		
	sw	$s1,($a1)		
	j 	capnhat
# cap nhat
capnhat:	
	addi 	$t1, $t1, 1	# t1 la index phan tu	
	addi 	$a1, $a1, 4	# a1 tro den phan tu tiep theo trong array	
	addi 	$a2, $a2, 4	# a2 tro den phan tu tiep theo trong arraykq	
	j 	NhapPhanTu
KetThucNhap:	
	jr 	$ra		# Ket thuc nhap - Bat dau in day chua duoc sort	
#Merge Sort
GanGiaTri:	
	la	$a1, array	# $a1 = address of array	
	lw	$a2, n		# $a2 = n = 20	
	subi	$a2, $a2, 1	# $a2 giam 1 (n--)	
	li	$a3, 0	
	jr 	$ra	
MSORT: 	
 	addi	$sp, $sp, -20  		# Tao stack luu tru  	
 	sw  	$ra, 16($sp)   		# Luu dia chi tra ve 	
 	sw  	$s1, 12($sp)   		# Luu dia chi mang 	
 	sw  	$s2, 8($sp)  		# Luu right 	
 	sw  	$s3, 4($sp)   		# Luu low	
 	sw  	$s4, 0($sp)   		# Luu mid 	
 	or  	$s1, $zero, $a1  	# $s1 <- array address	 	
 	or  	$s2, $zero, $a2  	# $s2 <- right	 	
 	or  	$s3, $zero, $a3  	# $s3 <- left	 		
 	slt 	$t3, $s3, $s2   	# low < high	
 	beq 	$t3, $zero, DONE  	# if $t3 == 0, DONE 	
 	add 	$s4, $s3, $s2  		# left + right 	
 	div 	$s4, $s4, 2   		# $s4 <- (left+right)/2 	
 	or  	$a2, $zero, $s4 	# $a2 = mid	
 	or  	$a3, $zero, $s3 	# $a3 = left 	
 	jal 	MSORT   		# recursive call for (array, left, mid)	
# mergesort (arr, mid+1, high)
	addi	$t4, $s4, 1   		# $t4 = $t4+1 = mid + 1 	
 	or  	$a3, $zero, $t4 	# $a3 = $t4 = mid + 1	
 	or  	$a2, $zero, $s2 	# $a2 = right	
 	jal 	MSORT   		# recursive call for (array, mid+1, high) 	
 	or 	$a1, $zero, $s1 	# a1 = Dia chi mang	
 	or 	$a2, $zero, $s2 	# a2 = high	 
 	or 	$a3, $zero, $s3 	# a3 = low	
 	or 	$a0, $zero, $s4 	# a0 = mid 	
 	jal 	MERGE   		# jump to merge (array, high, low, mid) 
DONE:	
 	lw 	$ra, 16($sp)  		# load dia chi tra ve	
 	lw 	$s1, 12($sp)  		# load dia chi mang	
	lw 	$s2, 8($sp)  		# load right	
 	lw 	$s3, 4($sp)  		# load left	
 	lw 	$s4, 0($sp)  		# load mid	
 	addi 	$sp, $sp,  20 		# xoa stack	
 	jr 	$ra    			# nhay den dia chi vua load
MERGE:  	
	addi	$sp, $sp, -20  		# Tao stack luu tru 	
 	sw  	$ra, 16($sp)   		# Luu dia chi tra ve	
 	sw  	$s1, 12($sp)   		# Luu dia chi mang	
 	sw  	$s2, 8($sp)  		# Luu right	
	sw  	$s3, 4($sp)   		# Luu low	
 	sw  	$s4, 0($sp)   		# Luu mid	
 	or  	$s1, $zero, $a1  	# $s1 = dia chi mang	
 	or  	$s2, $zero, $a2  	# $s2 <- right	
 	or 	$s3, $zero, $a3  	# $s3 <- left 			
 	or 	$s4, $zero, $a0  	# $s4 <- mid			
# In ra cac buoc:
# Xuat ket qua cua merge lan truoc	
 	la 	$a0, output4		# $a0 = address of output4	
	li 	$v0, 4
	syscall
	
	la	$a1, arraykq		# $a1 = address of arraykq	
	addi	$t1, $0, 0	
	jal	XuatPhanTu
# Bat dau hien thi left - mid - right	
	la	$a1, arraykq	
	addi	$t1, $0, 0		# $t1 la bien dem	
 	la 	$a0, left		# Hien thi left:	
	li 	$v0, 4
	syscall
	
	addi 	$a0, $s3, 0		# Xuat gia tri left = $s3	
	li 	$v0, 1	
	syscall
	
	la 	$a0, mid		# Hien thi mid:	
	li 	$v0, 4
	syscall
	
	move	$a0, $s4		# Xuat gia tri mid = $s4	
	li 	$v0, 1	
	syscall
	
	la 	$a0, right		# Hien thi right:	
	li 	$v0, 4
	syscall
	
	move	$a0, $s2		# Xuat gia tri right = $s2	
	li 	$v0, 1
	syscall
	
 	la 	$a0, output3		# Hien thi MERGE	
	li 	$v0, 4
	syscall

XuatPhanTubuoc:
# Kiem tra dau ngan
# In dau ngan trai	
	beq	$t1, $s3, indaungantrai	
continuetrai:
	# Kiem tra so lan lap	
	slt 	$t2, $t1, $s0	
	beq 	$t2, $0, continue
	# xuat phan tu array[i]	
	lw 	$a0, ($a1)	
	li 	$v0, 1
	syscall
	
	#in dau ngan o giua
	beq	$t1, $s4, indaunganphai	
	#in dau ngan phai
	beq	$t1, $s2, indaunganphai	
continuephai:
	# xuat khoang trang	
	la	$a0, khoangtrang	
	li 	$v0, 4
	syscall
	# Tang i (i++)	
	addi 	$t1, $t1, 1	
	addi 	$a1, $a1, 4	
	j 	XuatPhanTubuoc	
# In dau ngan
indaungantrai:	
 	la 	$a0, daungan	
	li 	$v0, 4
	syscall
	
	j continuetrai	
indaunganphai:	
 	la 	$a0, daungan	
	li 	$v0, 4
	syscall
	
	j continuephai	
# Sau khi sap xep
# Sau khi in xog thi tiep tuc
continue:
# Cap nhat lai	
 	or  	$a1, $zero, $s1  	# Dia chi mang	
 	or  	$a2, $zero, $s2 	# Cap nhat lai $a2 = $s2 = right	
 	or  	$a3, $zero, $s3  	# Cap nhat lai $a3 = $s3 = left	
 	or  	$a0, $zero, $s4  	# Cap nhat lai $a0 = $s4 = mid	
 	or  	$t1, $zero, $s3  	# $t1 = i = left	
 	or  	$t2, $zero, $s4  	# $t2 = j = mid			
 	addi	$t2, $t2, 1   	 	# $t2 = j = mid + 1 	
 	or  	$t3, $zero, $a3  	# $t3 = k = left = la bien dem cua arraykq										
# Khi 2 mang con tu i -> mid va j -> right co phan tu
WHILE: 
# Dieu kien vong while: khi i <= mid va j <= right	
 	slt  	$t4, $s4, $t1  		# mid < i (i <= mid) 	
 	bne  	$t4, $zero, while2 	# go to while 2 if i >= mid	
 	slt  	$t5, $s2, $t2  		# high < j (j <= high)	
 	bne  	$t5, $zero, while2 	# && go to while2 if j >= right	
 	sll  	$t6, $t1, 2  		# t6 = i * 4 	
 	add  	$t6, $s1, $t6 		# $t6 = address a[i]		 		
 	lw	$s5, 0($t6) 		# $f5 = a[i]	
	sll  	$t7, $t2, 2  		# j * 4 
 	add  	$t7, $s1, $t7 		# $t7 = address a[j]		
 	lw	$s6, 0($t7)		# $f6 = a[j]		
 	slt   	$s7,$s5, $s6	
 	beq 	$s7,0,ELSE	
 	sll  	$t8, $t3, 2  		# k * 4	
 	la   	$a0, arraykq  		# $a0 = dia chi arraykq	
 	add  	$t8, $a0, $t8 		# $t8 = dia chi c[k]	
 	sw   	$s5, 0($t8)  		# c[k] = a[i]  	
 	addi 	$t3, $t3, 1  		# k++	tang index trong mang kq	
 	addi 	$t1, $t1, 1  		# i++	tang index cho mang tu low -> mid	
 	j 	WHILE 
ELSE:   # a[i] >= a[j}	
 	sll  	$t8, $t3, 2  		# i = i * 4	
 	la   	$a0, arraykq  		# $a0 = dia chi arraykq	
 	add  	$t8, $a0, $t8 		# $t8 = address c[k]	
 	sw  	$s6, 0($t8)  		# c[k] = a[j]	
 	addi 	$t3, $t3, 1  		# k++ 	tang index trong mang kq	
 	addi 	$t2, $t2, 1  		# j++	tang index cho mang tu mid+1 den hight	
 	j 	WHILE
#Mang tu low den mid con phan tu
while2: 	
 	slt  	$t4, $s4, $t1  		# mid < i (i <= mid)	
 	bne  	$t4, $zero, while3 	# go to while3 if i >= mid 	
 	sll  	$t6, $t1, 2  		# i * 4	
 	add  	$t6, $s1, $t6 		# $t6 = address a[i]	
 	lw  	$s5, 0($t6)  		# $s5 = a[i] 	
 	sll  	$t8, $t3, 2  		# i * 4	
 	la   	$a0, arraykq  		# $a0 = dia chi arraykq
 	add  	$t8, $a0, $t8 		# $t8 = address c[k]
 	sw   	$s5, 0($t8)  		# c[k] = a[i]	
 	addi 	$t3, $t3, 1  		# k++ 	
 	addi 	$t1, $t1, 1  		# i++	
 	j while2
#Mang tu low den mid het phan tu - > mang tu mid+1 den hight con phan tu
while3: 	
 	slt  	$t5, $s2, $t2  		# high < j (j >= right)	
 	bne  	$t5, $zero, start 	# go to for loop if j >= right 	
	sll  	$t7, $t2, 2  		# i*4
 	add  	$t7, $s1, $t7 		# $t7 = address a[j]	
 	lw   	$s6, 0($t7)  		# $s6 = a[j] 	
 	sll  	$t8, $t3, 2  		# i*4	
 	la   	$a0, arraykq   		# $a0 = dia chi arraykq	
 	add  	$t8, $a0, $t8 		# $t8 = address c[k]	
 	sw   	$s6, 0($t8)  		# c[k] = a[j]	
	addi 	$t3, $t3, 1  		# k++ 	
 	addi 	$t2, $t2, 1  		# j++	
	j 	while3
#Cap nhat lai mang 
start:	
 	or   	$t1, $zero, $s3 	# i <- left
forloop:	
 	slt  	$t5, $t1, $t3  		# i < k	
	beq  	$t5, $zero, DONE 	# complete 	
 	sll  	$t6, $t1, 2 		# i * 4 	
 	add  	$t6, $s1, $t6 		# $t6 = address a[i] 	
 	sll  	$t8, $t1, 2  		# i * 4 	
 	la   	$a0, arraykq  		# $a0 = dia chi arraykq 	
 	add  	$t8, $a0, $t8  		# $t8 = address arraykq[i] 	
 	lw   	$s7, 0($t8)  		# $s7 = arraykq[i]	
 	sw   	$s7, 0($t6)  		# a[i]=	arraykq[i]  	
 	addi 	$t1, $t1, 1  		# i++	
 	j 	forloop 
# Ket thuc giai thuat Merge Sort
# Xuat
XuatMangchuaSort:	
	la 	$a0, output1 		# $a0 = address of output1	
	li 	$v0, 4
	syscall
		
	la	$a1, array		# $a1 = address of array	
	addi 	$t1, $0, 0		# $t1 = 0	
	j	XuatPhanTu
XuatMangdaSort:	
	la 	$a0, output2	
	addi 	$v0, $zero, 4
	syscall	
	la	$a1, array	
	addi	$t1, $0, 0
XuatPhanTu:
# Kiem tra so lan lap (Lap du 20 lan => Thoat)	
	slt 	$t2, $t1, $s0	
	beq 	$t2, $0, done
# Xuat phan tu array[i]	
	lw 	$a0, ($a1)		
	li 	$v0, 1			# Xuat gia tri	
	syscall
# Xuat khoang trang " "	
	la	$a0, khoangtrang	
	li 	$v0, 4
	syscall
# Tang i (i++)	
	addi 	$t1, $t1, 1	
	addi 	$a1, $a1, 4	
	j XuatPhanTu
done:	
	jr	$ra	
#Ket thuc chuong trinh
Exit:
