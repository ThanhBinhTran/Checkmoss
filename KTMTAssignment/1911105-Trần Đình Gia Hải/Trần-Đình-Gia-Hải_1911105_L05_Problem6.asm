.data
arr:.word -54, -73, -18, -99, -81, -11, -62, -30, 18, 24, -49, -32, 25, -12, -90, 26, -57, -35, 2, 6 # Array to sort
space:.byte' '
endl:.byte'\n'
temp:.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 # Array tam, phuc vu cho ham merge
temp2:.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 # Aray tam, phuc vu cho ham merge
line1:.asciiz "Mang con merge"
line2:.asciiz "Mang hien tai sau khi merge"
line3:.asciiz "Mang con ben trai"
line4:.asciiz "Mang con ben phai"

.text
main:
la $s0, arr
# s1 la bien dem khi in mang
addi $s1, $zero, 0
la $v1, arr

# In day so ban dau
print:
# In phan tu thu i
# Neu i(hay s1) = size thi thoat
beq $s1, 20, endprint
lw $s2, 0($s0)
addi $v0, $zero, 1
add $a0, $zero, $s2
syscall
# In dau cach
addi $v0, $zero, 11
lb $a0, space
syscall
# s1++
addi $s1, $s1, 1
add $s0, $s0, 4
j print
endprint:

# In dau xuong dong
addi $v0, $zero, 11
lb $a0, endl
syscall

# Load nhung bien can thiet de thuc hien thuat toan mergesort
la $s0, arr   
addi $s1, $zero, 0
addi $t0, $zero, 0     #$t0 la left
addi $t1, $zero, 19    #$t1 la right
addi $t7, $zero, 2
jal mergesort
j end
exit:
jr $ra   #Nhay den nhan jal cuoi cung

mergesort:
sub $a1, $t1, $t0
addi $a1, $a1, 1   # Tinh size voi a1 la size = right - left + 1
slti $s3, $a1, 2   # Neu a1 = size < 2 thi s3 = 1
beq $s3, 1, exit   # Neu s3 = 1, nhay den exit, nhay den end ket thuc chuong trinh
sub $a1, $a1, 1
div $a1, $t7
mflo $a1  
add $t2, $t0, $a1  #$t2 la middle


# Luu cac thanh ghi vao stack truoc khi goi de quy mergesort(left,middle)
addi $sp, $sp, -20
sw $ra, 0($sp)
sw $t0, 4($sp)            # Luu thanh ghi left 
sw $t1, 8($sp)            # Luu thanh ghi right
sw $a1, 12($sp)           # Luu thanh ghi size 
sw $t2, 16($sp)           # Luu thanh ghi middle
add $t1, $zero, $t2   

jal mergesort       # Goi ham de quy mergesort(left,middle)

# Load lai nhung thanh ghi da luu truoc do sau khi thuc thi ham de quy mergesort(left,middle)
lw $ra, 0($sp)           # Load thanh ghi ra
lw $t0, 4($sp)            # Load thanh ghi left
lw $t1, 8($sp)            # Load thanh ghi right
lw $a1, 12($sp)           # Load thanh ghi size
lw $t2, 16($sp)           # Load thanh ghi middle
addi $sp, $sp, 20        # Xoa stack

# Luu cac thanh ghi vao stack truoc khi goi de quy mergesort(middle+1,right)
addi $sp, $sp, -20 
sw $ra, 0($sp)
sw $t0, 4($sp)            # Luu thanh ghi left 
sw $t1, 8($sp)            # Luu thanh ghi right
sw $a1, 12($sp)           # Luu thanh ghi size 
sw $t2, 16($sp)           # Luu thanh ghi middle
add $t0, $zero, $t2
addi $t0, $t0, 1

jal mergesort        # Goi ham de quy mergesort(middle+1,right)
 
 # Load lai nhung thanh ghi da luu truoc do sau khi thuc thi ham de quy mergesort(middle+1,right)
lw $ra, 0($sp)            # Load thanh ghi ra
lw $t0, 4($sp)            # Load thanh ghi left
lw $t1, 8($sp)            # Load thanh ghi right
lw $a1, 12($sp)           # Load thanh ghi size
lw $t2, 16($sp)           # Load thanh ghi middle
addi $sp, $sp, 20        # Xoa stack

# Luu cac thanh ghi vao stack truoc khi goi ham merge
addi $sp, $sp, -20 
sw $ra, 0($sp)
sw $t0, 4($sp)            # Luu thanh ghi left 
sw $t1, 8($sp)            # Luu thanh ghi right
sw $a1, 12($sp)           # Luu thanh ghi size 
sw $t2, 16($sp)           # Luu thanh ghi middle
jal merge      # Goi ham merge

# Load lai nhung thanh ghi da luu truoc do sau khi thuc thi ham merge
lw $ra, 0($sp)               # Load thanh ghi ra
lw $t0, 4($sp)               # Load thanh ghi left
lw $t1, 8($sp)               # Load thanh ghi right
lw $a1, 12($sp)              # Load thanh ghi size
lw $t2, 16($sp)              # Load thanh ghi mid 
addi $sp, $sp, 20           # Xoa stack
j exit

merge: # Merge 2 day so da sap xep
sub $t3, $t2, $t0
addi $t3, $t3, 1   # $t3 = size_left
sub $t4, $t1, $t2  # $t4 = size_right
la $a2, temp      # $a2 la day so tam
la $a3, temp2     # $a3 la day so tam
la $v1, 0($s0)
mul $s2, $t0, 4
add $v1, $v1, $s2
addi $t5, $zero, 0
# In dong ghi chu mang ben trai can merge (hay mang a2)
addi $v0, $zero, 4
la $a0, line3
syscall
# In dau xuong dong
addi $v0, $zero, 11
lb $a0, endl
syscall

# Mang a2 luu cac phan tu tu s0[left] den s0[mid]
# Bat dau gan cac phan tu tu s0[left] den s0[mid] vao mang a2
for1:  
beq $t5, $t3, loop1 
lw $k0, 0($v1)
sw $k0, 0($a2)
# In phan tu thu i trong mang a2
addi $v0, $zero, 1
addi $a0, $k0, 0
syscall
# In dau cach
addi $v0, $zero, 11
lb $a0, space
syscall
addi $t5, $t5, 1
addi $v1, $v1, 4
addi $a2, $a2, 4
j for1

loop1:  # Dua con tro a2 tro ve vi tri a2[0]
beq $t5, 0, stop1
subi $a2, $a2, 4
subi $t5, $t5, 1
j loop1
stop1:
addi $t5, $zero, 0
# In dau xuong dong
addi $v0, $zero, 11
lb $a0, endl
syscall
# In dong ghi chu mang ben phai can merge (hay mang a3)
addi $v0, $zero, 4
la $a0, line4
syscall
# In dau xuong dong
addi $v0, $zero, 11
lb $a0, endl
syscall

# Mang a3 luu cac phan tu tu s0[mid+1] den s0[right]
# Bat dau gan cac phan tu tu s0[mid+1] den s0[right] vao mang a2
for2:  
beq $t5, $t4, loop2 
lw $k0, 0($v1)
sw $k0, 0($a3)
# In phan tu thu i trong mang a3
addi $v0, $zero, 1
addi $a0, $k0, 0
syscall
# In dau cach
addi $v0, $zero, 11
lb $a0, space
syscall
addi $t5, $t5, 1
addi $v1, $v1, 4
addi $a3, $a3, 4
j for2

loop2:   # Dua con tro a3 tro ve vi tri a3[0]
beq $t5, 0, stop2
subi $a3, $a3, 4
subi $t5, $t5, 1
j loop2
stop2:
# In dau xuong dong
addi $v0, $zero, 11
lb $a0, endl
syscall
addi $t5, $zero, 0  # index_left
addi $t6, $zero, 0  # index_right
addi $t9, $t0, 0

# Bat dau sap xep lai tu s0[left] den s0[right], bien dem k bat dau tu k=left
la $v1, 0($s0)
add $v1, $v1, $s2
# Bat dau vong lap while khi ca 2 day a2 va a3 con phan tu
while:
beq $t5, $t3, exitwhile  # Neu day a2 het phan tu thi thoat khoi while
beq $t6, $t4, exitwhile  # Neu day a3 het phan tu thi thoat khoi while
lw $k0, 0($a2)
lw $k1, 0($a3)
slt $t8, $k0, $k1
# Neu a2[i]<a3[j] thi s0[k]=a2[i]
beq $t8, 1, ganbentrai
lw $k0, 0($a3)
sw $k0, 0($v1)
addi $t6, $t6, 1  # j++
addi $v1, $v1, 4  # k++
addi $t9, $t9, 1
addi $a3, $a3, 4 
j while

# Neu a2[i]>a3[j] thi s0[k]=a3[j]
ganbentrai: 
lw $k0, 0($a2)
sw $k0, 0($v1)
addi $t5, $t5,1  #i++
addi $v1, $v1,4  #k++
addi $t9, $t9,1
addi $a2, $a2,4
j while

exitwhile:
beq $t5, $t3, while2  # Chuyen qua while2 khi day a2 het phan tu
beq $t6, $t4, while3  # Chuyen qua while3 khi day a3 het phan tu

while2:
# Khi day a2 het phan tu thi s0[k]=a3[j] cho den khi j=right-mid
beq $t6, $t4,anotherloop
lw $k0, 0($a3)
sw $k0, 0($v1)
addi $t6, $t6, 1 #j++
addi $a3, $a3, 4
addi $v1, $v1, 4 #k++
addi $t9, $t9, 1
j while2

while3:
# Khi day a2 het phan tu thi s0[k]=a2[i] cho den khi i=mid-left+1
beq $t5, $t3, anotherloop
lw $k0, 0($a2)
sw $k0, 0($v1)
addi $t5, $t5, 1 #i++
addi $a2, $a2, 4
addi $v1, $v1, 4 #k++
addi $t9, $t9, 1
j while3

# Dua con tro v1 ve vi tri ban dau la s0[0]
anotherloop:
beq $t9, 0, abort # Khi v1=s0[0] thi thoat
subi $v1, $v1, 4
subi $t9, $t9, 1
j anotherloop

abort:
# Bat dau cac thao tac in mang
la $s0, 0($v1)
# Dua con tro s0 vao vi tri left
add $s0, $s0, $s2
# t6 la size cua mang con duoc merge (size cua t6 la right-left)
sub $t6, $t1, $t0
addi $t6, $t6, 1
# In dong chu thich mang con duoc mergre
addi $s1, $zero, 0
addi $v0, $zero, 4
la $a0, line1
syscall
# In dau xuong dong
addi $v0, $zero, 11
lb $a0, endl
syscall
# In mang con duoc merge
print2:
lw $s2, 0($s0)
addi $v0, $zero, 1
add $a0, $zero, $s2
syscall
# In dau cach
addi $v0, $zero, 11
lb $a0, space
syscall
addi $s1, $s1, 1
add $s0, $s0, 4
beq $s1, $t6, endprint2
j print2
endprint2:
addi $v0, $zero, 11
lb $a0, endl
syscall

# Dua con tro s0 ve vi tri ban dau s0[0]
la $s0, 0($v1)
addi $s1, $zero, 0
# In dong ghi chu mang hien tai sau khi merge mang con
addi $v0, $zero, 4
la $a0, line2
syscall
# In dau xuong dong
addi $v0, $zero, 11
lb $a0, endl
syscall
# In day so hien tai sau khi merge
print3:
lw $s2, 0($s0)
addi $v0, $zero, 1
add $a0, $zero, $s2
syscall
# In dau cach
addi $v0, $zero, 11
lb $a0, space
syscall
addi $s1, $s1, 1
add $s0, $s0, 4
beq $s1, 20, endprint3
j print3
endprint3:
# In dau xuong dong
addi $v0, $zero, 11
lb $a0, endl
syscall
# Dua con tro #s0 ve vi tri ban dau la s0[0]
la $s0, 0($v1)
addi $s1, $zero, 0
jr $ra

end:
