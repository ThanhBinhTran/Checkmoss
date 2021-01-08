#Problem 6: Sap xep mang 20 phan tu bang merge sort
.data
space: .asciiz " "
result: .asciiz"Mang sau khi MergeSort\n"
Arr0: .word 13
Arr1: .word -4
Arr2: .word -5
Arr3: .word 0
Arr4: .word 0
Arr5: .word 0
Arr6: .word 11
Arr7: .word 12
Arr8: .word -46
Arr9: .word 73
Arr10: .word 45
Arr11: .word -12
Arr12: .word 42
Arr13: .word -13
Arr14: .word -13
Arr15: .word 30
Arr16: .word -4
Arr17: .word 1
Arr18: .word 4
Arr19: .word 3

# An array of pointers (indirect array)
count:	.word 20	# count_of_array
Array:	.word	Arr0,Arr1,Arr2,Arr3,Arr4,Arr5,Arr6,Arr7,Arr8,Arr9
	.word 	Arr10,Arr11,Arr12,Arr13,,Arr14,,Arr15,Arr16,Arr17,Arr18,Arr19
##############################
       #Mot so ki hieu
#count_of_array: so phan tu mang (=20)
#size_of_array: kich thuoc mang (size=count*4)
#begin_address: dia chi bat dau
#end_address: dia chi ket thuc
#middle_address:dia chi phan tu giua
##############################
.text
	#Print chuoi result ra man hinh
	la $a0,result
	li $v0,4
	syscall
	#Load du lieu dau vao
	la	$a0, Array		# $a0=begin_address
	lw	$t0, count		# #t0=count=20
	sll	$t0, $t0, 2		# Multiple the array length by 4 (the size of the elements)
	add	$a1, $a0, $t0		# $a1=end_address
	jal	Merge_Sort		# Goi ham MergeSort
  	b	Sort_End		# Khi sap xep xong->goi Sort_End
#Hien thuc ham Merge_Sort	
Merge_Sort:
	#Dieu chinh con tro stack_pointer
	#Luu lan ruot (dia chi tra ve,begin_address,end_address) vao stack
	addi	$sp, $sp, -16		
	sw	$ra, 0($sp)		
	sw	$a0, 4($sp)		
	sw	$a1, 8($sp)		
	#Tinh kich thuoc cua mang
	sub 	$t0, $a1, $a0		# size_of_aray =$t0=begin_address-end_address=count_of_array*4
	
	#Neu $t0<=4->mang dang co 1 phan tu->goi ham MergeSort_End
	ble	$t0, 4, MergeSort_End	
	#Nguoc lai:
	srl	$t0, $t0, 3		#$t0=$t0*8
	sll	$t0, $t0, 2		#$t0=$t0/4
	#Luc nay $t0 = size_of_array/2
	add	$a1, $a0, $t0		# $a1=$begiin_address+size_of_array/2
					# ->$a1=middle_address
	#Luu middle_address vao stack
	sw	$a1, 12($sp)		
	
	jal	Merge_Sort		# Goi MergeSort mang con ben trai 
	
	lw	$a0, 12($sp)		#$a0=middle_address
	lw	$a1, 8($sp)		#$a1=end_address
	
	jal	Merge_Sort		# Goi MergeSort mang con ben phai
	
	lw	$a0, 4($sp)		# $a0=begin_address
	lw	$a1, 12($sp)		# $a1=middle_address
	lw	$a2, 8($sp)		# $a2=end_address
	
	jal	Merge			# Goi ham Merge
	
#Sau khi MergeSort ket thuc->khoi phuc gia tri thanh ghi $ra va dieu chinh stack_pointer	
MergeSort_End:			
	lw	$ra, 0($sp)		
	addi	$sp, $sp, 16		
	jr	$ra	
			
###Ham Merge dung de gop hai mang con lai voi nhau sau khi da MergeSort 2 mang con
#$a0 la begin_address cua mang con ben trai
#$a1 la begin_address cua mang con ben phai
#$a2 la end_address cua mang con ben phai	
Merge:
	addi	$sp, $sp, -16		
	sw	$ra, 0($sp)		
	sw	$a0, 4($sp)		
	sw	$a1, 8($sp)		
	sw	$a2, 12($sp)		
	
	move	$s0, $a0		#$s0=$a0
	move	$s1, $a1		#$s1=$a1
	
Merge_Loop:
	lw	$t0, 0($s0)		
	lw	$t1, 0($s1)		
	lw	$t0, 0($t0)		
	lw	$t1, 0($t1)		
	
	#Neu $t1>$t0 -> khong can doi cho->goi ham Not_Shift
	bgt	$t1, $t0, Not_Shift	
	#Nguoc lai
	move	$a0, $s1		
	move	$a1, $s0		
	jal	Shift			
	
	addi	$s1, $s1, 4		# Tang chi so nua sau

Not_Shift:
	addi	$s0, $s0, 4		# Tang chi so nua dau
	
	lw	$a2, 12($sp)		# $a2=end_address
	#Neu $s0>=$a2 -> ngung vong lap
	bge	$s0, $a2, MergeLoop_End	
	#Neu $s1>=$a2 ->ngung vong lap
	bge	$s1, $a2, MergeLoop_End	
	#Nguoc lai->goi ham MergeLoop
	b	Merge_Loop
	
#Khi da merge xong->khoi phuc gia tri thanh ghi $ra duoc luu trong stack
MergeLoop_End:
	lw	$ra, 0($sp)		
	addi	$sp, $sp, 16		
	jr 	$ra			

#Neu 2 gia tri chua sap xep->goi ham Shift -> swap
Shift:
	li	$t0, 20
	#Neu $a0<=$a1  ->  ngung Shift
	ble	$a0, $a1, Shift_End
	#Nguoc lai:	
	addi	$t6, $a0, -4		# Tim dia chi phan tu d?ng truoc no (previous_address)
	lw	$t7, 0($a0)		# 
	lw	$t8, 0($t6)		# 
	sw	$t7, 0($t6)		# 
	sw	$t8, 0($a0)		# 
	move	$a0, $t6		# 
	b 	Shift			# Loop again
Shift_End:
	jr	$ra			
#Khi da sort  xong->in mang da sap xep bang ham Print:	
Sort_End:				# Point to jump to when sorting is complete
# Print out the indirect array
	li	$t0, 0				# Initialize the current index
print:
	Print_Loop:
	lw	$t1,count	
	#Neu $t0>=$t1	->da in den phan tu cuoi-> stop print	
	bge	$t0,$t1,Print_End
	#Nguoc lai:		
	sll	$t2,$t0,2			# Next_element
	lw	$t3,Array($t2)			# Get pointer
	lw	$a0,0($t3)
	
	#In gia tri so nguyen ($v0=1)						
	li	$v0,1				
	syscall	
	#In khoang trang giua cac phan tu:				
	la	$a0,space		
	li	$v0,4				
	syscall		
				
	addi	$t0,$t0,1			# in phan tu ke tiep (next_element)
	b	Print_Loop			# Print next_element	
Print_End:						
	li	$v0,10				# Dung thuc thi bai toan
	syscall

