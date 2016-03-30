.data # start data segment with bitmapDisplay so that it is at 0x10010000
.globl bitmapDisplay # force it to show at the top of the symbol table
bitmapDisplay: .space 0x80000 # Reserve space for memory mapped bitmap display
bitmapBuffer: .space 0x80000 # Reserve space for an "offscreen" buffer
width: .word 512 # Screen Width in Pixels
height: .word 256 # Screen Height in Pixels

testMatrix: .float 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
testVec1: .float 0 1 2 1
testVec2: .float 0 1 0 0
testVec3: .float 0 0 1 0
testVec4: .float 0 0 0 1

testResult: .float 0 0 0 0
testResult2: .float 0 0 0 0
M: .float
331.3682, 156.83034, -163.18181, 1700.7253
-39.86386, -48.649902, -328.51334, 1119.5535
0.13962941, 1.028447, -0.64546686, 0.48553467
0.11424224, 0.84145665, -0.52810925, 6.3950152

line1: .float 0 0 0 0
line2: .float 0 0 0 0		

R: .float
0.9994 0.0349 0 0
-0.0349 0.9994 0 0
0 0 1 0
0 0 0 1				
.text
main:
	
#TEST CLEAR BUFFER
	jal clearBuffer
#TEST POINT DRAWING
	li $a0, 100			#X 
	li $a1, 200			#Y
	jal drawPoint
	

#TEST LINE DRAWING ABILITY
#	li	$a0, 335			#x0
#	li	$a1, 300			#x1
#	li	$a2, 10		#y0
#	li	$a3, 50			#y1
#	li 	$s0, 0xFFFFFF
#	jal 	DrawLine
#	

#TEST MATRIX MULTIPLICATION
	#jal mulMatrixVec
	
	jal drawTeapot
	jal clearBuffer
	jal rotateTeapot
	jal clearBuffer
	
	
	j done
	
	
clearBuffer:
	li	$s0, 0x000000		# Colour - Green	
	li	$s1, 0x10010000
	
loop:
	sw $s0, ($s1)
	la $s1, 4($s1)
	
	
	li $t2, 0x10090000
	bne $t2, $s1, loop
	jr $ra

drawPoint:
	
	li $s1, 0x10010000		#BASE
	li $s0, 0xFFFFFF
	add $t0, $a0, $0			#X 
	add $t1, $a1, $0			#Y
	li $t2, 512			#W

	mult $t2,$t1			#w*y
	mflo $t1
	add $t3, $t1, $t0 		#t3 = x+wy
	sll $t3, $t3, 2				#t3= 4(x+wy)
	add $s1, $s1, $t3		# base + t3
	sw $s0, ($s1)
	jr $ra
	
drawLine:
	addiu 	$sp, $sp, -24
	sw	$ra, 20($sp)			#return address
	sw	$a0, 16($sp)			#x0
	sw	$a1, 12($sp)			#x1
	sw	$a2, 8($sp)			#y0
	sw	$a3, 4($sp)			#y1
	sw	$s0, ($sp)			#colour
	add $a0, $0, $a0
	add $s2, $0, $a1
	add $a1, $0, $a2
	jal drawPoint 				#drawpoint (x0,y0)
	add $a0, $0, $s2
	add $a1, $0, $a3
	jal drawPoint				#drawpoint (x1,y1)
	lw	$s0, ($sp)
	lw	$a3, 4($sp)
	lw	$a2, 8($sp)
	lw	$a1, 12($sp)
	lw	$a0, 16($sp)
	lw	$ra, 20($sp)
	
	addiu	$sp, $sp, 24
	
	jr	$ra


DrawLine:	#a0 = x0, a1 = x1, a2 = y0, a3 = y1, s0 = colour
	
	li 	$s0, 0xFFFFFF
	addiu 	$sp, $sp, -24
	sw	$ra, 20($sp)			#return address
	sw	$a0, 16($sp)			#x0
	sw	$a1, 12($sp)			#x1
	sw	$a2, 8($sp)			#y0
	sw	$a3, 4($sp)			#y1
	sw	$s0, ($sp)			#colour
	
	li $s7,-8
	sub $s6, $a1, $a0
	abs $s6, $s6
	
	li	$s2, 1			#s2 = offsetX
	li	$s3, 1			#s3 = offsetY	
	add	$s4,$0, $a0		#s4= x = x0
	add	$s5, $0, $a2 		#s5= y = y0
	
	sub	$t8, $a1, $a0			# dx = x1 - x0 ($t0 == dx)
	sub	$t9, $a3, $a2			# dy = y1 - y0 ($t1 == dy)
	
	
	add $t6, $0, $a0
	add $t7, $0, $a1

	bgez $t8, dx
	abs $t8,$t8	
	li $s2, -1
	
	add $t6, $0, $a2
	add $t7, $0, $a3
dx:	
	
	bgez $t9, dy
	abs $t9, $t9
	li $s3, -1
	
dy:

	add $t6, $0, $a0
	add $t7, $0, $a1
	
	add $a0 $0, $s4				#a0 = x
	add $a1, $0, $s5			#a1 = y
	jal drawPoint
	
	
############################################################
	slt $t4, $t8, $t9 	# if dx<dy go to else
	bne $t4, $0, else 
	
	add $t4, $0, $t8 	#t2 = error = dx
loop1:	
	add $a0, $0, $t6
	add $a1, $0 , $t7
	
	beq $s4, $a1, continue # if x = x1 goto continue
	
	sll $t5, $t9, 1 #2*dy
	sub $t4 $t4, $t5 #  t2 = error = error - 2*dY;
	
	bgez $t4, continue1
	add $s5, $s5, $s3	#y = y + offsetY;
	sll $t5, $t8, 1 
	add $t4, $t4,$t5	#t2 = error = error +2dx
continue1:
	add $s4, $s4 $s2	#x = x + offsetX;
	
	add $a0, $0, $s4
	add $a1, $0, $s5
	jal drawPoint
	j loop1


continue:
	j avoidElse

else:

	add $t4, $0, $t9
loop2:
	add $a2, $0, $t6
	add $a3, $0 , $t7
	
	beq $s5, $a3 continue2
	beq $s7, $s6, continue2
	sll $t5, $t8, 1		#2*dX;
	sub $t4, $t4, $t5	#error = error - 2*dX;
	bgez $t4 continue3
	add $s4, $s4, $s2
	sll $t5, $t9, 1
	add $t4, $t4, $t5
continue3:
	add $s5, $s5, $s3
	add $a0, $0, $s4
	add $a1,$0, $s5
	add $s7, $s7, 1
	jal drawPoint
	j loop2
continue2:	
avoidElse:
	lw	$s0, ($sp)
	lw	$a3, 4($sp)
	lw	$a2, 8($sp)
	lw	$a1, 12($sp)
	lw	$a0, 16($sp)
	lw	$ra, 20($sp)
	
	addiu	$sp, $sp, 24
	
	jr	$ra
mulMatrixVecBackUp:
	
	
	la $t4, testVec1
	
	la $a0, ($t4)
	la $a1, 4($t4)
	la $a2, 8($t4)
	la $a3, 12($t4)
	
	lwc1	$f0, ($a0)	  #loading testVec1 into floats
	lwc1	$f1, ($a1)	
	lwc1	$f2, ($a2)	
	lwc1	$f3, ($a3)	
	
	la $t0, testMatrix 
	la $t1, 0($t0)
	la $t2, 16($t0)
	la $t3, 32($t0)
	la $t4, 48($t0)
	
	lwc1	$f4, ($t1) 	#1
	lwc1	$f5, ($t2)	#5
	lwc1	$f6, ($t3)	#9
	lwc1	$f7, ($t4)	#13
	
	mul.s $f8, $f0, $f4
	mul.s $f9, $f0, $f5
	mul.s $f10, $f0, $f6
	mul.s $f11, $f0, $f7
	
	la $t1, 4($t1)
	la $t2, 4($t2)
	la $t3, 4($t3)
	la $t4, 4($t4)
	lwc1	$f4, ($t1) 	#2
	lwc1	$f5, ($t2)	#6
	lwc1	$f6, ($t3)	#10
	lwc1	$f7, ($t4)	#14
	
	mul.s $f4, $f1, $f4
	mul.s $f5, $f1, $f5
	mul.s $f6, $f1, $f6
	mul.s $f7, $f1, $f7
	
	add.s $f8, $f8, $f4
	add.s $f9, $f9, $f5
	add.s $f10, $f10, $f6
	add.s $f11, $f11, $f7
	
	la $t1, 4($t1)
	la $t2, 4($t2)
	la $t3, 4($t3)
	la $t4, 4($t4)
	lwc1	$f4, ($t1) 	#3
	lwc1	$f5, ($t2)	#7
	lwc1	$f6, ($t3)	#11
	lwc1	$f7, ($t4)	#15
	
	mul.s $f4, $f2, $f4
	mul.s $f5, $f2, $f5
	mul.s $f6, $f2, $f6
	mul.s $f7, $f2, $f7
	
	add.s $f8, $f8, $f4
	add.s $f9, $f9, $f5
	add.s $f10, $f10, $f6
	add.s $f11, $f11, $f7
	
	la $t1, 4($t1)
	la $t2, 4($t2)
	la $t3, 4($t3)
	la $t4, 4($t4)
	lwc1	$f4, ($t1) 	#4
	lwc1	$f5, ($t2)	#8
	lwc1	$f6, ($t3)	#12
	lwc1	$f7, ($t4)	#16
	
	mul.s $f4, $f3, $f4
	mul.s $f5, $f3, $f5
	mul.s $f6, $f3, $f6
	mul.s $f7, $f3, $f7
	
	add.s $f8, $f8, $f4		#final vmatric results
	add.s $f9, $f9, $f5
	add.s $f10, $f10, $f6
	add.s $f11, $f11, $f7
	
	la $t0, testResult		#putting result into testResult
	swc1 $f8, ($t0)
	swc1 $f9, 4($t0)
	swc1 $f10, 8($t0)
	swc1 $f11, 12($t0)
	
	lwc1 $f8, ($t0)
	lwc1 $f9, 4($t0)
	lwc1 $f10, 8($t0)
	lwc1 $f11, 12($t0)
	
	mov.s $f12 $f8 			#TEST OUTPUT
	li $v0 2
	syscall
	mov.s $f12 $f9
	li $v0 2
	syscall
	mov.s $f12 $f10
	li $v0 2
	syscall
	mov.s $f12 $f11
	li $v0 2
	syscall
	

mulMatrixVec2:
	la $t4, line2
	j matrixContinue
mulMatrixVec:
	
	la $t4, line1
matrixContinue:	
	la $a0, ($t4)
	la $a1, 4($t4)
	la $a2, 8($t4)
	la $a3, 12($t4)
	
	lwc1	$f0, ($a0)	  #loading testVec1 into floats
	lwc1	$f1, ($a1)	
	lwc1	$f2, ($a2)	
	lwc1	$f3, ($a3)	
	
	la $t0, M
	la $t1, 0($t0)
	la $t2, 16($t0)
	la $t3, 32($t0)
	la $t4, 48($t0)
	
	lwc1	$f4, ($t1) 	#1
	lwc1	$f5, ($t2)	#5
	lwc1	$f6, ($t3)	#9
	lwc1	$f7, ($t4)	#13
	
	mul.s $f8, $f0, $f4
	mul.s $f9, $f0, $f5
	mul.s $f10, $f0, $f6
	mul.s $f11, $f0, $f7
	
	la $t1, 4($t1)
	la $t2, 4($t2)
	la $t3, 4($t3)
	la $t4, 4($t4)
	lwc1	$f4, ($t1) 	#2
	lwc1	$f5, ($t2)	#6
	lwc1	$f6, ($t3)	#10
	lwc1	$f7, ($t4)	#14
	
	mul.s $f4, $f1, $f4
	mul.s $f5, $f1, $f5
	mul.s $f6, $f1, $f6
	mul.s $f7, $f1, $f7
	
	add.s $f8, $f8, $f4
	add.s $f9, $f9, $f5
	add.s $f10, $f10, $f6
	add.s $f11, $f11, $f7
	
	la $t1, 4($t1)
	la $t2, 4($t2)
	la $t3, 4($t3)
	la $t4, 4($t4)
	lwc1	$f4, ($t1) 	#3
	lwc1	$f5, ($t2)	#7
	lwc1	$f6, ($t3)	#11
	lwc1	$f7, ($t4)	#15
	
	mul.s $f4, $f2, $f4
	mul.s $f5, $f2, $f5
	mul.s $f6, $f2, $f6
	mul.s $f7, $f2, $f7
	
	add.s $f8, $f8, $f4
	add.s $f9, $f9, $f5
	add.s $f10, $f10, $f6
	add.s $f11, $f11, $f7
	
	la $t1, 4($t1)
	la $t2, 4($t2)
	la $t3, 4($t3)
	la $t4, 4($t4)
	lwc1	$f4, ($t1) 	#4
	lwc1	$f5, ($t2)	#8
	lwc1	$f6, ($t3)	#12
	lwc1	$f7, ($t4)	#16
	
	mul.s $f4, $f3, $f4
	mul.s $f5, $f3, $f5
	mul.s $f6, $f3, $f6
	mul.s $f7, $f3, $f7
	
	add.s $f8, $f8, $f4		#final vmatric results
	add.s $f9, $f9, $f5
	add.s $f10, $f10, $f6
	add.s $f11, $f11, $f7
	
	la $t0, testResult		#putting result into testResult
	swc1 $f8, ($t0)
	swc1 $f9, 4($t0)
	swc1 $f10, 8($t0)
	swc1 $f11, 12($t0)
	
	la $t0, testResult2		#putting result into testResult
	swc1 $f8, ($t0)
	swc1 $f9, 4($t0)
	swc1 $f10, 8($t0)
	swc1 $f11, 12($t0)
	
#	lwc1 $f8, ($t0)
#	lwc1 $f9, 4($t0)
#	lwc1 $f10, 8($t0)
#	lwc1 $f11, 12($t0)
#	
#	mov.s $f12 $f8 			#TEST OUTPUT
#	li $v0 2
#	syscall
#	mov.s $f12 $f9
#	li $v0 2
#	syscall
#	mov.s $f12 $f10
#	li $v0 2
#	syscall
#	mov.s $f12 $f11
#	li $v0 2
#	syscall
	
	jr $ra
	
	
drawTeapot:


	li $t7, 0  #line count
	la $t0, LineData
teabag:	

	
	
	lwc1 $f12, ($t0)	#Put in line1
	lwc1 $f13, 4($t0)
	lwc1 $f14, 8($t0)
	lwc1 $f15, 12($t0)	
	#mov.s $f12, $f12
	#li $v0 2
	#syscall
	la $t1, line1	#putting in line1
	swc1 $f12, ($t1)
	swc1 $f13, 4($t1)
	swc1 $f14, 8($t1)
	swc1 $f15, 12($t1)
	
	addiu 	$sp, $sp, -16
	sw	$ra, 12($sp)			#return address
	sw	$t7, 8($sp)			#line count
	sw	$t1, 4($sp)			#line1 address
	sw	$t0, ($sp)			#line data 

	
	jal mulMatrixVec
	
	lw	$t0, ($sp)
	lw	$t1, 4($sp)
	lw	$t7, 8($sp)
	lw	$ra, 12($sp)
	
	addiu	$sp, $sp, 16
	
	la $t6, testResult		#putting result into testResult
	lwc1 $f12, ($t6)
	lwc1 $f13, 4($t6)
	lwc1 $f14, 8($t6)
	lwc1 $f15, 12($t6)
	
	div.s $f12, $f12, $f15
	div.s $f13, $f13, $f15
	
	cvt.w.s $f12, $f12
	cvt.w.s $f13, $f13
	
	lwc1 $f16, 16($t0)			#Put in line2
	lwc1 $f17, 20($t0)
	lwc1 $f18, 24($t0)
	lwc1 $f19, 28($t0)
	la $t2, line2	#putting in line2
	swc1 $f16, ($t2)
	swc1 $f17, 4($t2)
	swc1 $f18, 8($t2)
	swc1 $f19, 12($t2)
	
	addiu 	$sp, $sp, -20
	sw	$ra, 16($sp)			#return address
	sw	$t7, 12($sp)			#line count
	sw 	$t2 8($sp)			#line2 address
	sw	$t1, 4($sp)			#line1 address
	sw	$t0, ($sp)			#line data 
	
	jal mulMatrixVec2
	
	lw	$t0, ($sp)
	lw	$t1, 4($sp)
	lw 	$t2, 8($sp)
	lw	$t7, 12($sp)
	lw	$ra, 16($sp)
	
	addiu	$sp, $sp, 20
	
	la $t6, testResult
	
	lwc1 $f16, ($t6)
	lwc1 $f17, 4($t6)
	lwc1 $f18, 8($t6)
	lwc1 $f19, 12($t6)
	
	div.s $f16, $f16, $f19
	div.s $f17, $f17, $f19
	
	cvt.w.s $f16, $f16
	cvt.w.s $f17, $f17
	
	mfc1 $a0, $f12 	#x0
	mfc1 $a1, $f16	#x1
	mfc1 $a2, $f13	#y0
	mfc1 $a3, $f17	#y1
	
	addiu 	$sp, $sp, -20
	sw	$ra, 16($sp)			#return address
	sw	$t7, 12($sp)			#line count
	sw 	$t2 8($sp)			#line2 address
	sw	$t1, 4($sp)			#line1 address
	sw	$t0, ($sp)			#line data 
	
	jal DrawLine		# DRAWLINE NOT WORKING
	
	lw	$t0, ($sp)
	lw	$t1, 4($sp)
	lw 	$t2, 8($sp)
	lw	$t7, 12($sp)
	lw	$ra, 16($sp)
	
	addiu	$sp, $sp, 20
	
	la $t0, 32($t0)
	add $t7, $t7, 1
	beq $t7, 575, sugar 
	
	j teabag
sugar:	
	lwc1 $f12, ($t1)
	
	mov.s $f12, $f12
	li $v0 2
	syscall
	jr $ra
	
	
	
	
rotateTeapot:
li $t4, 0
la $t7, R
la $t0, LineData
li $t6, 0 
li $t5, 0  #line count
Rreset:
rotate:
	lwc1 $f20, ($t0)  # one line of line data
	lwc1 $f21, 4($t0)
	lwc1 $f22, 8($t0)
	lwc1 $f23, 12($t0)

	lwc1 $f24, ($t7) 	# one line of R
	lwc1 $f25, 4($t7)
	lwc1 $f26, 8($t7)
	lwc1 $f27, 12($t7)
	
	
	
	
	add.s $f20, $f20, $f24
	add.s $f21, $f21, $f25
	add.s $f22, $f22, $f26
	add.s $f23, $f23, $f27
	
	swc1 $f20, ($t0)  # one line of line data
	swc1 $f21, 4($t0)
	swc1 $f22, 8($t0)
	swc1 $f23, 12($t0)
	
	la $t7, 16($t7)
	
	
	la $t0, 16 ($t0)
	
	add $t6, $t6, 1
	add $t5, $t5, 1
	
	beq $t5, 1152, continuerotate
	
	slti $t4,$t6,4 # $t0 = 1 if g<h
 			# $t0 = 0 if g>=h
	bne $t4,$0,Less 
	
	j rotate
Less:
 la $t7,R
 
 j Rreset




continuerotate:
	li $t7, 0  #line count
	la $t0, LineData
teabag2:	

	
	
	lwc1 $f12, ($t0)	#Put in line1
	lwc1 $f13, 4($t0)
	lwc1 $f14, 8($t0)
	lwc1 $f15, 12($t0)	
	#mov.s $f12, $f12
	#li $v0 2
	#syscall
	

	la $t1, line1	#putting in line1
	swc1 $f12, ($t1)
	swc1 $f13, 4($t1)
	swc1 $f14, 8($t1)
	swc1 $f15, 12($t1)
	
	addiu 	$sp, $sp, -16
	sw	$ra, 12($sp)			#return address
	sw	$t7, 8($sp)			#line count
	sw	$t1, 4($sp)			#line1 address
	sw	$t0, ($sp)			#line data 

	
	jal mulMatrixVec
	
	lw	$t0, ($sp)
	lw	$t1, 4($sp)
	lw	$t7, 8($sp)
	lw	$ra, 12($sp)
	
	addiu	$sp, $sp, 16
	
	la $t6, testResult		#putting result into testResult
	lwc1 $f12, ($t6)
	lwc1 $f13, 4($t6)
	lwc1 $f14, 8($t6)
	lwc1 $f15, 12($t6)
	
	div.s $f12, $f12, $f15
	div.s $f13, $f13, $f15
	
	cvt.w.s $f12, $f12
	cvt.w.s $f13, $f13
	
	lwc1 $f16, 16($t0)			#Put in line2
	lwc1 $f17, 20($t0)
	lwc1 $f18, 24($t0)
	lwc1 $f19, 28($t0)
	la $t2, line2	#putting in line2
	swc1 $f16, ($t2)
	swc1 $f17, 4($t2)
	swc1 $f18, 8($t2)
	swc1 $f19, 12($t2)
	
	addiu 	$sp, $sp, -20
	sw	$ra, 16($sp)			#return address
	sw	$t7, 12($sp)			#line count
	sw 	$t2 8($sp)			#line2 address
	sw	$t1, 4($sp)			#line1 address
	sw	$t0, ($sp)			#line data 
	
	jal mulMatrixVec2
	
	lw	$t0, ($sp)
	lw	$t1, 4($sp)
	lw 	$t2, 8($sp)
	lw	$t7, 12($sp)
	lw	$ra, 16($sp)
	
	addiu	$sp, $sp, 20
	
	la $t6, testResult
	
	lwc1 $f16, ($t6)
	lwc1 $f17, 4($t6)
	lwc1 $f18, 8($t6)
	lwc1 $f19, 12($t6)
	
	div.s $f16, $f16, $f19
	div.s $f17, $f17, $f19
	
	cvt.w.s $f16, $f16
	cvt.w.s $f17, $f17
	
	mfc1 $a0, $f12 	#x0
	mfc1 $a1, $f16	#x1
	mfc1 $a2, $f13	#y0
	mfc1 $a3, $f17	#y1
	
	addiu 	$sp, $sp, -20
	sw	$ra, 16($sp)			#return address
	sw	$t7, 12($sp)			#line count
	sw 	$t2 8($sp)			#line2 address
	sw	$t1, 4($sp)			#line1 address
	sw	$t0, ($sp)			#line data 
	
	jal DrawLine		# DRAWLINE NOT WORKING
	
	lw	$t0, ($sp)
	lw	$t1, 4($sp)
	lw 	$t2, 8($sp)
	lw	$t7, 12($sp)
	lw	$ra, 16($sp)
	
	addiu	$sp, $sp, 20
	
	la $t0, 32($t0)
	add $t7, $t7, 1
	beq $t7, 575, sugar2 
	
	j teabag2
sugar2:	
	lwc1 $f12, ($t1)
	
	mov.s $f12, $f12
	li $v0 2
	syscall
	jr $ra

done:
## DONE ##
