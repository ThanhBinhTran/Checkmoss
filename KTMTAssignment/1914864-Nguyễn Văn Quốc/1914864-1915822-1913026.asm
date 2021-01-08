#Title: Write Megre sort function in MIPS used to sort a float array (A[20])
#Student1: Nguyen Van Quoc. Student ID: 1914864
#Student2: Phan Anh Tu. Student ID: 1915822
#Student3: Huynh Tuan Dat. Student ID: 1913026
.data
n:		.word	20
Open:		.asciiz	"A["
Close:		.asciiz	"] = "
output: 	.asciiz	"Begin enter the elements of the float array (A[20])\n"
output1:	.asciiz	"\nThe array before sorting is : "
output2:	.asciiz	"\nThe array after sorting is : "
output3:	.asciiz	"\nMERGE: "
output4:	.asciiz "\nSORT:  "
left:		.asciiz	"\n left: "
right:		.asciiz	"\t right: "
mid:		.asciiz	"\t  mid: "
space:		.asciiz	"    "
compartment:	.asciiz " | "
array:		.float	0:20 		# float array A[20] 
arrayresult:	.float	0:20 		# float array C[20] 
.text
.globl main
main:
lw		$t0, n			# t0 = n = 20
jal 		EnterArray		# Enter the elements of array
jal 		PrintArrayOriginal	# Print array before sorting
jal 		AssignValue
jal 		MSORT			# Merge Sort
jal 		PrintArrayResult	# Print array after sorting
j 		Exit			# End
EnterArray:
	la 	$a0, output
	li 	$v0, 4
	syscall 
	addi 	$t1, $0, 0		# $t1 = 0 = index
	la	$a1, array		# $a1 = address of array
	la	$a2, arrayresult	# $a2 = address of arrayresult 			
EnterElement:
# Check number of loop
	slt	$t2, $t1, $t0
	beq	$t2, $0, FinishEnter 
# Print "A["
	la 	$a0, Open
	li 	$v0, 4
	syscall 
# Print index of element
	addi  	$a0, $t1, 0
	li 	$v0, 1
	syscall
# Print "] = "
	la 	$a0, Close
	li 	$v0, 4
	syscall
# Enter float number and save in A[i]
	li 	$v0, 6
	syscall
	swc1 	$f0, ($a1)
	swc1 	$f0, ($a2)
# Update
	addi 	$t1, $t1, 1	# $t1 = $t1 + 1 (Update index of element)
	addi 	$a1, $a1, 4	# $a1 = address of the next element in A[]
	addi 	$a2, $a2, 4	# $a2 = address of the next element in C[]
	j 	EnterElement
FinishEnter:
	jr 	$ra		# Finish enter element - Begin print array before sorting
	
#Merge Sort
AssignValue:
	la	$a1, array	# $a1 = address of array
	li	$a2, 0		# $a2 = left = 0
	lw	$a3, n		# $a3 = n = 20
	addi	$a3, $a3, -1	# $a3 = right = n - 1
	jr 	$ra
	
	
MSORT:	# void mergeSort(int array[],int left,int right){ //($a1, $a2, $a3)
    	# if(left>=right){
        # 	return; //returns recursively
    	# }
    	# 	int mid = (left+right)/2;
    	# 	mergeSort(array,left,mid);
    	# 	mergeSort(array,mid+1,right);
   	# 	merge(array,left,mid,right);
	# }
 
 	addi	$sp, $sp, -20  		# Create stack to store 
 	sw  	$ra, 16($sp)   		# Store $ra to stack 
 	sw  	$s1, 12($sp)   		# Store Array address
 	sw  	$s2, 8($sp)  		# Store left
 	sw  	$s3, 4($sp)   		# Store right
 	sw  	$s4, 0($sp)   		# Store mid
 	
 	# Loading arguemnt to $s1(array), $s2(left), $s3(right)
 	or  	$s1, $zero, $a1  	# $s1 <- $a1 = array address	
 	or  	$s2, $zero, $a2  	# $s2 <- $a2 = left	
 	or  	$s3, $zero, $a3  	# $s3 <- $a3 = right	
 		
 	# if(left>=right){ // ($s3 >= $s2)
        # 	return;//returns recursively
    	# }	
 	slt  	$t3, $s2, $s3   	# if left < right thi $t3 = 1, else $t3 = 0
 	beq 	$t3, $zero, DONE  	# if left >= right, DONE
 	
 	# int mid = (left+right)/2; // $s4 = (
 	add 	$s4, $s2, $s3  		# left + right
 	div 	$s4, $s4, 2   		# $s4 = mid = (left+right)/2
 	
# mergesort (Array[], left, mid)
 	or  	$a2, $zero, $s2 	# $a2(left) = left
 	or  	$a3, $zero, $s4 	# $a3(right) = mid
 	jal 	MSORT   		# recursive call for (A[], left, mid)

# mergesort (Array[], mid+1, right)
 	addi	$t4, $s4, 1   		# $t4 = $t4+1 = mid + 1 
 	or  	$a2, $zero, $t4 	# $a2(left) = $t4 = mid + 1
 	or  	$a3, $zero, $s3 	# $a3(right) = right
 	jal 	MSORT   		# recursive call for (A[], mid+1, right) 
 	
 	
 	
 	
# merge (A[], left, right, mid)
 	or 	$a1, $zero, $s1 	# a1 = array
 	or 	$a2, $zero, $s2 	# a2 = left 
 	or 	$a3, $zero, $s3 	# a3 = right
 	or 	$a0, $zero, $s4 	# a0 = mid
 	jal 	MERGE   		# jump to merge (A[], left, right, mid) 
 
DONE: 					# delete stack and load left, mid, right
 	lw 	$ra, 16($sp)  		# load $ra
 	lw 	$s1, 12($sp)  		# load array
 	lw 	$s2, 8($sp)  		# load left
 	lw 	$s3, 4($sp)  		# load right
 	lw 	$s4, 0($sp)  		# load mid
 	addi 	$sp, $sp,  20 		# delete stack
 	jr 	$ra    			# jump to $ra loaded recently

MERGE:  
	addi	$sp, $sp, -20  		# Create stack  
 	sw  	$ra, 16($sp)   		# store $ra
 	sw  	$s1, 12($sp)   		# store array
 	sw  	$s2, 8($sp)  		# store left
 	sw  	$s3, 4($sp)   		# store right
 	sw  	$s4, 0($sp)   		# store mid
 	or  	$s1, $zero, $a1  	# $s1 = array
 	or  	$s2, $zero, $a2  	# $s2 <- left
 	or 	$s3, $zero, $a3  	# $s3 <- right 		
 	or 	$s4, $zero, $a0  	# $s4 <- mid			

# Print step by step
# Print array in the previous step
 	la 	$a0, output4		# $a0 = address of output4
	li 	$v0, 4
	syscall
	la	$a1, arrayresult	# $a1 = address of arrayresult
	li	$t1, 0			# $t1 = index
	jal	PrintElement

# Print left - mid - right
	la	$a1, arrayresult
	li	$t1, 0			# $t1 = index
 	la 	$a0, left		# Print "left: "
	li 	$v0, 4
	syscall
	addi 	$a0, $s2, 0		# Print left = $s3
	li 	$v0, 1
	syscall
	la 	$a0, mid		# Print "mid: "
	li 	$v0, 4
	syscall
	addi	$a0, $s4, 0		# Print mid = $s4
	li 	$v0, 1
	syscall
	la 	$a0, right		# Print "right: "
	li 	$v0, 4
	syscall
	addi	$a0, $s3, 0		# Print right = $s2
	li 	$v0, 1
	syscall
# Finish print left - mid - right

 	la 	$a0, output3		# Print "MERGE: "
	li 	$v0, 4
	syscall
	
PrintStep:
	# Print left compartment 
	beq	$t1, $s2, PrintLeftCompartment # if index ($t1) = left ($s2) then print left compartment
	
ContinueLeft:

	# Check number of loop
	slt 	$t2, $t1, $t0
	beqz 	$t2, continue 		# if index >= n (20) then goto continue

	# Print A[i]
	lwc1 	$f12, ($a1)
	li 	$v0, 2
	syscall
	
	# Print mid compartment
	beq	$t1, $s4, PrintRightCompartment	# if index ($t1) = mid ($s4) then print compartment

	# Print right compartment
	beq	$t1, $s3, PrintRightCompartment	# if index ($t1) = left ($s3) then print compartment
	
ContinueRight:
	# print space
	la	$a0, space
	li 	$v0, 4
	syscall

	# Increase index (i++)
	addi 	$t1, $t1, 1
	addi 	$a1, $a1, 4    		# %a1 = address of the next element

	j 	PrintStep
	
# Print compartment
PrintLeftCompartment:
 	la 	$a0, compartment
	li 	$v0, 4
	syscall

	j ContinueLeft
	
PrintRightCompartment:
 	la 	$a0, compartment
	li 	$v0, 4
	syscall

	j ContinueRight
	
continue:
# Update
 	or  	$a1, $zero, $s1  	# address of array
 	or  	$a2, $zero, $s2 	# $a2 = $s2 = left
 	or  	$a3, $zero, $s3  	# $a3 = $s3 = right
 	or  	$a0, $zero, $s4  	# $a0 = $s4 = mid
 	or  	$t1, $zero, $s2  	# $t1 = i = left
 	or  	$t2, $zero, $s4  	# $t2 = mid		
 	addi	$t2, $t2, 1   	 	# $t2 = j = mid + 1 		
 	or  	$t3, $zero, $a2  	# $t3 = k = left = index of element on arrayresult C[]		
 								
# When two subarrays have elements ( i -> mid and j -> right)
WHILE: 
# Conditions of while loop: i <= mid && j <= right
 	slt  	$t4, $s4, $t1  		 
 	bne  	$t4, $zero, while2 	# if mid ($s4) < i ($t1) ($t4 = 1) then go to while2
 	slt  	$t5, $s3, $t2  		
 	bne  	$t5, $zero, while2 	# if right ($s3) < j ($t2) ($t5 = 1) then go to while2
 	sll  	$t6, $t1, 2  		# $t6 = i * 4 
 	add  	$t6, $s1, $t6 		# $t6 = address A[i]	 		
 	lwc1	$f5, 0($t6) 		# $f5 = A[i]
	sll  	$t7, $t2, 2  		# $t7 = j * 4 
 	add  	$t7, $s1, $t7 		# $t7 = address A[j]	
 	lwc1	$f6, 0($t7)		# $f6 = A[j]	
 	
# Compare A[i], A[j]
# If (A[i] < A[j]) C[k] = A[i]
# Else C[k] = A[j]
 	c.lt.s	$f5, $f6
 	bc1f	ELSE
 	# A[i] < A[j]
 	sll  	$t8, $t3, 2  		# $t8 = k * 4
 	la   	$a0, arrayresult  	# $a0 = address of arrayresult
 	add  	$t8, $a0, $t8 		# $t8 = address C[k]
 	swc1   	$f5, 0($t8)  		# C[k] = A[i]  
 	addi 	$t3, $t3, 1  		# k++	
 	addi 	$t1, $t1, 1  		# i++	
 	j 	WHILE 

ELSE:   # A[i] >= A[j}
 	sll  	$t8, $t3, 2  		# $t8 = k * 4
 	la   	$a0, arrayresult  	# $a0 = address of arrayresult
 	add  	$t8, $a0, $t8 		# $t8 = address C[k]
 	swc1  	$f6, 0($t8)  		# C[k] = A[j]
 	addi 	$t3, $t3, 1  		# k++ 	
 	addi 	$t2, $t2, 1  		# j++	
 	j 	WHILE

# Subarray from left to mid have elements 
while2: 
 	slt  	$t4, $s4, $t1  		
 	bne  	$t4, $zero, while3 	# if mid ($s4) < i ($t1) ($t4 = 1) then go to while3
 	sll  	$t6, $t1, 2  		# $t6 = i * 4
 	add  	$t6, $s1, $t6 		# $t6 = address A[i]
 	lwc1  	$f5, 0($t6)  		# $f5 = A[i] 
 	sll  	$t8, $t3, 2  		# $t8 = k * 4
 	la   	$a0, arrayresult  	# $a0 = address of arrayresult
 	add  	$t8, $a0, $t8 		# $t8 = address C[k]
 	swc1   	$f5, 0($t8)  		# C[k] = A[i]
 	addi 	$t3, $t3, 1  		# k++ 
 	addi 	$t1, $t1, 1  		# i++
 	j while2

# Subarray from mid + 1 to right have elements
while3: 
 	slt  	$t5, $s3, $t2  		
 	bne  	$t5, $zero, start 	# if right ($s3) < j ($t2) ($t5 = 1) then go to start
	sll  	$t7, $t2, 2  		# $t7 = j * 4
 	add  	$t7, $s1, $t7 		# $t7 = address A[j]
 	lwc1   	$f6, 0($t7)  		# $s6 = A[j] 
 	sll  	$t8, $t3, 2  		# $t8 = k * 4
 	la   	$a0, arrayresult   	# $a0 = address of  arrayresult
 	add  	$t8, $a0, $t8 		# $t8 = address C[k]
 	swc1   	$f6, 0($t8)  		# C[k] = A[j]
	addi 	$t3, $t3, 1  		# k++ 
 	addi 	$t2, $t2, 1  		# j++
	j 	while3

# Update array
start:
 	or   	$t1, $zero, $s2 	# i = left
forloop:
 	slt  	$t5, $t1, $t3  		
 	beqz  	$t5, DONE 		# if i ($t1) >= k ($t3) ($t5 = 1) then go to DONE 
 	sll  	$t6, $t1, 2 		# $t6 = i * 4 
 	add  	$t6, $s1, $t6 		# $t6 = address A[i]
 	sll  	$t8, $t1, 2  		# $t8 = i * 4
 	la   	$a0, arrayresult  	# $a0 = address of arrayresult 
 	add  	$t8, $a0, $t8  		# $t8 = address C[i] 
 	lwc1   	$f7, 0($t8)  		# $f7 = C[i]
 	swc1   	$f7, 0($t6)  		# A[i]=	C[i] 
 	addi 	$t1, $t1, 1  		# i++
 	j 	forloop
  
# END MERGE FUNCTION

# Print
PrintArrayOriginal:
	la 	$a0, output1 		# $a0 = address of output1
	li 	$v0, 4
	syscall

	la	$a1, array		# $a1 = address of array
	li 	$t1,0			# $t1 = 0
	j	PrintElement
PrintArrayResult:

	la 	$a0, output2		# $a0 = address of output2
	li 	$v0, 4
	syscall

	la	$a1, array
	li 	$t1,0			# $t1 = 0

PrintElement:
# Check number of loop
	slt 	$t2, $t1, $t0
	beq 	$t2, $0, done		# if index >= n (20) then go to done

# Print element A[i]
	lwc1 	$f12, ($a1)		# Load A[i] to $f12
	li 	$v0, 2			# Print A[i]
	syscall

# Print space "    "
	la	$a0, space
	li 	$v0, 4
	syscall

# Increase index (i++)
	addi 	$t1, $t1, 1		# i++
	addi 	$a1, $a1, 4 		# $a1 = address of the next element

	j PrintElement
done:
	jr	$ra
	
#End
	Exit:
	li 	$v0, 10
	syscall
