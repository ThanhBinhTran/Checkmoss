.data
str_in: .asciiz "Nhap so thu nhat: "
str_in1: .asciiz "Nhap so thu hai: "
str_out: .asciiz "Ket qua = "
.text
Enter:
        # Nhap so A
        la $a0, str_in
        li $v0, 4
        syscall
        li $v0, 6
        syscall
        mfc1 $t0, $f0 # $t0 = A
        # Nhap so B
        la $a0,str_in1
        li $v0, 4
        syscall
        li $v0, 6
        syscall
        mfc1 $t1, $f0 #$t1 = 
        
        
Get_sign:# xet bit dau cua tich
        srl $s0, $t0, 31 #lay bit dau cua thua so
        srl $s1, $t1, 31 #lay bit dau cua thua so
        xor $s2, $s0, $s1 #dau cua tich
        sll $s2, $s2, 31 
        
        
Get_exponent:# ham lay bit so mu
        sll $t2, $t0, 1 #dich trai $t0 sang 1bit
        srl $t2, $t2, 24 #sau do dich phai 23bit
        sll $t3, $t1, 1 #dich trai $t1 sang 1bit
        srl $t3, $t3, 24 #sau do dich sang phai 24bit
        
        
Add_exponent:#cong so mu
        add $t6, $t2, $t3
        addi $t6, $t6, -127 # so mu cua tich
        
        
Get_mantissa:#lay lay phan dinh tri, sau do them bit 1 vao dau ==> dang 1.m
        sll $t4, $t0, 9 #dich trai 9bit
        srl $t4, $t4, 9 #sau do dich phai 9 bit
        addi $t4, $t4, 8388608 #them bit 1 vao dau
        sll $t5, $t1, 9 #dich trai 9bit
        srl $t5, $t5, 9 #sau do dich phai 9 bit
        addi $t5, $t5, 8388608 #athem bit 1 vao dau
        
        
Mult_mantissa: #nhan phan dinh tri
        mult $t4, $t5 # nh�n 2 phan dinh tri
        mfhi $s3 #luu 32bit high v�o $s3
        mflo $s4 #luu 32bit low v�o $s4
        srl $s5, $s3, 15 #dich phai thanh ghi $s3 15bit
        beq $s5, 0, bit_Mantissa #neu $s3 c� 15 bit th� nhay toi man_pro
        sll $s6, $s3, 31 #nguoc lai neu c� 16 bit th� dich $s3 sang trai 31bit
        srl $s4, $s4, 1 
        add $s4, $s4, $s6 
        srl $s3, $s3, 1 
        addi $t6, $t6, 1 #cong so mu them 1
        
        
bit_Mantissa: 
        sll $s3, $s3, 18  #dich trai thanh ghi s3 18bit
        srl $s3, $s3, 9 
        srl $s4, $s4, 23 
        add $s4, $s3, $s4 
        

Convention: #Do khong the bieu dien so 0 duoi dang so thuc, nen ta quy uoc neu exponent = 0 va mantissa = 0 thi so thuc do bang 0
        bne $t6, -127, Return_product 
        bne $s4, 0, Return_product
        addi $t8, $zero, 0
        mtc1 $t8, $f12
        j Print_out
        
        
Return_product: #sign-exponent-mantissa
        sll $t6, $t6, 23
        add $t7, $s2, $t6
        add $t7, $t7, $s4
        mtc1 $t7, $f12
        
        
Print_out:
        la $a0, str_out
        li $v0, 4
        syscall
        li $v0, 2
        syscall
        li $v0, 10
        syscall
