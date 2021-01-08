
.data
Array: .word 529, 797, 32, -606, -330, 506, -340, 642, 260, -769, -906, -85, -64, -758, 392, -84, -645, 785, 496, -790, -284, -639, -188, 120, 167, 632, -84, 991, 640, 954, -941, 26, 821, 919, -973, 408, -578, 382, -392, 108, -351, -974, 871, 353, -477, -889, -743, -563, -420, -84
size: .word 50
endl: .asciiz "\n"
space: .asciiz " "
.text
la $a1,Array		#Load dia chi Array v�o $a1
li $a2,0		#Index thap nhat
li $a3,49		#Index cao nhat

jal quicksort

j endd
#-------------------------Swap(arr[$a2], arr[$a3])-----------------------------------	#
swap: 
	addi $sp,$sp,-4					
	sw $ra,0($sp)						# Push $ra vao Stack
	
	sll $a3,$a3,2						#------------------------------#
	add $a3,$a3,$a1						# $s6 = arr[$a3]		#
	lw $s6,0($a3)					#------------------------------#
	
	sll $a2, $a2,2					#------------------------------#
	add $a2,$a2,$a1					# $s7 = arr[$a2]		#
	lw $s7,0($a2)					#------------------------------#
	
	sw $s6,0($a2)					#------------------------------#
							# Hoan doi			#
	sw $s7,0($a3)					# -----------------------------	#
	
	jal print					# In mang ra man hinh		#
	lw $ra,0($sp)					# Lay lai $ra tu Stack		#
	addi $sp,$sp,4					# Resize Stack			#
	jr $ra
	
#----------- partition (int arr[] ($a0), int low($a2), int high($a3))------------------#
partion:
	addi $sp,$sp,-4					
	sw $ra,0($sp)					# Push gia tri $ra vao Stack  	#	
		
	sll $t1,$a3,2					#-----------------------------	#
	add $t1,$a1,$t1					#  pivot ($t1) = arr[high]    	#
	lw $t1,0($t1) 					#-----------------------------	#
		
	addi $t2,$a2,0 					# left($t2) = low ($a2)       	#
	addi $t3,$a3,-1 				# right($t3) = high($a2) - 1  	#
	
	loopwhile:					#--------- while(true)---------#
	
	 	loopwhile1:				#-----------while--------------#
	 		bgt $t2,$t3,exitloopwhile1	# (left ($t2) <= right ($t3)	#
	 		sll $t4,$t2,2			# 				#
	 		add $t4,$t4,$a1			# &&				#
	 		lw $t4,0($t4)			# 				#
	 		bge $t4,$t1,exitloopwhile1	# arr[left] ($t4)< pivot ($t1))#
	 		addi $t2,$t2,1			# left++			#
	 		j loopwhile1			#				#
	 	exitloopwhile1:				#------------end while---------#
	 	
	 	loopwhile2:				#-----------while--------------#
	 		bgt $t2,$t3,exitloopwhile2	#(right ($t3) <= left ($t2)	#
	 		sll $t5,$t3,2			#				#
	 		add $t5,$t5,$a1			# &&				#
	 		lw $t5,0($t5)			#				#
	 		bge $t1,$t5,exitloopwhile2	# arr[right] ($t5) > pivot($t1)#
	 		addi $t3,$t3,-1			# right--			#
	 		j loopwhile2			#				#
	 	exitloopwhile2:				#------------end while---------#
	 	
	 	bge $t2,$t3,exitloopwhile		# if (left >= right)    break  #
	 		addi $sp,$sp,-8                #-------------Swap-------------#
	 		sw $a2,0($sp)                  #                              #
	 		sw $a3,4($sp)                  #                              #
	 		addi $a2,$t2,0                 #                              #
	 		addi $a3,$t3,0                 # swap(left($t2) , right($t3)) #
	 		jal swap                       #                              #
	 		lw $a2,0($sp)                  #                              #
	 		lw $a3,4($sp)                  #                              #
	 		addi $sp,$sp,8                 #------------------------------#                           
	 		addi $t2,$t2,1                 # left++			#
	 		addi $t3,$t3,-1                # right--			#
	 j loopwhile					#------------------------------#
	 exitloopwhile:					#---------end while(true)------#
	 
	 		addi $sp,$sp,-8                #-------------Swap-------------#
	 		sw $a2,0($sp)                  #(Luu a2,a3 vao Stack de truyen#
	 		sw $a3,4($sp)                  # tham so su dung ham Swap)    #
	 		addi $a2,$t2,0                 #                              #
	 		addi $a3,$a3,0                 #  				# 
	 		jal swap                       # swap(left($t2) , high($a3))  #
	 		lw $a2,0($sp)                  #  				#
	 		lw $a3,4($sp)                  # (Pop a2,a3 va resize Stack)  #
	 		addi $sp,$sp,8                 #------------------------------#
	 		addi $v0,$t2,0                 #------	return left($t2) ------	#

	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
#--------------------Quicksort(int arr[]($a1) , int low($a2) , int high($a3) )-----------------------	#
quicksort:
	addi $sp,$sp,-12       				#---------------------------------------------	#   
	      						# Luu a2,a3,ra vao Stack			#
	sw $a2, 0($sp)          			# de su dung de qui				#
	sw $a3, 4($sp)          			#						#
	sw $ra, 8($sp)         			#						#
	ble $a3,$a2,exit            			# if (low ($a2) < high ($a3) )     		#      		
	jal partion					# $v0 = partion					#
	subi $a3,$v0,1					#						#
	jal quicksort           			# De qui quickSort(arr[] , low , $v0 - 1)	#
	addi $a2,$v0,1					# 						#
	lw $a3,4($sp)						# Lay lai $a3 tu Stack				#
	jal quicksort					# De qui quickSort(arr, $v0 + 1, high)		#
	exit:                                        	# 						#
	lw $a2,0($sp)					# Lay lai cac gia tri $a2,$a3,$ra tu Stack	#
	lw $a3,4($sp)					#						#		
	lw $ra,8($sp)					#						#
	addi $sp,$sp,12					# Resize Stack					#
	jr $ra						#---------------------------------------------	#
#------------------------------Ham Print in cac phan tu cua mang-------------------------------------#
print:
	 addi $t5,$0,0              
	 addi $t6,$0,49
	 
	 loop1:
	 bgt $t5,$t6,end
	 li $v0,1
	 sll $s3,$t5,2
	 add $s3,$s3,$a1
	 lw $s3,0($s3)
	 addi $a0,$s3,0
	 syscall
	 la $a0,space
	 li $v0,4
	 syscall
	 addi $t5,$t5,1
	 j loop1
	 end:
	 la $a0,endl
	 syscall
	 jr $ra
	
endd:
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
