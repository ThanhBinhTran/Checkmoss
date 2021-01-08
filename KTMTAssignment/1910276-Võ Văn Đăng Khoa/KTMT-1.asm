.data
newline: .asciiz "\n"
space: .asciiz " "
Array: .word 1 3 5 7 9 2 4 6 8 10 11 13 15 17 19 12 14 16 18 0
L: .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
R: .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
.text
main:
la $s0, Array #Assign array to $s0
li $t0, 0 #i = 0
PrintUnsortedLoop:
beq $t0, 20, endloop #Check condition
lw $a0, 0($s0) #Assign element to $a0
li $v0, 1 #Assign 1 to $v0 to print integer
syscall
la $a0, space #Assign space to $a0
li $v0, 4 #Assign 4 to $v0 to print string
syscall
addi $t0, $t0, 1 #Increment i by 1
addi $s0, $s0, 4 #Increment array by 4 to access next element
j PrintUnsortedLoop #loop
endloop:
la $a0, newline #Assign newline to $a0
li $v0, 4 #Assign 4 to $v0 to print string
syscall

la $s0, Array #Reassign array to $s0
li $t0, 0 #Set $t0 to low
li $t1, 19 #Set $t1 to high (size - 1)
li $k0, 2 #For divsion purpose
jal MERGESORT
j END
EXIT:
jr $ra #Jump to last jal

MERGESORT:
sub $a3,$t1,$t0
addi $a3,$a3,1 #Calculate $a3 = size = (high - low) + 1
blt $a3, 2, EXIT #Check condition to end MERGESORT
sub $a3,$a3,1
div $a3,$k0
mflo $a3
add $t3,$t0,$a3 #Calculate $t3 = middle = (high - low) / 2

#Necessary parameters to save in stack before calling MERGESORT(low, middle) recursively
addi $sp, $sp, -20 #Make space for stack
sw $ra, 0($sp) #Save return address into stack
sw $t0,4($sp) #Save low into stack
sw $t1,8($sp) #Save high into stack
sw $a3,12($sp) #Save size into stack
sw $t3,16($sp) #Save middle into stack
add $t1,$zero,$t3 #Set new high = previous middle

jal MERGESORT #Call MERGESORT(low, middle) recursively

#Load necessary parameters that were saved after doing MERGESORT(low, middle) recursively
lw $ra, 0($sp) #Load return address from stack
lw $t0,4($sp) #Load low from stack
lw $t1,8($sp) #Load high from stack
lw $a3,12($sp) #Load size from stack
lw $t3,16($sp) #Load middle from stack
addi $sp, $sp, 20 #Reset stack

#Necessary parameters to save in stack before calling MERGESORT(middle + 1, high) recursively
addi $sp, $sp, -20 #Make space for stack
sw $ra,0($sp) #Save address into stack
sw $t0,4($sp) #Save low into stack
sw $t1,8($sp) #Save high into stack
sw $a3,12($sp) #Save size into stack
sw $t3,16($sp) #Save middle into stack
add $t0,$zero,$t3
addi $t0,$t0,1 #Set new low = previous middle + 1

jal MERGESORT #Call MERGESORT(middle + 1, high) recursively
 
#Load necessary parameters that were saved after doing MERGESORT(middle + 1, high) recursively
lw $ra,0($sp) #Load return address from stack
lw $t0,4($sp) #Load low from stack
lw $t1,8($sp) #Load high from stack
lw $a3,12($sp) #Load size from stack
lw $t3,16($sp) #Load middle from stack
addi $sp, $sp, 20 #Reset stack

#Necessary parameters to save in stack before calling MERGE
addi $sp, $sp, -20 #Make space for stack
sw $ra,0($sp) #Save address into stack
sw $t0,4($sp) #Save low into stack 
sw $t1,8($sp) #Save high into stack
sw $a3,12($sp) #Save size into stack
sw $t3,16($sp) #Save middle into stack

jal MERGE #Call MERGE

#Load necessary parameters that were saved after doing MERGE recursively
lw $ra,0($sp) #Load return address from stack
lw $t0,4($sp) #Load low from stack
lw $t1,8($sp) #Load high from stack
lw $a3,12($sp) #Load size from stack
lw $t3,16($sp) #Load middle from stack
addi $sp, $sp, 20 #Reset stack
j EXIT

MERGE:
sub $t4,$t3,$t0
addi $t4,$t4,1 #Calculate $t4 = size of left side of array = middle - low + 1
sub $t5,$t1,$t3 #Calculate $t5 = size of right side of array = high - middle
la $s1,L #Set $s1 to hold a temp array for left side
la $s2,R #Set $s2 to hold a temp array for right side
la $a2,0($s0) 
mul $t9,$t0,4 
add $a2,$a2,$t9 #Set $a2 to element array[left]

li $t7,0 #i = 0
la $s3, 0($s1) #Set $s3 to hold the address for temp array (left side)
forleft: #Loop to assign left side of array to temp array
beq $t7,$t4,endleft #Check condition
lw $t6,0($a2) #Load element of current array
sw $t6,0($s1) #Save to element of temp array (left side)
addi $t7,$t7,1 #Increment i by 1
addi $a2,$a2,4 #Increment array by 4 to access next element
addi $s1,$s1,4 #Increment array by 4 to access next element
j forleft
endleft:
la $s1, 0($s3) #Set temp array (left side) back to its first element

li $t7,0 #i = 0
la $s3, 0($s2) #Set $s2 to hold the address for temp array (right side)
forright: #Loop to assign right side of array to temp array
beq $t7,$t5,endright #Check condition
lw $t6,0($a2) #Load element of current array
sw $t6,0($s2) #Save to element of temp array (right side)
addi $t7,$t7,1 #Increment i by 1
addi $a2,$a2,4 #Increment array by 4 to access next element
addi $s2,$s2,4 #Increment array by 4 to access next element
j forright
endright:
la $s2, 0($s3) #Set temp array (right side) back to its first element

li $t7, 0 #Set $t7 to left index
li $t8, 0 #Set $t8 to right index
la $a2, 0($s0)
add $a2, $a2, $t9 #Set $a2 to element array[left]

while:
beq $t7, $t4, exitwhile 
beq $t8, $t5, exitwhile #Check condition to exit when reach the end of either array
lw $s6, 0($s1) 
lw $s7, 0($s2) #Get same index element from both array for comparison
blt $s6, $s7, addleft #Compare the 2 elements to choose which one to sort into array
sw $s7, 0($a2) #Save the element from temp array (right side) into array
addi $t8, $t8, 1 #Increment i by 1
addi $s2, $s2, 4 #Increment array by 4 to access next element
addi $a2, $a2, 4 #Increment array by 4 to access next element
j while
addleft:
sw $s6, 0($a2) #Save the element from temp array (left side) into array
addi $t7, $t7, 1 #Increment i by 1
addi $s1, $s1, 4 #Increment array by 4 to access next element
addi $a2, $a2, 4 #Increment array by 4 to access next element
j while

exitwhile:

whileleft: #Save all remaining elements in temp array (left side) back into array
beq $t7, $t4, exitleft #Check if index has reach the end of temp array (left side)
lw $s6, 0($s1) #Load element from temp array (left side)
sw $s6, 0($a2) #Save element into array
addi $t7, $t7, 1 #Increment i by 1
addi $s1, $s1, 4 #Increment array by 4 to access next element
addi $a2, $a2, 4 #Increment array by 4 to access next element
j whileleft
exitleft:

whileright: #Save all remaining elements in temp array (right side) back into array
beq $t8, $t5, exitright #Check if index has reach the end of temp array (right side)
lw $s7, 0($s2) #Load element from temp array (right side)
sw $s7, 0($a2) #Save element into array
addi $t8, $t8, 1 #Increment i by 1
addi $s2, $s2, 4 #Increment array by 4 to access next element
addi $a2, $a2, 4 #Increment array by 4 to access next element
exitright:

la $a2, 0($s0) #Set $a2 to first element of array
add $a2, $a2, $t9 #Set $a2 to the first element of the current merging step
sub $t7, $t1, $t0 
addi $t7, $t7, 1 #Set $t7 to the number of elements in the current merging step
li $t8, 0 #i = 0
printstep:
beq $t8, $t7, exitprint
lw $a0, 0($a2)
li $v0, 1
syscall #Print element
la $a0, space
li $v0, 4
syscall #Print space
addi $t8, $t8, 1 #Increment i by 1
addi $a2, $a2, 4 #Increment $a2 by 4 to access next element
j printstep
exitprint:
la $a0, newline
li $v0, 4
syscall #Print endl
jr $ra
END:
