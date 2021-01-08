
		.data
arrSize:	.word 	20
array:		.space	200				#edit
input:		.asciiz "Nhap chuoi so nguyen 20 phan tu lan luot la:\n"	#edit
space:		.asciiz " "				#edit
		.text
		.globl main
main:
		#edit
		#nhap chuoi
		#
		li $v0,4
    		la $a0,input
    		
    		syscall
    		addi	$t7,$0,0
    		la	$t0,arrSize
    		lw	$t0,0($t0)
    		mul	$t0,$t0,4
####
    		jal put
    		la $s3,array
		la	$t0,arrSize
		lw	$t0,0($t0)			#t0 = size 		
		addi	$t1,$0,0			#t1 = low
		addi	$t3,$t0,-1			#t3 = high
		mul	$t0,$t0,4			
		add	$s4,$s3,$t0			#condition to print

		jal	quickSort
#print array!						
L:	
		lw	$a0,0($s3)		
		li	$v0,1			
		syscall	
		la $a0,space
		li $v0,4
		syscall			
		addi	$s3,$s3,4		
		beq	$s3,$s4,exit		
		j	L			
exit:											
		li	$v0,10			
		syscall	
		######
put:         		
    		beq $t7,$t0,done
    		li $v0,5
    		syscall
    		sw $v0,array($t7)
    		addi $t7,$t7,4
    		j put
done:
    		jr $ra	
    		######
    		
swap2:		#swap low and pivot
		sw	$a0,0($s1)	
		sw	$a1,0($s0)	
		jr	$ra		
swap1:		#swap low and high
		sw	$a1,0($s2)
		sw	$a2,0($s1)
		jr	$ra

partition:	#t4 -> position of pivot = left
		addi $sp, $sp, -4     
		sw 	$ra,0($sp)         		# return address
		mul	$s5,$t1,4			#s5 = 4*low
		add	$s1,$s3,$s5			#s1 = arr[low]
		mul	$t6,$t3,4			#t6 = 4*high
		add	$s0,$s3,$t6			#s0 = arr[high]
		addi	$s2,$s0,-4			#s2 = arr[right]
loop:						
		lw	$a0,0($s0)			# a0 = pivot 
		lw	$a1,0($s1)			# a1 = arr[left]
		lw	$a2,0($s2)			# a2 = arr[right]
loop1:		
		bgt	$t1,$t3,loop2			#left > right?
		bge	$a1,$a0,loop2			#arr[left] >= pivot?
		addi	$t1,$t1,1			#left ++
		addi	$s1,$s1,4			#arr[low++]
		lw	$a1,0($s1)		
		j	loop1			
loop2:		
		bgt	$t1,$t3,break_if		#left > right?
		ble	$a2,$a0,break_if		#arr[right] <= pivot?
		addi	$t3,$t3,-1			#right--
		addi	$s2,$s2,-4			#arr[right--]
		lw	$a2,0($s2)		
		j	loop2
break_if:
		bge	$t1,$t3,return
		jal	swap1
		addi	$s1,$s1,4			
		addi	$s2,$s2,-4
		addi	$t1,$t1,1			#t1 = left = low = 0,1,2..
		addi	$t3,$t3,-1			#t3 = right	 = 8,7,6..	
		j	loop
return:
		jal	swap2			
		lw	$ra,0($sp)		
		addi	$sp,$sp,4			
		jr	$ra				#return left = t1	
							
quickSort:	
		#condition to stop
		addi $sp, $sp, -12     
		sw	$t1, 0($sp)          	# low
		sw 	$t3, 4($sp)         	# high
		sw 	$ra, 8($sp)         	# return address
		move	$t2,$t3			#t2 = a2 = high
		bge	$t1,$t2,end		#low >= high ?
		jal	partition
		move	$t5,$t1			#t5 = pivot
		lw	$t1,0($sp)		#t1 = low
		addi	$t3,$t5,-1		#t3 = pivot - 1
		jal	quickSort
		addi	$t1,$t5,1		#t1 = pi + 1
		lw	$t3,4($sp)		#t3 = high
		jal	quickSort
end:
		lw 	$t1, 0($sp)        	#restore a1
		lw	$t3, 4($sp)        	#restore a2
		lw 	$ra, 8($sp)        	#restore return address
		addi 	$sp, $sp, 12      	#restore the stack
		jr 	$ra              	#return to caller		
			
		
		
		
