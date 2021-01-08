# Chuong trinh cong, tru hai so thuc 32bit
# Filename: BTL.asm
# Date: 12/08/2020
# Nguoi lam: Nguyen Trung Phong, Nguyen Kim Loc, Nguyen Anh Kiet
# Mo ta: Day la chuong trinh cho phep nguoi dung nhap vao hai so thuc va cho ra man hinh ket qua la tong (hoac hieu) cua hai so da cho
# Input: hai so thuc
# Output: tong (hoac hieu) cua hai so 

################# Data segment #####################

.data
sothunhat: .asciiz "So hang thu nhat la: "
sothuhai: .asciiz "So hang thu hai la: "
pheptinh: .asciiz "\nPhep tinh can thuc hien la (0: Cong, 1: Tru): "
ketqua: .asciiz "Ket qua la: "
cauhoi: .asciiz "\nNhap 1 de tiep tuc tinh toan, nhap 0 de ket thuc: " 

################# Code segment #####################

.text
.globl input
input: 
 # Yeu cau nguoi dung nhap so thu nhat
 la $a0, sothunhat
 li $v0, 4
 syscall
 
 # Luu so dau tien vao $t1
 li $v0, 6
 syscall 
 mfc1 $t1, $f0 
 
 # Yeu cau nguoi dung nhap so thu hai
 la $a0, sothuhai
 li $v0, 4
 syscall
 
 # Luu so thu hai vao $t2
 li $v0, 6
 syscall 
 mfc1 $t2, $f0 
 
 # Yeu cau nguoi dung chon phap cong hay tru
 la $a0,pheptinh
 li $v0,4
 syscall 
 
 # Luu bieu thuc can tinh vao $t0
 li $v0,5
 syscall
 add $t0,$v0,$0 
 
#########################################################
 
# Lay 1 bit sign 
 # Lay bit sign cua so thu nhat, cac bit con lai bang 0
 #li $at, 0x80000000 # Tao thanh ghi tam co bit sign bang 1, cac bit con lai bang 0
 lui $at, 0x8000
 ori $at, $at, 0x0000
 and $s1, $t1, $at # Lay bit sign
 
 # Lay bit sign cua so thu hai, cac bit con lai bang 0
 #li $at, 0x80000000 # Tao thanh ghi tam co bit sign bang 1, cac bit con lai bang 0
 lui $at, 0x8000
 ori $at, $at, 0x0000
 and $s2, $t2, $at # Lay bit sign
 
# Kiem tra $t0 de biet la phep cong hay tru
 bne $t0, $0, subres # Neu $t0 = 1 (khac 0) thuc hien phep tru
 j addres # Neu $t0 = 0 thuc hien phep cong
 
# Thuc hien phep tru
subres: # Dao nguoc bit sign cua so thu hai
 #li $at, 0x80000000 # Tao thanh ghi tam co bit sign bang 1, cac bit con lai bang 0
 lui $at, 0x8000
 ori $at, $at, 0x0000
 addu $s2, $s2, $at # Dao nguoc bit sign cua so thu hai
 
# Thuc hien phep cong
addres: 
# Lay exponent va fraction cua so dau tien
 # Lay exponent cua so dau tien luu vao $s3   
 #li $at, 0x7F800000 # Tao thanh ghi tam co cac bit exponent bang 1, cac bit con lai bang 0
 lui $at, 0x7F80
 ori $at, $at, 0x0000
 and $s3, $t1, $at # Lay exponent
 
 # Lay fraction cua so thu nhat luu vao $s4
 #li $at, 0x007FFFFF # Tao thanh ghi tam co cac bit fraction bang 1, cac bit con lai bang 0
 lui $at, 0x007F
 ori $at, $at, 0xFFFF
 and $s4, $t1, $at # Lay fraction
 
 # Them bit prefix 1 vao truoc fraction (dai dien cho 1.)
 #li $at, 0x00800000
 lui $at, 0x0080
 ori $at, $at, 0x0000
 or $s4, $s4, $at 
 
# Lay exponent va fraction cua so thu hai
 # Lay exponent cua so thu hai luu vao $s5
 #li $at, 0x7F800000 # Tao thanh ghi tam co cac bit exponent bang 1, cac bit con lai bang 0
 lui $at, 0x7F80
 ori $at, $at, 0x0000
 and $s5, $t2, $at # Lay exponent 
 
 # Lay fraction cua so thu hai luu vao $s6
 #li $at, 0x007FFFFF # Tao thanh ghi tam co cac bit fraction bang 1, cac bit con lai bang 0
 lui $at, 0x007F
 ori $at, $at, 0xFFFF
 and $s6, $t2, $at # Lay fraction 
 
 # Them bit prefix 1 vao truoc fraction (dai dien cho 1.)
 #li $at, 0x00800000
 lui $at, 0x0080
 ori $at, $at, 0x0000
 or $s6, $s6, $at 

# Kiem tra exponent (so mu) cua hai so xem co bang nhau khong 
expcheck:
 # Neu so mu cua so thu hai nho hon so mu cua so thu nhat
 slt $at, $s5, $s3
 bne $at, $0, exp1 # Nhay toi exp1 de xu li 
 
 # Neu so mu cua so thu nhat nho hon so mu cua so thu hai
 slt $at, $s3, $s5
 bne $at, $0, exp2 # Nhay toi exp2 de xu li 
 j signcheck
  
exp1: # Tang exponent so thu hai len 1 don vi va dich phai fraction so thu hai 1 bit
 #li $at, 0x00800000 # Tao thanh ghi co phan exponent bang 1
 lui $at, 0x0080
 ori $at, $at, 0x0000
 addu $s5, $s5, $at # Cong exponent cho 1
 srl $s6, $s6, 1 # Dich phai fraction cua 1 bit 
 j expcheck # Nhay toi expcheck de kiem tra lai
 
exp2: # Tang exponent so thu nhat len 1 don vi va dich phai fraction so thu nhat 1 bit
 #li $at, 0x00800000 # Tao thanh ghi co phan exponent bang 1
 lui $at, 0x0080
 ori $at, $at, 0x0000
 addu $s3, $s3, $at # Cong exponent cho 1
 srl $s4, $s4, 1 # Dich phai fraction cua so 1 bit 
 j expcheck # Nhay toi expcheck de kiem tra lai
 
# Sau expcheck hai so co so mu bang nhau

# Kiem tra bit sign 
signcheck:
 beq $s1, $s2, adding # Neu hai so cung dau, nhay toi adding
 # Hai so trai dau
 beq $s4, $s6, triettieu # Neu fraction hai so bang nhau thi triet tieu nhau, nhay den triettieu ( luu ket qua bang 0 )
 slt $at, $s4, $s6
 beq $at, $0, subfirst # Tai day fraction so thu nhat lon hon so thu hai, nhay toi subfirst ( lay $s4 - $s6 )
 j subsecond # Neu fraction so thu hai lon hon so thu nhat, nhay toi subsecond ( lay $s6 - $s4 )

adding: # Cong hai so cung dau
 addu $s4, $s4, $s6 # Cong fraction cua hai so voi nhau luu vao $s4
 addu $s0, $s1, $0 # Lay bit sign cua 2 so vao $s0
 j fix1 # Nhay toi fix1 de dieu chinh lai ket qua $s4
 
triettieu: # Hai so trai dau co fraction bang nhau, cho ket qua bang 0
 and $t1, $t1, $0 # $t1 = 0 (ket qua bang 0)
 j output # Nhay toi output (in ket qua)
 
subfirst: # Lay fraction so thu nhat tru so thu hai, lay bit sign cua so thu nhat
 subu $s4, $s4, $s6 # fraction so thu nhat - fraction so thu hai ( $s4 - $s6 ) luu vao $s4
 addu $s0, $s1, $0 # Lay bit sign cua so thu nhat vao $s0
 j fix2 # Nhay toi fix2 de dieu chinh lai ket qua $s4
 
subsecond: # Lay fraction so thu hai tru so thu nhat, lay bit sign cua so thu hai
 subu $s4, $s6, $s4 # fraction so thu hai - fraction so dau ( $s6 - $s4 ) luu vao $s4
 addu $s0, $s2, $0 # Lay bit sign cua so thu hai vao $s0
 j fix2 # Nhay toi fix2 de dieu chinh lai ket qua $s4

fix1: # Dieu chinh ket qua $s4 neu hai so cung dau
# Kiem tra bit dung truoc bit prefix (1.) da cho luc dau co bang 1 hay khong ( thay doi tu 0 sang 1 ) 
# Neu co thi dich phai $s4 va tang so mu cho den khi bit tai vi tri do bang 0 thi nhay toi saveres ( luu ket qua )
 #li $at, 0x01000000 # Tao thanh ghi co bit dung truoc bit prefix bang 1, cac bit con lai bang 0
 lui $at, 0x0100
 ori $at, $at, 0x0000
 and $s1, $s4, $at # Lay bit dung truoc bit prefix cua $s4
 beq $s1, $0, saveres # Neu bang 0 thi nhay toi saveres
 # Dich phai 1 bit
 srl $s4, $s4, 1 # neu bang 1 thi dich phai 1 bit
 # Cong exponent cho 1
 #li $at, 0x00800000 # Tao thanh ghi co phan exponent bang 1
 lui $at, 0x0080
 ori $at, $at, 0x0000
 add $s3, $s3, $at # Cong exponent cua ket qua cho 1
 j fix1 # Nhay toi fix1 de kiem tra lai
 
fix2: # Dieu chinh ket qua $s4 neu hai so khac dau
# Kiem tra bit prefix (1.) da cho luc dau co bang 0 hay khong ( thay doi tu 1 sang 0 ) 
# Neu co thi dich trai $s4 va giam so mu cho den khi bit tai vi tri do bang 1 thi nhay toi saveres ( luu ket qua )
 #li $at, 0x00800000 # Tao thanh ghi co bit prefix bang 1, cac bit con lai bang 0
 lui $at, 0x0080
 ori $at, $at, 0x0000
 and $s1, $s4, $at # Lay bit prefix cua $s4
 bne $s1, $0, saveres # Neu khac 0 ( = 1 ) thi nhay toi saveres
 # Dich trai 1 bit
 sll $s4, $s4, 1 # Neu bang 0 thi dich trai 1 bit
 # Tru exponent cho 1
 #li $at, 0x00800000 # Tao thanh ghi co phan exponent bang 1
 lui $at, 0x0080
 ori $at, $at, 0x0000
 sub $s3, $s3, $at # Tru exponent cua ket qua cho 1
 j fix2 # Nhay toi fix2 de kiem tra lai
 
saveres: # Luu ket qua vao $t1
 #li $at, 0x007FFFFF
 lui $at, 0x007F
 ori $at, $at, 0xFFFF
 and $s4, $s4, $at # lay phan fraction cua ket qua, con lai cho bang 0 ( cho bit prefix bang 0 )
 addu $t1, $s0, $0 # Lay bit sign cua ket qua cho vao $t1
 or $t1, $t1, $s3 # Lay exponent cua ket qua cho vao $t1
 or $t1, $t1, $s4 # Lay fraction cua ket qua cho vao $t1
 j output # Nhay toi output ( in ket qua )
 
output: # In ket qua
 # Thong bao in ra ket qua
 la $a0, ketqua
 li $v0, 4
 syscall
 
 # Luu ket qua tu $t1 vao $f12 de in ra so thuc
 mtc1 $t1, $f12 
 
 # In ra ket qua
 li $v0, 2
 syscall
 
asking: # Lua chon tiep tuc tinh toan hoac ket thuc
 # Dat cau hoi cho nguoi dung
 la $a0, cauhoi
 li $v0, 4
 syscall
 # Doc ket qua duoc nhap vao
 li $v0, 5 
 syscall
 # Neu nguoi dung nhap 1 thi tiep tuc tinh toan
 beq $v0, 1, input 
 # Neu nguoi dung nhap 0 thi ket thuc chuong trinh
 beq $v0, $0, done
 # Neu nguoi dung nhap so khac, tiep tuc dat cau hoi
 j asking
 
done:
 li $v0, 10
 syscall
