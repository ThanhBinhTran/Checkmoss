.data
size: .word 20
arr1: .space 40
arr2: .space 40
enter: .asciiz "\n"
__: .asciiz "  "
string: .word 0, 3495, 349, 02, -239, -23, -435, -3490, -2, -23, 10, 45, 35, 354, 390, 329, 109, 303, 490, 320
.text
##################### main function ########################
main:
la $a0,string 
la $a2,size   
lw $a2,0($a2)   				
sub $a2,$a2,1
li $a1, 0       				
jal print_string
jal merge_sort				# merge sort

li $v0, 10
syscall
#############################################################
##################### Print string ##########################
print_string:
li $t7, 0
la $s3, string
la $t3,size   
lw $t3,0($t3) 
looop:
li $v0, 1

lw $a0, 0($s3)
syscall
li $v0, 4
la $a0, __
syscall
la $s3, 4($s3)
addi $t7, $t7, 1
bne $t7, $t3, looop

la $a0, enter
syscall
la $a0, string
jr $ra
#############################################################
################### begin merge_sort ########################
merge_sort:					
slt $t6, $a1, $a2
bne $t6, $0, mergesort      	# if(a2 <= a1) return 
jr $ra
mergesort:
add $s0, $a1, $a2
addi $s0, $s0, -1
div $s0, $s0, 2				# $s0 = ($a1 + $a2 - 1)/2
add $sp, $sp, -16
sw $ra, 12($sp)				# save address $ra
sw $a1, 8($sp)				# save address $a1
sw $a2, 4($sp)				# save address $a2
sw $s0, 0($sp)				
move $a2, $s0				# $a2 = $s0
jal merge_sort				# merge_sort(string, a1, a2)
lw $s0, 0($sp)
lw $a2, 4($sp)				# save address $a2
addi $a1, $s0, 1				# $a1 = $s0 + 1
jal merge_sort				# merge_sort(string, a1, a2)
lw $s0, 0($sp)
lw $a2, 4($sp)				# restore $a2
lw $a1, 8($sp)			 	# restore $a1
jal merge					# merge(string, a1, s0, a2)
lw $s0, 0($sp)
lw $a2, 4($sp)				# restore $a2
lw $a1, 8($sp)
lw $ra, 12($sp)				# restore $ra
add $sp, $sp, 16
jr $ra						
##################### end merge_sort #########################
####################### begin merge ##########################
merge:
sub $s1, $s0, $a1
addi $s1, $s1, 1				# $s1 = $s0 - $a1 + 1
sub $s2, $a2, $s0			# $s2 = $a2 - $s0
mul $a1, $a1, 4
mul $a2, $a2, 4
mul $s0, $s0, 4

la $t1, arr1					# $t1 <- arr1[size]
la $t2, arr2					# $t2 <- arr2[size]

la $s3, string
add $s3, $s3, $a1			# string[a1]
li $t3, 0					# i = 0
loop_T1:
lw $s4, 0($s3)				
sw $s4, 0($t1)				# arr1[i] = string[a1+i]
addi $t3, $t3, 1				# i++
la $s3, 4($s3)
la $t1, 4($t1)
bne $t3, $s1, loop_T1		# if(i == s1) break

la $s3, string
add $s3, $s3, $s0			# string[s0]
la $s3, 4($s3)     			# string[s0+1]
li $t3, 0					# i = 0
loop_T2:
lw $s4, 0($s3)				
sw $s4, 0($t2)				# arr2[i] = string[s0+1+i]
addi $t3, $t3, 1				# i++
la $s3, 4($s3)
la $t2, 4($t2)
bne $t3, $s2, loop_T2		# if(i == s2) break

li $t3, 0					# i = 0
li $t4, 0 					# j = 0
move $t5, $a1				# k = a1

la $t1, arr1					# $t1 -> arr1[size]
la $t2, arr2					# $t2 -> arr2[size]
la $s6, string
add $s6, $s6, $t5			# string[k]

while: 						# while(i < s1 && j < s2)
slt $s3, $t3, $s1			
slt $s4, $t4, $s2			
bne $s3, 1, end_while		
bne $s4, 1, end_while
lw $t8, 0($t2)
lw $t9, 0($t1)
slt $s5, $t8, $t9			
bne $s5, 0, else 			# if(arr1[i] <= arr2[j])
lw $s7, 0($t1)
sw $s7, 0($s6)				# 	string[k] = arr1[i]
addi $t3, $t3, 1				# 	i++
la $t1, 4($t1)    			# 	arr1[i]
j end_if
else: 						# else 
lw $s7, 0($t2)
sw $s7, 0($s6)				#  	string[k] = arr2[j]
addi $t4, $t4, 1				# 	j++
la $t2, 4($t2)				# 	arr2[j]
end_if:
la $s6, 4($s6)    			# k++  
j while
end_while:

while_L1:
slt $s3, $t3, $s1
bne $s3, 1, end_while_L1		# while(i < s1)
lw $s7, 0($t1) 
sw $s7, 0($s6)				# 	string[k] = arr1[i]
addi $t3, $t3, 1				# 	i++
la $t1, 4($t1)				# 	arr1[i]
la $s6, 4($s6)				# k++
j while_L1
end_while_L1:

while_L2:
slt $s3, $t4, $s2
bne $s3, 1, end_while_L2		# while(j < s2)
lw $s7, 0($t2) 
sw $s7, 0($s6)				# 	string[k] = arr2[j]
addi $t4, $t4, 1				# 	j++
la $t2, 4($t2)			# 	arr2[j]
la $s6, 4($s6)				# k++
j while_L2
end_while_L2:

add $sp, $sp, -4
sw $ra, 0($sp)	
jal print_string
lw $ra, 0($sp)				# restore $ra
add $sp, $sp, 4
jr $ra
#############################################################
