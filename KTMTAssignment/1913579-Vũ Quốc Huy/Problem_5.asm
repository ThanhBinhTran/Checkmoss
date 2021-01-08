.data 
	array: .word 79, -48, -36, 63, -1, -59, 74, -75, -77, -91, 26, -42, -63, -16, -51, 36, -34, 54, 56, -26
	size: .space 4
	current: .asciiz "Current:	"
	before: .asciiz "Before QuickSort:          "
	after: .asciiz "After QuickSort:          "
	newline: .asciiz "\n"
	space: .asciiz  " "
.text

################### MAIN ########################
main:
	#store element array and size of array
	la $a0, array			#a0  store address of array
	la $s7, size			#s7 store size of array
	li, $a1,0			#a1 low
	sub $t1, $s7,$a0		# size = (add1-add2)/4 do 2 dia chi canh nhau
	srl $t1,$t1,2
	sw $t1, 0($s7)			# luu size vao $s7
	addi $a2,$t1,-1			#a2 high 
	# print array before
	li		$v0, 4
	la		$a0, before
	syscall
	la $a0, array
	jal PRINT
	# implement quicksort
	jal QUICKSORT
	# print arr after quicksort
	li		$v0, 4
	la		$a0, after
	syscall
	jal PRINT
	# terminate program
	li,$v0,10
	syscall
#####################END MAIN######################

################### PRINT FUNCTION ##################
PRINT: 
	add $t0,$zero,$zero		# int i=0
	lw $t1, 0($s7)			#load size
	addi $sp, $sp, -8		#create stack
	sw $a0,0($sp)			#store addr arr
	sw $ra,4($sp)			#store addr stmt before
	la $s6, array			#load addr of arr
	
loop_print: 
	beq $t0,$t1, done_print		# if i==size stop print
	sll $t2 ,$t0,2			# 1word =4byte , truy xuat arr[i] = i*4 + addr arr
	add $t2,$t2,$s6			
	
	lw  $a0, 0($t2)			#load arr[i] to print
	li  $v0, 1
	syscall
	
	li		$v0, 4		#print space
	la		$a0, space
	syscall
	addi $t0,$t0,1
	j loop_print
done_print:
	li		$v0, 4			
	la		$a0, newline		#print newline
	syscall
	lw $a0,0($sp)				#luu addr vao a0
	lw $ra,4($sp)				#return $ra
	addi $sp,$sp,8				#pop stack
	jr $ra
########################### END PRRINT FUNCTION ##########################

############################ QUICKSORT FUNCTION ##########################
QUICKSORT:
	######################## C code ###########################
#
#	void quick(int *arr, int left, int right) {
#		int l = left, r = right, p = left;
#		
#		while (l < r) {
#			while (arr[r] >= arr[p] && r > left)
#				r--;
#			while (arr[l] <= arr[p] && l < right)
#				l++;
#			if (l >= r) {
#				SWAP(arr[p], arr[r]);
#				quick(arr, left, r - 1);
#				quick(arr, r + 1, right);
#				return;
#			}
#			SWAP(arr[l], arr[r]);
#		}
#	}
#
###########################################################	
	# store $s and $ra
	addi		$sp, $sp, -24	# Adjest sp
	sw		$s0, 0($sp)		# store s0
	sw		$s1, 4($sp)		# store s1
	sw		$s2, 8($sp)		# store s2
	sw		$a1, 12($sp)	# store a1
	sw		$a2, 16($sp)	# store a2
	sw		$ra, 20($sp)	# store ra

	# set $s
	add	$s1, $a1,$zero		# l = left
	add	$s2, $a2,$zero		# r = right
	add	$s0, $a1,$zero		# p = left
	while:
		slt $t0,$s1,$s2  #left<right
		beq $t0,$zero, while_done #if left >= right => stop
		sll $t0,$s0,2		#  calculate arr[p] 
		add $t0,$t0,$a0	
		lw $t7,0($t0)		#t7=pivot
		while1: 
			slt $t0,$s1,$s2 	#left<right
			beq $t0,$zero, while1_done #if right <= left => stop
			sll $t0,$s2,2		#cal arr[r]
			add $t0,$t0,$a0
			lw $t1,0($t0)			
			
			slt $t2, $t1, $t7	#arr[r]<arr[p]
			beq $t2,1,while1_done	#if true => stop
			add $s2,$s2,-1		# false => r=r-1
			j while1
		while1_done:
		while2: 
			slt $t0,$s1,$s2  #if left>= right =>stop
			beq $t0,$zero, while2_done
			sll $t0,$s1,2    #cal a[l]
			add $t0,$t0,$a0
			lw $t1,0($t0)
			slt $t2, $t7, $t1	#arr[p]< arr[l] 
			beq $t2,1,while2_done #if true =>stop
			add $s1,$s1,1		#false => l=l+1
			j while2
		while2_done:
		
		if_stmt:
			slt $t0, $s1,$s2   #if l<r endif
			beq $t0,1, endif
			#SWAP arr[p] & arr[r]
			sll $t1, $s0,2		
			sll $t2,$s2,2		
			add $t1,$t1,$a0
			add $t2,$t2,$a0
			lw  $t3, 0($t1)
			lw  $t4, 0($t2)
			sw  $t4, 0($t1)
			sw  $t3, 0($t2)
			##print current array
			li		$v0, 4
			la		$a0, current
			syscall
			la $a0,array
			jal PRINT
			
		recursive1: #recursive quicksort(arr,left, right -1)
			add $a2, $s2,-1 
			jal QUICKSORT
			#tra lai cac gia tri da luu
			lw	$a1, 12($sp)
			lw	$a2, 16($sp)
			lw	$ra, 20($sp)
		recursive2: #recursive quicksort(arr,right +1, right)
			addi	$a1, $s2,1
			jal		QUICKSORT
			#tra laij cac gia tri cua ham truoc do
			lw		$a1, 12($sp)	
			lw		$a2, 16($sp)
			lw		$ra, 20($sp)	
	
			lw		$s0, 0($sp)
			lw		$s1, 4($sp)		
			lw		$s2, 8($sp)		
			addi		$sp, $sp, 24	
			jr		$ra
			
		endif: 
			#if l < right => swap arr[r] va arr[l]
			sll $t1, $s1,2
			sll $t2,$s2,2
			add $t1,$t1,$a0
			add $t2,$t2,$a0
			lw  $t3, 0($t1)
			lw  $t4, 0($t2)
			sw  $t4, 0($t1)
			sw  $t3, 0($t2)
			j while #continue 
			
	while_done:
		
		lw		$s0, 0($sp)		# load s0
		lw		$s1, 4($sp)		# load s1
		lw		$s2, 8($sp)		# load s2
		addi	$sp, $sp, 24	# Adjest sp
		jr		$ra
		
		
	
	
	
	 

	
	
	
	
