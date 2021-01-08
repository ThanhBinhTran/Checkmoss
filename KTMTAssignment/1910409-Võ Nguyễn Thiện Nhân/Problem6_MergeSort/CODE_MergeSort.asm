.data

space:	.asciiz	"  "
newline:	.asciiz 	"\n"
given_arr:	.asciiz	"Given Array: "
process:	.asciiz	"Sorting process: "
prompt:		.asciiz "Sorted Array: "
tempArr: 	.word 	0:20
arr:		.word 	900 900 80 70 45 30 20 25 10 -50 -40 -30 -10 15 0 60 50 5 999 999
size:		.word 	20


.text
.globl 	main

main:
	la 	$a0, given_arr			# print array before sorting
	
	li 	$v0, 4
	syscall		
	la 	$a0, newline
	li 	$v0, 4
	syscall
	
	move 	$a1, $zero			# a1 = index of start array
	lw 	$a2, size
	addi 	$a2, $a2, -1		# a2 = index of end array
	
	jal	PrintSortArray
	
	la 	$a0, newline
	li 	$v0, 4
	syscall
	la 	$a0, process		# print lable "Sorting process"
	li 	$v0, 4
	syscall
	la 	$a0, newline
	li 	$v0, 4
	syscall
	
	la 	$a0, arr			# a0 = address of array

	jal 	MergeSort			# merge sort array

	la 	$a0, prompt			# print array after sorted
	li 	$v0, 4
	syscall		
	la 	$a0, newline
	li 	$v0, 4
	syscall

	jal 	PrintSortArray

	li 	$v0, 10				# exit program
	syscall

	##################### PRINT ARRAY ##############################

PrintSortArray:
	add	$t0, $zero, $a1			# t0 = index of start
	add	$t1, $zero, $a2			# t1 = index of end
	la 	$t2, arr

PrintSortArray_Loop:
	sub	$t6, $t0, $t1			# if start > end, then ExitPrint
	slt 	$t7, $zero, $t6
	bne	$t7, $zero, ExitPrint	 

	sll 	$t3, $t0, 2				# index*4
	add  	$t3, $t3, $t2			# address of array
	lw 	$t4, 0($t3)				# t4 = value of array at this index

	add	$a0, $zero, $t4			# move to a0 for print
	li 	$v0, 1
	syscall

	addi 	$t0, $t0, 1				# increase index by 1
	la 	$a0, space				# print a space
	li 	$v0, 4
	syscall
	j 	PrintSortArray_Loop

ExitPrint:
	jr 	$ra
	
	##################### END PRINT ARRAY #########################

	# ----------------------------------------------------------- #					   

	####################### MERGE SORT ############################

MergeSort:
	beq	$a1, $a2, ExitMergeSort		# if start = end, then Exit MergeSort
	
	addi 	$sp, $sp, -16
	sw 	$ra, 12($sp)				# save ra on stack
	sw 	$a1, 8($sp)					# save start on stack
	sw 	$a2, 4($sp)					# save end on stack

	add 	$s0, $a1, $a2			# start + end
	srl	$s0, $s0, 1					# mid = (start + end) / 2
	
	sw 	$s0, 0($sp)					# save index mid on stack

	add 	$a2, $zero, $s0			# make end = mid for sort half first array
	
	jal 	MergeSort

	lw 	$s0, 0($sp)					# load mid on stack
	add	$a1, $zero, $s0				# make start = mid for sort 2nd half array
	addi 	$a1, $a1, 1				# start = mid + 1
	lw 	$a2, 4($sp)					# end = end
	jal 	MergeSort

	lw 	$a1, 8($sp)					# a1 = load start on stack
	lw 	$a2, 4($sp)					# a2 = load end on stack
	lw 	$a3, 0($sp)					# a3 = load mid on stack

	jal 	Merge					# combine array

	lw 	$ra, 12($sp)
	addi 	$sp, $sp, 16
	jr 	$ra

ExitMergeSort:
	jr 	$ra

	###################### END MERGE SORT ####################### 

	# --------------------------------------------------------- #

	########################### MERGE ###########################

Merge:
	add	$s0, $zero, $a1			# s0 = i = index of array left
	add	$s1, $zero, $a1			# s1 = k = start
	add	$s2, $zero, $a3			# s2 = j = index of array right (mid)
	addi 	$s2, $s2, 1				# j = mid + 1

CheckCondition:
	sub	$t6, $s0, $a3			# if i > mid, exit fill array left
	bgtz	$t6, FillRestArrayRight
	
	sub	$t6, $s2, $a2			# if j > end, exit fill array right
	bgtz	$t6, FillRestArrayLeft

Comparision:					# COMPARE array[i] and array[i] (t1 and t3)
	sll 	$t0, $s0, 2				# t0 = i*4
	add 	$t0, $t0, $a0			# address of array[i]
	lw 	$t1, 0($t0)				# t1 = value of array[i]	

	add	$t0, $zero, $zero
	sll 	$t0, $s2, 2				# t0 = j*4
	add 	$t0, $t0, $a0			# address of array[j]
	lw 	$t3, 0($t0)				# t3 = value of array[j]

	sub	$t6, $t3, $t1			# if array[j] < array[i]
	bltz	$t6, FillArrayRight
	
FillArrayLeft:
	la 	$t2, tempArr			# load address of temp array
	sll 	$t0, $s1, 2				# t0 = index of next element of array * 4 = k*4
	add 	$t2, $t2, $t0			# address of next element of temp array
	sw 	$t1, 0($t2)				# temp[k] = array[i]

	addi 	$s1, $s1, 1				# k++
	addi 	$s0, $s0, 1				# i++
	j 	CheckCondition

FillArrayRight:
	la 	$t2, tempArr			# load address of temp array
	sll 	$t0, $s1, 2				# t0 = index of next element of array * 4 = k*4
	add 	$t2, $t2, $t0			# address of next element of temp array
	sw 	$t3, 0($t2)				# temp[k] = array[j]

	addi 	$s1, $s1, 1				# k++
	addi 	$s2, $s2, 1				# j++
	j 	CheckCondition

FillRestArrayLeft:
	sub	$t6, $s0, $a3			# if i > mid (fill completed), then set variable
	bgtz	$t6, SetVariable

	la 	$t0, tempArr			# load address of temp array
	sll 	$t1, $s1, 2				# t1 = k*4
	add 	$t0, $t0, $t1			# t0 = address of next element of temp array

	sll 	$t2, $s0, 2				# i*4
	add 	$t2, $t2, $a0			# t2 = address of array[i]
	lw 	$t1, 0($t2)				# t1 = value of array[i]
	
	sw 	$t1, 0($t0)				# store value of array[i] to temp array

	addi 	$s1, $s1, 1				# k++
	addi 	$s0, $s0, 1				# i++
	j 	FillRestArrayLeft

FillRestArrayRight:
	sub	$t6, $s1, $a2			# if k > end (fill completed), then set variable
	bgtz	$t6, SetVariable

	la 	$t0, tempArr			# load address of temp array
	sll 	$t1, $s1, 2				# t1 = k*4
	add 	$t0, $t0, $t1			# t0 = address of next element of temp array

	sll 	$t2, $s2, 2				# j*4
	add 	$t2, $t2, $a0			# t2 = address of array[j]
	lw 	$t1, 0($t2)				# t1 = value of array[j]
	
	sw 	$t1, 0($t0)				# store value of array[j] to temp array
 
	addi 	$s1, $s1, 1				# k++
	addi 	$s2, $s2, 1				# j++
	j 	FillRestArrayRight

SetVariable:
	add 	$t0, $a1, $zero		# t0 = current
	addi 	$t1, $a2, 0			# t1 = end
	la 	$t2, tempArr

SortEachMerge:
	sub	$t6, $t0, $t1		# if current > end, then Sort End
	bgtz	$t6, EndSortEachMerge

	sll 	$t3, $t0, 2			# current*4
	add 	$t3, $t3, $t2		# t3 = address of current element of temp array
	lw 	$t4, 0($t3)			# t4 = value of current element of temp array

	sll 	$t3, $t0, 2			# current*4
	add 	$t3, $t3, $a0		# t3 = address of next element of array
	sw 	$t4, 0($t3)			# store: value of next element of temp array = value of 
					# current element of temp array		

	add 	$t5, $zero, $a0		# t5 = temp address for a0
					# a0 now is being used for print
								
	add	$a0, $zero, $t4		# print array each merge
					# t4 = value need to printed
	
	li 	$v0, 1
	syscall
	la 	$a0, space
	li 	$v0, 4
	syscall

	add	$a0, $zero, $t5		# return value for a0

	addi 	$t0, $t0, 1			# increase next index of array by 1
	j 	SortEachMerge

EndSortEachMerge:
	add	$t5, $zero, $a0		# t5 = a0 for print newline after each merge
	
	la 	$a0, newline
	li 	$v0, 4
	syscall

	add	$a0, $zero, $t5
	jr 	$ra

	######################### END MERGE ##########################
