#Input method picker:
#Hex section
.data
n1: .asciiz " Enter number 1:(Multiplicand or Dividend) "
n2: .asciiz " Enter number 2:(Multiplier or Divisor) "
D1: .asciiz " Remainder: "
D2: .asciiz " Quotient: "
M1: .asciiz " Product: "
text1: .asciiz "        "
ecpt: .asciiz " Division by 0 is not possible"
nl: .asciiz " its newline"
input: .asciiz " 1)Int 2)Hex 3) Float (Maximum 32 bits)"
mess: .asciiz " Must be 8 characters, hex must be uppercase: "
hexin: .asciiz "        "
flp: .asciiz " Review your original assignment please"
expt: .asciiz " Segmentation Fault"
ALUchoice: .asciiz " Choose your poison 1)Multiplier 2) Divider "
#S4 is our mode storage
.text
#First ask input mode
la $a0, input
li $v0, 4
syscall
li $v0, 5
syscall
#Mode branch
move $s4,$v0
beq $s4, 1, Int
beq $s4,2, Hex
beq $s4,3, Float
#Exception handler
j Exception
#Int is natively supported by the algorithm
Int:
la $a0, n1
li $v0, 4
syscall
li $v0,5
syscall
move $s6, $v0
la $a0, n2
li $v0, 4
syscall
li $v0, 5
syscall
move $s7, $v0
j ALU
#Print out our little message, the ALU will be implemented later if I feel like it.
Float:
la $a0, flp
li $v0, 4
syscall	
j exit
#jump to exception but can be changed to another one if implemented later
Hex: 
la $a0, n1
li $v0, 4
syscall
jal Hexconvert
move $s6, $a0
la $a0, n2
li $v0, 4
syscall
jal Hexconvert
move $s7, $a0
j ALU
#Our hex converter, can be called later
#Promt user interaction using syscall 54
Hexconvert:
addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
syscall
la $a0, mess # Message buffer address
li $v0, 4
syscall
addi $a0, $0, 0xA #ascii code for LF, if you have any trouble try 0xD for CR.
addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
syscall
la $a0, hexin #Input buffer address, will be our intermadiate
li $a1, 10 # Maximum accepted characters, derived from 32bits / 4bits each positions + null terminate
li $v0, 8 # Prompt for input string
syscall
#la baseaddress, hexin # Our intermediate buffer address
#move termaddress, baseaddress
la $t5, hexin
move $t6,$t5
li $a1, 0
li $t7,0
cont:
	lb $a0, 0($t6) #Load character at address
	beq $a0, 10, Hexcon #Look for NULL termination
	subu $a1, $t6, $t5	
	addi $t6, $t6, 1#Offset 1 for every bytes we compare
	j cont
#PreHexcon:
#sub counter, termaddress, baseaddress # Derive number of chars from termination address - base address
Hexcon:
lb $t9, ($t5)
beqz $t9, Hexout
li $t2, 0
sle $t2, $t9, 57
bnez $t2, numex
#ble $t9, 57, numex # In the number range
li $t2, 0
sge $t2, $t9, 65
bnez $t2, charex
#bge $t9, 65, charex# In the uppercase character range
j Exception
numex:
li $t2, 0
slti $t2, $t9, 47
bnez $t2, Exception
#blt $t9, 48, Exception # Make sure is in the number range
subi $t9, $t9, 48 #Substract the difference
j Hconti
charex:
li $t2, 0
sgt $t2, $t9, 70
bnez $t2, Exception
#bgt $t9, 70, Exception #Make sure is in the uppercase range
subi $t9, $t9, 55 #Substract the difference
j Hconti
Hconti:
addi $t5, $t5, 1
sll $t7, $t7, 4
add $t7,$t7, $t9
beq $t5,$t6, Hexout
j Hexcon
Hexout:
subi $a1,$a1,1
#la $a0,hexin
#li $v0, 4
#syscall
move $a0,$t7
jr $ra
newline:
la $a0, nl
li $v0,4
syscall
return:
jr $ra
#-----------------------------------------------------------------------
#		ALU BLOCK IS HERE, END OF MODE SWITCH
#-----------------------------------------------------------------------
ALU:
move $a0, $s6
move $a1, $s7
la $a0, ALUchoice
li $v0, 4
syscall
li $v0, 5
syscall
beq $v0,1, Mul
beq $v0,2, Div
j Exception
Mul:
Mulstart:
#move $s6, $a0
#move $s7, $a1
move $t6, $s6
move $t7, $s7
li $t4, 0
li $t2, 0
sgt $t2, $t6, 0
bnez $t2, Mul1
#bgtz $t6, Mul1
sub $t6, $0,$t6
Mul1:
li $t2, 0
sgt $t2, $t7, 0
bnez $t2, Mul2
#bgtz $t7, Mul2
sub $t7, $0,$t7
Mul2:
li $t4, 0
li $a0, 0
Mulcon:
andi $t9,$t7,1 #test multiplier0
beqz $t9, Mul00
add $a0, $a0, $t6 #mul0 = 1
Mul00:
sll $t6,$t6, 1
srl $t7,$t7, 1
addi $t4,$t4,1
beq $t4,31,Mulexit
j Mulcon
Mulexit:
li $a1, 0
li $t5, 0
slt $t6, $s6, $0
slt $t7, $s7, $0
xor $t5, $t6, $t7
beqz $t5, ALUexit
sub $a0, $0, $a0
j ALUexit
Div:
Divstart:
#move $s6, $a0
#move $s7, $a1
move $t6, $s6 # N
move $t7, $s7 # D
bgtz $t6, Div1
sub $t6, $0,$t6
Div1:
bgtz $t7, Div2
sub $t7, $0,$t7
Div2:
beqz $s7, DivZero
li $a0, 0 #Remainder
li $a1, 0 #Quotient
li $t4,0x80000000 #i
#beqz $s6, DivZero
Div00:
sll $a0, $a0, 1 # Left shift R 1 bit
and $t2, $s6, $t4
beqz $t2, RNi
ori $a0,$a0,1
RNi: #Set R's LSB to bit i
li $t2, 0
sltu $t2, $a0, $s7
bnez $t2, RLTD
subu $a0, $a0, $s7
or $a1, $a1, $t4
RLTD: 
srl $t4,$t4,1
beqz $t4, Divdone
j Div00
Divdone:
li $t5, 0
slt $t6, $s6, $0
slt $t7, $s7, $0
xor $t5, $t6, $t7
beqz $t6, Dends
sub $a0, $0, $a0
Dends:
beqz $t5, ALUexit
sub $a1, $0, $a1
j ALUexit
ALUexit:
move $s6, $a0
move $s7, $a1
#j modeoutput
#modeoutput:
#beq $s4, 1, INT
beq $s4,2, HEX
#INT:
move $t6, $a0
move $t7, $a1
la $a0, D1
li $v0, 4
syscall
move $a0, $t6
li $v0, 1
syscall
addi $a0, $0, 0xD #ascii code for LF, if you have any trouble try 0xD for CR.
addi $v0, $0, 0xB #syscall 11 prints the lower 8 bits of $a0 as an ascii character.
syscall
la $a0, D2
li $v0, 4
syscall
move $a0, $t7
li $v0, 1
syscall
j exit
#move $a0, $t4
#li $v0,1
#syscall
#--------------------------------------------------------------
#		END OF THE ALU BLOCK
#		HEXCONVERTER BLOCK, SHOULD BE IGNORED IF CHOSEN OTHER MODE
#--------------------------------------------------------------
HEX:
move $a0,$s6
la $a1, text1
jal Hexoutput
la $a0, D1
li $v0,4
syscall
la $a0, text1
li $v0, 4
syscall
move $a0,$s7
la $a1, text1
jal Hexoutput
la $a0, D2
li $v0, 4
syscall
la $a0, text1
li $v0, 4
syscall
j exit
Hexoutput:
move $t0, $a0
addi $a1, $a1, 7
li $t4,0
Hexoutcont:
andi $t8, $t0, 15
srl $t0, $t0, 4
# Store the least 4 bits, shift them away
bltz $t8, Exception
bgt $t8, 15, Exception
bge $t8, 10, tenover
bgez $t8, nineunder
tenover:
addi $t8, $t8, 55
j here
nineunder:
addi $t8, $t8, 48
j here
here:
sb $t8, ($a1)
#sb $0, 4($a1)
subi $a1, $a1,1
addi $t4, $t4,1
beq $t4, 8, return
j Hexoutcont
DivZero:
la $a0, ecpt
li $v0, 4
syscall
j exit
Exception:
la $a0, expt
li $v0, 4
syscall
exit:
