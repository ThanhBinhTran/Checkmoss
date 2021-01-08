.data
enterA: .asciiz"Please enter A = "
enterB: .asciiz"Please enter B = "
multiply: .asciiz"Multiply floating point  A x B la = "
.text
#read A
li $v0 4
la $a0 enterA
syscall

li $v0 6
syscall
mov.s $f1 $f0
#read B
li $v0 4
la $a0 enterB
syscall

li $v0 6
syscall
mov.s $f2 $f0

#save memory
lui $s0 0x1001
add $s0 $s0 0x80
# f1 f2 to memory
s.s $f1 0 ($s0)
s.s $f2 4 ($s0)
# memory to register
lw $t1 0 ($s0)
lw $t2 4 ($s0)
# bit sign
srl $s1 $t1 31
srl $s2 $t2 31
beq $s1 $s2 equal

# different
sll $s3 $t1 1
srl $s3 $s3 24

sll $s4 $t2 1
srl $s4 $s4 24
# fration
sll $s5 $t1 9
srl $s5 $s5 9
addu $s5 $s5 0x800000

sll $s6 $t2 9
srl $s6 $s6 9
addu $s6 $s6 0x800000

#sign + sign - bias
addu $s7 $s3 $s4
subu $s7 $s7 127
#mul fraction
mul $t3 $s5 $s6
mfhi $t4
mflo $t6
srl $t5 $t4 15
beq $t5 1 equal1
# 24 bit fraction
sll $t4 $t4 9
srl $t6 $t6 23
addu $t4 $t4 $t6
j end
equal1:
sll $t4 $t4 8
srl $t6 $t6 24
addu $t4 $t4 $t6
addu $s7 $s7 1
end:
#move bit 
sll $t4 $t4 9
srl $t4 $t4 9
sll $s7 $s7 23
addu $t4 $t4 $s7
addu $t4 $t4 0x80000000
#end
sw $t4 0($s0)
l.s $f12 0($s0)

li $v0 4
la $a0 multiply
syscall

li $v0 2
syscall

li $v0 10
syscall


# same
equal:
# bit extend
sll $s3 $t1 1
srl $s3 $s3 24

sll $s4 $t2 1
srl $s4 $s4 24
# bit fraction
sll $s5 $t1 9
srl $s5 $s5 9
addu $s5 $s5 0x800000

sll $s6 $t2 9
srl $s6 $s6 9
addu $s6 $s6 0x800000

# sign + sign - bias
addu $s7 $s3 $s4
subu $s7 $s7 127
# fraction
mul $t3 $s5 $s6
mfhi $t4
mflo $t6
srl $t5 $t4 15
beq $t5 1 equal12
# 24 fraction
sll $t4 $t4 9
srl $t6 $t6 23
addu $t4 $t4 $t6
j end2
equal12:
sll $t4 $t4 8
srl $t6 $t6 24
addu $t4 $t4 $t6
addu $s7 $s7 1
end2:
# move bit
sll $t4 $t4 9
srl $t4 $t4 9
sll $s7 $s7 23
addu $t4 $t4 $s7
#end
sw $t4 0($s0)
l.s $f12 0($s0)

li $v0 4
la $a0 multiply
syscall

li $v0 2
syscall

li $v0 10
syscall
