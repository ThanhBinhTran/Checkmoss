.data
text1:  .asciiz "Nhap so thu nhat: "
text2:  .asciiz "Nhap so thu hai: "
text3:  .asciiz "Ket qua phep cong: "
text4:  .asciiz "\nKet qua phep tru: "
num1:  .word       0           # luu dang chuan IEEE 754 cua so thu nhat
num2:  .word       0           # luu dang chuan IEEE 754 cua so thu hai
.text
    #print "Nhap so thu nhat: "
    la  $a0, text1 
    li  $v0, 4
    syscall
    # luu so vua nhap vao num1
    li  $v0, 6
    syscall                 
    swc1    $f0, num1
    #print "Nhap so thu hai: "
    la  $a0, text2
    li  $v0, 4
    syscall
    # luu so vua nhap vao num2
    li  $v0, 6
    syscall                 
    swc1    $f0, num2
    li $a0, 0 #a0=0
    #lay du lieu 2 so luu vao $t0 va $t2
    lw  $t0, num1
    lw  $t2, num2
    #kiem tra neu ca 2 so deu bang 0 thi ket qua la 0
    bnez $t0, sign           #re nhanh neu so thu nhat khac 0 
    bnez $t2, sign           #re nhanh neu so thu hai khac 0
    j zero_2                 #xuat ra ket qua phep cong va tru = 0 neu ca hai so deu la 0
    
substract:                   #doi dau neu thuc hien phep tru
   #neu da thuc hien doi thu tu trong phep cong, doi dau so thu nhat
   beq      $a1, 1, change_sign       #a1=1 neu trong phep cong da doi thu tu 2 so
   addiu     $t2, $t2, 0x80000000     #doi dau so thu hai
   j        sign
   
change_sign:
   addiu     $t0, $t0, 0x80000000     #doi dau so thu nhat
sign:
    move    $t4, $t0
    andi    $t4, $t4, 0x80000000      #luu bit dau so thu nhat vao $t4

    move    $t5, $t2
    andi    $t5, $t5, 0x80000000      #luu bit dau so thu hai vao $t5

    #doi thu tu 2 so neu so thu nhat am de phu hop cho tinh toan

    beq $t4, 0x80000000, swap
    j extract
    #doi thu tu hai so
swap:
    addi $a1, $0, 1 #luu dau hieu nhan biet da doi thu tu 2 so
    move $t1, $t0 
    move $t0, $t2
    move $t2, $t1
    #luu lai bit dau
    andi    $t4, $t0, 0x80000000
    andi    $t5, $t2, 0x80000000
            

 extract:
    #lay phan dinh vi va phan mu
    move    $t6, $t0    
    andi    $t6, $t6, 0x7F800000    #luu phan mu vao $t6 

    move    $t7, $t0
    andi    $t7, $t7, 0x007FFFFF    #luu phan dinh vi vao $t7
    ori     $t7, $t7, 0x00800000    #dua ve dang chuan bang cach them bit 1 vao bit thu 24 cua phan dinh vi
    #remaining mantissa stays in register $t1

    move    $t8, $t2    
    andi    $t8, $t8, 0x7F800000    #luu phan mu vao $t8
    move    $t9, $t2
    andi    $t9, $t9, 0x007FFFFF    #luu phan dinh vi vao $t9
    ori     $t9, $t9, 0x00800000    #dua ve dang chuan bang cach them bit 1 vao bit thu 24 cua phan dinh vi
    #kiem tra 2 so doi nhau
    beq $t4, $t5, exp_check         #neu phan dau bang nhau, re nhanh
    bne $t6, $t8, exp_check 	     #neu phan mu khac nhau, re nhanh
    bne $t7, $t9, exp_check         #neu phan dinh vi khac nhau, re nhanh
    j zero                          #ket qua bang 0 neu cong hai so doi nhau hoac tru 2 so bang nhau
    
exp_check:
    slt    $a2, $t8, $t6
    beq    $a2, 1 ,exp1   #chuyen qua exp1 neu so mu so thu nhat lon hon
    slt    $a2, $t6, $t8 
    beq    $a2, 1 ,exp2   #chuyen qua exp2 neu so mu so thu hai lon hon
    
    slt    $a2, $t5, $t4
    beq    $a2, 1 ,sub_first #chuyen qua phep cong 2 so trai dau
   
add:
    #thuc hien phep cong 2 so cung dau
    add   $t7, $t7, $t9  #cong hai phan dinh vi

    move   $s1, $t4      #luu dau cua 2 so vao $s1

    j      shift         #chuyen den phan dua ket qua ve dang chuan

sub_first:
    #re nhanh qua sub_second neu phan dinh vi so thu hai lon hon phan dinh vi so thu nhat
    slt    $a2, $t7, $t9
    beq    $a2, 1 ,sub_second 

    subu   $t7, $t7, $t9 #tru 2 phan dinh vi

    move   $s1, $t4      #dau cua ket qua la dau cua so thu nhat, luu vao $s1

    j      shift2        #dua ket qua ve dang chuan

sub_second:
    
    subu   $t7, $t9, $t7 #tru 2 phan dinh vi

    move   $s1, $t5      #dau cua ket qua la dau cua so thu hai, luu vao $s1

    j      shift2        #dua ket qua ve dang chuan
    
exp1:
	
    srl    $t9, $t9, 1          #dich phan dinh vi qua phai 1 bit

    addiu  $t8, $t8, 0x00800000 #tang phan mu len 1 bit

    j      exp_check            #lap lai cho den khi phan mu hai so bang nhau
exp2:

    srl    $t7, $t7, 1          #dich phan dinh vi qua phai 1 bit

    addiu  $t6, $t6, 0x00800000 #tang phan mu len 1 bit

    j      exp_check            #lap lai cho den khi phan mu hai so bang nhau
    
shift:
	
    andi     $t4, $t7, 0x01000000 #kiem tra xem ket qua phep cong phan dinh vi co bi tran khong ?
    beqz     $t4, result          #tinh ket qua cuoi cung neu khong bi tran
	
    srl    $t7, $t7, 1            #dich phai 1 bit neu bi tran

    addi    $t6, $t6, 0x00800000  #tang phan mu len 1 don vi
    j result                      #den phan tinh ket qua cuoi cung
    
shift2:
    #dich trai ket qua tru 2 phan dinh vi 1 bit, tang phan mu len 1 bit cho den khi dua ve dang chuan
standard_check:
    andi     $t4, $t7, 0x00800000
    beq      $t4, 0x00800000, result #tinh toan ket qua neu da dua ve dang chuan voi bit trong so cao nhat la 1
    sll      $t7, $t7, 1             #dich trai 1 bit
    subi     $t6, $t6, 0x00800000    #tang phan mu len 1 bit
    j standard_check                 #tiep tuc vong lap

zero:# ket qua bang 0 neu cong 2 so doi nhau
    li $t3, 0
    j output
result:   
    andi    $t7, $t7, 0x007FFFFF #lay 23 bit thap cua phan dinh tri
    move   $t3, $s1              #chuyen phan dau vao ket qua
    or     $t3, $t3, $t6         #them phan mu
    or     $t3, $t3, $t7         #them phan dinh vi
output: #xuat ra ket qua phep cong
    sw  $t3, num1                #luu du lieu vao num1
    #print "Ket qua phep cong: "
    bnez $a0, ouput2             #chuyen qua ouput_2 neu la phep tru
    la  $a0, text3
    li  $v0, 4
    syscall
    lwc1    $f12, num1
    #xuat ra ket qua phep cong
    li  $v0, 2
    syscall
    
    j substract
ouput2: #xuat ra ket qua phep tru
    la  $a0, text4
    li  $v0, 4
    syscall
    lwc1    $f12, num1
    #xuat ra ket qua phep tru
    li  $v0, 2
    syscall
finish: #ket thuc chuong trinh
    li  $v0, 10             
    syscall
zero_2: #xuat ra 2 ket qua deu = 0 neu 2 so cung bang 0
    la  $a0, text3
    li  $v0, 4
    syscall
    li $a0, 0 
    li $v0, 1
    syscall
    la  $a0, text4
    li  $v0, 4
    syscall
    li $a0, 0 
    li $v0, 1
    syscall
    j finish

	
