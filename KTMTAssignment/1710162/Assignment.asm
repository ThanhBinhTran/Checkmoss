.data
  array: .word 4 20 23 11 2 8 24 39 36 17 22 43 29 13 31 38 10 6 46 27
  original: .asciiz "Original Array\n"
  leftPart: .asciiz "Left Part\n"
  rightPart: .asciiz "Right Part\n"
  newLine: .asciiz "\n"
  beforeMerge: .asciiz "Before Merge\n"
  afterMerge: .asciiz "After Merge\n"
  final: .asciiz "Final Result\n"
 
.text
#Print Original Label
main:
li $v0, 4
la $a0, original
syscall

# Load array
la $a0, array

# Get end of array
addi $a1, $0, 20
mul $a1, $a1, 4
add $a1, $a1, $a0

# Print Array
jal printArray
jal printNewLine

# Start Merge Sort
jal mergeSort

# Print Final Label & Print Array
jal printFinal
jal printArray

# End Program
li $v0, 10
syscall


mergeSort:
### Align the address ###
addi $sp, $sp, -4
sw $t0, 0($sp)
addi $t0, $0, 4
sub $a3, $a1, $a0
div $a3, $t0
mfhi $t0
add $a3, $a3, $t0
### Align the address ###
lw $t0, 0($sp)
addi $sp, $sp, 4

# If only 1 element if in array, we will stop sorting
bgt $a3, 4, continueMergeSort
jr $ra

continueMergeSort:
### Saving Stack (excessive) ###
addi $sp, $sp, -20
sw $ra, 0($sp)
sw $t0, 4($sp)
sw $t1, 8($sp)
sw $t2, 12($sp)
sw $a2, 16($sp)
### Saving Stack (excessive) ###

# t0 is middle address
sub $t0, $a1, $a0
div $t0, $t0, 2

### Align middle address####
addi $t2, $0, 4
div $t0, $t2
mfhi $t2
add $t0, $t0, $t2
### align middle address####

# Move middle address to a2
add $t0, $t0, $a0
addi $a2, $t0, 0

#t1 is left part address
addi $t1, $a0, 0
jal printLeftLabel

### Saving Stack (excessive) ###
addi $sp, $sp, -8
sw $a0, 0($sp)
sw $a1, 4($sp)
### Saving Stack (excessive) ###

addi $a0, $t1, 0
addi $a1, $t0, 0
jal printArray
jal printNewLine

# Go deeper to the left
jal mergeSort

### Restoring Stack ###
lw $a0, 0($sp)
lw $a1, 4($sp)
addi $sp, $sp, 8
### Restoring Stack ###

jal printRightLabel

### Saving Stack (excessive) ###
addi $sp, $sp, -8
sw $a0, 0($sp)
sw $a1, 4($sp)
### Saving Stack (excessive) ###

addi $a0, $t0, 0
jal printArray
jal printNewLine
# Go deeper to the right
jal mergeSort

### Restoring Stack ###
lw $a0, 0($sp)
lw $a1, 4($sp)
addi $sp, $sp, 8
### Restoring Stack ###


# This is the real sorting part
jal merge

### Restoring more Stack ###
lw $ra, 0($sp)
lw $t0, 4($sp)
lw $t1, 8($sp)
lw $t2, 12($sp)
lw $a2, 16($sp)
addi $sp, $sp, 20
### Restoring more Stack ###
jr $ra


# merge will create a new array based on size of left and right in $sp
# then write the sorted version to $sp then COPYBACK to orginal array

merge:
#a0 is start address
#a1 is end address
#a2 is middle address

### Saving Stack (excessive) ###
addi $sp, $sp, -20
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $t2, 8($sp)
sw $t3, 12($sp)
sw $ra, 16($sp)
### Saving Stack (excessive) ###

# Print Before Merge #
jal printBeforeMergeLabel 
jal printArray
jal printNewLine
# Print Before Merge #

# t1 and t3 is incrementing address of left and right
addi $t1, $a0, 0
addi $t3, $a2, 0

#allocate for temp array with the size of a0 - a1 (negative)
sub $t4, $a0, $a1
add $sp, $sp, $t4
addi $t5, $sp, 0

mergeLoop:
# Checking if left reach middle and right reach end
bge $t1, $a2, fillLoop1 
bge $t3, $a1, fillLoop1
# Load Value
lw $t0, ($t1)
lw $t2, ($t3)
bgt $t0, $t2, writeRight
# writeLeft part
sw $t0, ($t5)
addi $t1, $t1, 4
addi $t5, $t5, 4
j mergeLoop

writeRight:
sw $t2, ($t5)
addi $t3, $t3, 4
addi $t5, $t5, 4
j mergeLoop

fillLoop1:
# Checking if left has reached middle. if not, fill in the temp array in stack
bge $t1, $a2, fillLoop2 
lw $t0, ($t1)
sw $t0, ($t5)
addi $t1, $t1, 4
addi $t5, $t5, 4
j fillLoop1

fillLoop2:
# Checking if right has reached end. if not, fill in the temp array in stack
bge $t3, $a1, copyBack # if yes, copy the temp array back to the real array
lw $t2, ($t3)
sw $t2, ($t5)
addi $t3, $t3, 4
addi $t5, $t5, 4
j fillLoop2

copyBack:
# t5 t6 us pointing to first of temp array and the left address of real array
addi $t5, $sp, 0
addi $t6, $a0, 0
copyLoop:
# Loop through and copy
bge $t6, $a1, endMerge
lw $t0, ($t5)
sw $t0, ($t6)
addi $t5, $t5, 4
addi $t6, $t6, 4
j copyLoop

endMerge:
# remove the temp array by the size of a1 - a0 (positive)
sub $t4, $a1, $a0
add $sp, $sp, $t4
jal printAfterMergeLabel
jal printArray
jal printNewLine
### Restoring Stack ###
lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $t3, 12($sp)
lw $ra, 16($sp)
addi $sp, $sp, 20
### Restoring Stack ###
jr $ra




printArray:
#a0 is start address
#a1 is end address
addi $sp, $sp, -16
sw $t0, 0($sp)
sw $t1, 4($sp)
sw $t2, 8($sp)

#t0 is next address
addi $t0, $a0, 0
#save to use print function
sw $a0, 12($sp)

printLoop:
bge $t0, $a1, endPrintLoop
#t2 is current value
lw $t2, ($t0)
addi $a0, $t2, 0
li $v0, 1
syscall
li $a0, ' '
li $v0, 11
syscall
addi $t0, $t0, 4
j printLoop

endPrintLoop:
lw $t0, 0($sp)
lw $t1, 4($sp)
lw $t2, 8($sp)
lw $a0, 12($sp)
addi $sp, $sp, 16
jr $ra

printLeftLabel:
addi $sp, $sp, -4
sw $a0, 0($sp)
li $v0, 4
la $a0, leftPart
syscall
lw $a0, 0($sp)
addi $sp, $sp, 4
jr $ra

printRightLabel:
addi $sp, $sp, -4
sw $a0, 0($sp)
li $v0, 4
la $a0, rightPart
syscall
lw $a0, 0($sp)
addi $sp, $sp, 4
jr $ra

printBeforeMergeLabel:
addi $sp, $sp, -4
sw $a0, 0($sp)
li $v0, 4
la $a0, beforeMerge
syscall
lw $a0, 0($sp)
addi $sp, $sp, 4
jr $ra

printAfterMergeLabel:
addi $sp, $sp, -4
sw $a0, 0($sp)
li $v0, 4
la $a0, afterMerge
syscall
lw $a0, 0($sp)
addi $sp, $sp, 4
jr $ra

printNewLine:
addi $sp, $sp, -4
sw $a0, 0($sp)
li $v0, 4
la $a0, newLine
syscall
lw $a0, 0($sp)
addi $sp, $sp, 4
jr $ra

printFinal:
addi $sp, $sp, -4
sw $a0, 0($sp)
li $v0, 4
la $a0, final
syscall
lw $a0, 0($sp)
addi $sp, $sp, 4
jr $ra

