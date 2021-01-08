.data 
array: .word 20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1
space: .asciiz " "
P: .asciiz "partition: "
high: .asciiz "high: "
low: .asciiz "low: " 
newline: .asciiz "\n"
.text 
.globl main

main:
la $t0, array 
addi $a0, $t0, 0                # Set argument 1 to the array.
addi $a1, $zero, 0              # low
addi $a2, $zero, 19             # high
jal Quicksort                   # Call quick sort
jal print                       # Print sorted array
li $v0, 10                      # Terminate program run and
syscall                         # Exit

print:
   addi $sp, $sp, -12	        # Make stack room for 3
   sw $a0, 0($sp)		# Store a0
   sw $a1, 4($sp)		# Store a1
   sw $a2, 8($sp)               # Store a2
   
   li $v0, 4
   la $t7, array
   addi $t0, $0, 0              # t0 = 0
   st:
      beq $t0, 20, e             # t0 = 8
   
      sll $t1, $t0, 2		# t1 = 4*i
      add $t1, $t7, $t1	        # t1 = arr + 4*i
      lw $t2, 0($t1)            # t2 = arr[i]
   
      addi $a0, $t2, 0          
      li $v0, 1                 # print arr[i]
      syscall
   
      li $v0, 4
      la $a0, space             # print space " "
      syscall
   
      addi $t0, $t0, 1          # i++
   
      j st
   
   e:
   li $v0, 4
   la $a0, newline              # print endline
   syscall
   
   lw $a0, 0($sp)		# Load a0
   lw $a1, 4($sp)		# Load a1
   lw $a2, 8($sp)               # Load a2
   addi $sp, $sp, 12
   jr $ra
   
Quicksort:
   addi $sp, $sp, -20           # Make stack room for 5
   sw $a0, 0($sp)		
   sw $a1, 4($sp)		
   sw $a2, 8($sp)
   sw $ra, 12($sp)
   
   addi $t0, $a1, 1            # t0 = low + 1
   slt $t0, $a2, $t0           # high < low + 1 (high <= low), jump to endQS
   beq $t0, 1, endQS         
   
   jal print                    # Call print
   
   jal partition
   add $s0, $v0, $0             # s0 = partition
   
   jal print_partition
   
   sw $s0, 16($sp)              # Store partition       
   lw $a1, 4($sp)
   addi $a2, $s0, -1  
   jal Quicksort                # Quicksort (low, partition - 1)
   
   lw $s0, 16($sp)              # Load partition
   addi $a1, $s0, 1
   lw $a2, 8($sp)             
   jal Quicksort                # Quicksort (partition + 1, high)
   
   endQS:
      lw $a0, 0($sp)	        	
      lw $a1, 4($sp)		
      lw $a2, 8($sp)
      lw $ra, 12($sp)
      addi $sp, $sp, 20
      
      jr $ra
  
partition:
   addi $sp, $sp, -16
   sw $a0, 0($sp)		
   sw $a1, 4($sp)		
   sw $a2, 8($sp)
   sw $ra, 12($sp)
   
   addi $s1, $a1, 0             # low
   addi $s2, $a2, 0             # high
   
   sll $t3, $s2, 2		# t1 = 4*high
   add $t3, $a0, $t3	        # t1 = arr + 4*high
   lw $t4, 0($t3)		# t2 = arr[high] //pivot
   
   addi $t5, $s1, -1            # t5 l = low - 1
   addi $t6, $s1, 0             # t6 i = low
   
   loop:
      addi $t8, $t6, 1
      slt $t8, $s2, $t8         # high <= i
      beq $t8, 1, endloop  
      
      sll $t3, $t6, 2		# t3 = 4*i
      add $t3, $a0, $t3	        # t3 = arr + 4*i
      lw $t7, 0($t3)		# t7 = arr[i]
      
      addi $t8, $t7, 1
      slt $t8, $t4, $t8         # pivot <= arr[i]
      beq $t8, 1, endif       
      
      addi $t5, $t5, 1          # l++
      
      addi $a1, $t5, 0             
      addi $a2, $t6, 0
      jal swap                  # swap (arr[l], arr[i]
      
      endif:
         addi $t6, $t6, 1       # i++
         j loop
   endloop:
      lw $a2, 8($sp)            # a2: high
      addi $a1, $t5, 1          # a1: l + 1
      jal swap                  # swap (arr[l + 1], arr[high])
      
      addi $v0, $t5, 1          # return v0 = l + 1
      
      lw $a0, 0($sp)		
      lw $a1, 4($sp)		
      lw $a2, 8($sp)
      lw $ra, 12($sp)
      
      addi $sp, $sp, 16
      
      jr $ra
swap:
   addi $sp, $sp, -16 
   sw $a0, 0($sp)		
   sw $a1, 4($sp)		
   sw $a2, 8($sp)
   sw $ra, 12($sp)
   
   sll $t0, $a1, 2		
   add $t0, $a0, $t0	       
   lw $t1, 0($t0)               # t1 = arr[i]
   
   sll $t2, $a2, 2		
   add $t2, $a0, $t2	       
   lw $t3, 0($t2)               # t3 = arr[j]
   
   sw $t1, 0($t2)               
   sw $t3, 0($t0)
   
   lw $a0, 0($sp)		
   lw $a1, 4($sp)		
   lw $a2, 8($sp)
   lw $ra, 12($sp)
   addi $sp, $sp, 16
   
   jr $ra
print_partition:
   addi $sp, $sp, -16 
   sw $a0, 0($sp)		
   sw $a1, 4($sp)		
   sw $a2, 8($sp)
   sw $ra, 12($sp)
   
   li $v0, 4
   la $a0, P           
   syscall
   addi $a0, $s0, 0
   li $v0, 1                 # print partition
   syscall
   li $v0, 4
   la $a0, space             # print space " "
   syscall
   li $v0, 4
   la $a0, low             
   syscall
   addi $a0, $a1, 0
   li $v0, 1                 # print low
   syscall
   li $v0, 4
   la $a0, space             # print space " "
   syscall
   li $v0, 4
   la $a0, high            
   syscall
   addi $a0, $a2, 0
   li $v0, 1                 # print high
   syscall
   li $v0, 4
   la $a0, newline           # print newline
   syscall
   
   
   lw $a0, 0($sp)		
   lw $a1, 4($sp)		
   lw $a2, 8($sp)
   lw $ra, 12($sp)
   addi $sp, $sp, 16
   
   jr $ra
endd:    
