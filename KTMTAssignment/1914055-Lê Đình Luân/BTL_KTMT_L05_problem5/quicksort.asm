.data
	nums: .word 20
	elems: .word 12,12,15,-2,-2,15,100,-5,0,10,5,5,7,7,3,2,1,-5,-5,100
	Kq: .asciiz"Mang duoc sort lai la: "
	phay: .asciiz","
.text
main:
la $t1,elems #luu dia chi mang vao thanh ghi $t1
la $a3,nums #luu dia chi nums vao $a2
lw $a3,0($a3)
addi $t0,$zero,0 #t0 luon bang 0
addi $t4,$zero,4 #t4 luon bang 4
addi $a2,$a3,-1 #a2 chi so phan tu cuoi nums-1 hight
addi $a1,$zero,0 #a1 chi so phan tu dau cua mang low
jal quicksort
#in ket qua
li $v0,4
la $a0,Kq
syscall

add $s4,$0,$0
la $s5,elems
Loop:
slt,$s6,$s4,$a3
beq $s6,$0,Endpr

li $v0,1
lw $a0,0($s5)
syscall

addi $a0, $0, ' ' 
li $v0, 11 
syscall

addi $s5,$s5,4
addi $s4,$s4,1
j Loop
Endpr:

	# End Program
        li $v0, 10
        syscall

quicksort:
        #store
	addi $sp,$sp,-16              
	sw $ra,0($sp)                 
	sw $a2,4($sp)	              
	sw $a1,8($sp)                 
	sw $s7,12($sp)                
	#body			
	slt $s4,$a1,$a2
	beq $s4,$0,exitIf2
	jal partition                 #goi ham partition
	add $s7,$zero,$v0             #gan gia tri tra ve cua ham partition cho s7

	addi $a2,$s7,-1	              #hight=pivot-1
	jal quicksort

	addi $a1,$s7,1                #low=pivot+1
	lw $a2,4($sp) 
	jal quicksort
	exitIf2:
	#load
	lw $ra,0($sp)
	lw $a2,4($sp)
	lw $a1,8($sp)
	lw $s7,12($sp)
	addi $sp,$sp,16
	#return
	jr $ra

partition:
        #store
	addi $sp,$sp,-16
	sw $ra,0($sp) #luu lai dia chi $ra
	sw $s1,4($sp) #luu lai i
	sw $s2,8($sp) #luu lai j
	sw $s3,12($sp)
        #body
        
        mul $t3,$t4,$a1   #khoang cach gi?a t1 va s1
        add $s1,$t1,$t3   #s1 luu dia chi begin
        add $s3,$s1,$0    #s3 la s1 ti nua xai sau
        lw $t2,0($s1)  # t2=p=start[0]
        mul $t3,$t4,$a2   #khoang cach giua t1 va a2
        add $s2,$t1,$t3   #s2 luu dia chi begin
        addi $s2,$s2,4
        loopofpar1:
        #do
           loopofpar2:
           #do
           addi $s1,$s1,4
           #xet dk
           lw $t5,0($s1)  
           slt $t6,$t2,$t5
           beq $t6,$0,loopofpar2
           #end
           loopofpar3:
           #do
           addi $s2,$s2,-4
           #xet dk
           lw $t5,0($s2)  
           slt $t6,$t2,$t5
           addi $t7,$0,1
           beq $t6,$t7,loopofpar3
           #end 
        lw $t5,0($s1)
        lw $t6,0($s2)
        sw $t5,0($s2)
        sw $t6,0($s1)
        #xet dk
        slt $t5,$s1,$s2
        addi $t7,$0,1
        beq $t5,$t7,loopofpar1
        #end
        lw $t5,0($s1)
        lw $t6,0($s2)
        sw $t5,0($s2)
        sw $t6,0($s1)
        
        lw $t5,0($s3)
        lw $t6,0($s2)
        sw $t5,0($s2)
        sw $t6,0($s3)
        
        sub $v0,$s2,$t1
        div $v0,$v0,$t4
 
        #load 
	lw $ra,0($sp)
	lw $s1,4($sp) 
	lw $s2,8($sp)
	lw $s3,12($sp)
	addi $sp,$sp,16
	jr $ra
