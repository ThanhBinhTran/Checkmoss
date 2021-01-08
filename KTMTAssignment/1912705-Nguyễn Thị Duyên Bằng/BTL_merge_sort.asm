.data
Print_Unsorted_Array:	.asciiz	"Unsorted Array: ["
Print_Sorted_Array:	.asciiz	"Sorted Array:   ["
space:			.asciiz	", "
Closing_Bracket:	.asciiz	"]\n"
array_length:		.word 20

Print_Current_Array:	.asciiz "Current array:  ["
Line:			.asciiz "---------------------------------------------\n"
#--------------------------------------------------------------------------------
# 20 pointers
first:			.word 6222
second:			.word 1448
third:			.word -21
fourth:			.word -853
fifth:			.word -5524
sixth:			.word 648
seventh:		.word 917
eighth:			.word 1655
ninth:			.word -6585
tenth:			.word -165
eleventh:		.word 4561
twelveth:		.word 771
thirteenth:		.word 461
fourteenth:		.word 32
fifteenth:		.word -0
sixteenth:		.word -984
seventeenth:		.word 6156
eighteenth:		.word -6872
ninteenth:		.word 6542
twentieth:		.word 5462
# my_array
my_array:	
		.word first
		.word second
		.word third
		.word fourth
		.word fifth
		.word sixth
		.word seventh
		.word eighth
		.word ninth
		.word tenth
		.word eleventh
		.word twelveth
		.word thirteenth
		.word fourteenth
		.word fifteenth
		.word sixteenth
		.word seventeenth
		.word eighteenth
		.word ninteenth
		.word twentieth
#----------------------------------------------------------------------------------
.text
main:
	jal	print_unsorted_array	# print unsorted array
	
	#---------------------------------------------------
	# prepare parameter
	la	$a0, my_array		# a0 giu vi tri element dau tien cua array
	
	lw	$t0, array_length	# t0 = length
	mul	$t0, $t0, 4		# t0 = size cua array
	add	$a1, $a0, $t0		# a1 giu vi tri element cuoi cung cua array
	
	#---------------------------------------------------
	jal	Merge_sort		# Merge sort
	
	#---------------------------------------------------
	jal 	print_sorted_array	# print sorted array
	
	#-----------------------------------------------------
	li  	$v0, 10			# Done!
	syscall
#--------------------------------------------------------------------------------------------
# Ham merge sort de quy
# Chia doi mang hien tai, sau do lien tuc de quy cho den khi chi con 1 phan tu
# Sau do tien hanh so sanh tren mang 2 phan tu, hoan doi 2 vi tri phan tu neu can
#
# a0 = dia chi cua phan tu dau tien
# a1 = dia chi cua phan tu cuoi cung
Merge_sort:
	#	  STACK
	#	---------	
	#	| mid 	|
	#	| end	|
	#	| start |
	#	| ra	|
	addi	$sp, $sp, -16		# tao 4 empty trong stack
	sw	$ra, 0($sp)		# luu ra vao stack de return sau
	sw	$a0, 4($sp)		# luu start vao stack
	sw	$a1, 8($sp)		# luu end vao stack
	
	sub 	$t0, $a1, $a0		# t0 = size of current array
					# number of elements * 4

	sle	$t9, $t0, 4		# Neu tao sort chi con 1 phan tu thi ngung
	beq	$t9, 1,  Stop_sort	# t0 = size = 4
				
	div	$t0, $t0, 8		# t0 = size / 8
	mul	$t0, $t0, 4		# t0 = t0 * 4
	add	$a1, $a0, $t0		# a1 = a0 + to = mid of current array
	sw	$a1, 12($sp)		# luu mid vao stack
	
	# Recursive on first half
	jal	Merge_sort		
	
	# After all first-half, return here
	
	lw	$a0, 12($sp)		# new start = mid
	lw	$a1, 8($sp)		# old end
	
	# Recursive on second half
	jal	Merge_sort		
	
	# After all first-half, return here
	
	lw	$a0, 4($sp)		# restore Start
	lw	$a1, 12($sp)		# restore Mid
	lw	$a2, 8($sp)		# restore End
	
	jal	Merge_array		# tien hanh ghep 2 mang lai	
	
	Stop_sort:				
		lw	$ra, 0($sp)		# restore ra
		addi	$sp, $sp, 16		# xoa 4 empty da tao  gan day nhat
		jr	$ra			# Return 
# Ham merge array
# So sanh va ghep 2 mang da duoc loc lai voi nhau
#
# a0 = dia chi cua phan tu dau tien cua mang dau tien
# a1 = dia chi phan tu dau tien cua mang thu hai
# a2 = dia hi phan tu cuoi cung cua mang thu hai
Merge_array:
	addi	$sp, $sp, -16		# tao 4 empty trong stack
	sw	$ra, 0($sp)		# luu ra vao stack
	sw	$a0, 4($sp)		# luu start vao stack
	sw	$a1, 8($sp)		# luu mid vao stack
	sw	$a2, 12($sp)		# luu end vao stack
	
	move	$s0, $a0		# Tao 1 ban sao cua mang thu nhat 
	move	$s1, $a1		# Tao 1 ban sao cua mang thu hai
	
	Merge_loop:
		lw	$t0, 0($s0)		# Lay vi tri hien tai cua ptr tren mang thu nhat
		lw	$t1, 0($s1)		# Lay vi tri hien tai cua ptr tren mang thu hai
	
		lw	$t0, 0($t0)		# Lay gia tai ptr cua mang thu nhat
		lw	$t1, 0($t1)		# Lay gia tri ptr cua mang thu hai
	
		blt	$t0, $t1, No_swap	# Neu nhu 
						# gia tri ptr mang 1st < gia tri ptr mang 2nd (dung nhu thu tu ta mong muon)
						# => khong can phai swap
	
		# swap
		move	$a0, $s1		# a0 = vi tri hien tai cua ptr tren mang thu hai
						# a0 la vi tri can swap
		move	$a1, $s0		# a1 = vi tri hien tai cua ptr tren mang thu nhat
						# a1 la vi tri ma a0 can phai den
	
		jal	Swap			# Tien hanh swap
	
		addi	$s1, $s1, 4		# Tang ptr o mang thu hai len phan tu tiep theo
	
	No_swap:
		addi	$s0, $s0, 4		# Tang ptr o mang thu nhat len phan tu tiep theo
		
		jal	print_current_array 	# In mang ra 
		
		lw	$a2, 12($sp)		# restore end
		
		bge	$s1, $a2, Merge_end	# Ket thuc neu nhu da duyet het ca 2 mang
		bge	$s0, $a2, Merge_end	# CO THE BO DI	
		
		# tiep tuc so sanh neu nhu chua duyet het
		j	Merge_loop
	
	Merge_end:
		lw	$ra, 0($sp)		# restore ra
		addi	$sp, $sp, 16		# xõa empty da tao ra gan day nhat
		jr 	$ra			# Return
# Ham hoan doi gia tri
# Hoan doi gia tri ve dung vi tri cua no
#
# a0 la dia chi cua phan tu can duoc hoan doi
# a1 la dia chi phan tu do can den
Swap:	
	sle	$t9, $a0, $a1		# neu nhu hai dia chi da trung nhau, stop swapping
	beq	$t9, 1, Swap_end
	
	sub	$s5, $a0, 4		# Lui ve 1 index
	
	lw	$s6, 0($a0)		# lay ptr index a
	lw	$s7, 0($s5)		# lay ptr index a - 1
	
	sw	$s6, 0($s5)		# hona doi gia tri trong ptr
	sw	$s7, 0($a0)		# 
	
	sub 	$a0, $a0, 4		# current position -= 1
	j 	Swap			# Tiep tuc vong lap
	
	Swap_end:
		jr	$ra			# Return		
	
#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------
# SUPPORT FUNCTIONS
print_current_array:
	li  	$v0, 4				
	la  	$a0, Line			# Prints -------------------------------
	syscall
	
	li  	$v0, 4				
	la  	$a0, Print_Current_Array	# Print : "Current Array: ["
	syscall
	
	lw	$t9, array_length
	subi	$t8, $t9, 1
	li 	$t0, 0				# counter
	
	print_current_array_loop:
		# exit if print all
		bge 	$t0, $t9, exit_current_print
		
		# get the address of array[ index ]
		mul 	$t2, $t0, 4
		lw	$t3, my_array($t2)
		
		# syscall to print the value
		li 	$v0, 1
		lw 	$a0, 0($t3)
		syscall
		
		# skip the last space (beautify purpose)
		bge	$t0, $t8, skip_last_current
		
		# print space
   	 	li  	$v0, 4				
		la  	$a0, space	
		syscall
		
	skip_last_current:
		# increase counter
		addi    $t0, $t0, 1
    		j     	print_current_array_loop
  
	exit_current_print:
		li  	$v0, 4				
		la  	$a0, Closing_Bracket	# Prints the closing bracket 
		syscall
		
		jr 	$ra
#----------------------------------------------------------------------------------------		
print_unsorted_array:
	li  	$v0, 4				
	la  	$a0, Print_Unsorted_Array	# Print : "Unsorted Array: ["
	syscall
	
	lw	$t9, array_length
	subi	$t8, $t9, 1
	li 	$t0, 0				# counter
	
	print_array_loop:
		# exit if print all
		bge 	$t0, $t9, exit_print
		
		# get the address of array[ index ]
		mul 	$t2, $t0, 4
		lw	$t3, my_array($t2)
		
		# syscall to print the value
		li 	$v0, 1
		lw 	$a0, 0($t3)
		syscall
		
		# skip the last space (beautify purpose)
		bge	$t0, $t8, skip_last
		
		# print space
   	 	li  	$v0, 4				
		la  	$a0, space	
		syscall
		
	skip_last:
		# increase counter
		addi    $t0, $t0, 1
    		j     	print_array_loop
  
	exit_print:
		li  	$v0, 4				
		la  	$a0, Closing_Bracket	# Prints the closing bracket 
		syscall
		
		jr 	$ra
#----------------------------------------------------------------------------------------		
print_sorted_array:
	li  	$v0, 4				
	la  	$a0, Line			# Prints -------------------------------
	syscall
	
	li  	$v0, 4				
	la  	$a0, Print_Sorted_Array		# Print : "Sorted Array: ["
	syscall
	
	lw	$t9, array_length
	subi	$t8, $t9, 1
	li 	$t0, 0				# counter
	
	print_sorted_array_loop:
		# exit if print all
		bge 	$t0, $t9, exit_print_sorted
		
		# get the address of array[ index ]
		mul 	$t2, $t0, 4
		lw	$t3, my_array($t2)
		
		# syscall to print the value
		li 	$v0, 1
		lw 	$a0, 0($t3)
		syscall
		
		# skip the last space (beautify purpose)
		bge	$t0, $t8, skip_last_sorted
		
		# print space
   	 	li  	$v0, 4				
		la  	$a0, space	
		syscall
		
	skip_last_sorted:
		# increase counter
		addi    $t0, $t0, 1
    		j     	print_sorted_array_loop
  
	exit_print_sorted:
		li  	$v0, 4				
		la  	$a0, Closing_Bracket		# Prints the closing bracket 
		syscall
		
		jr 	$ra
