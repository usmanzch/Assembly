
.data
displayBuffer:  .space 0x80000  # space for 512x256 bitmap display 
errorBuffer:    .space 0x80000  # space to store match function
templateBuffer: .space 0x400	# space for 8x8 template
imageFileName:    .asciiz "pxlcon512x256cropgs.raw"  # filename of image to load 
templateFileName: .asciiz "template8x8gs.raw"	     # filename of template to load
# struct bufferInfo { int *buffer, int width, int height, char* filename }
imageBufferInfo:    .word displayBuffer  512 256  imageFileName 
errorBufferInfo:    .word errorBuffer    512 256  0
templateBufferInfo: .word templateBuffer 8   8    templateFileName
#Measuring Cache Performance Questions
#1. No each main memory address is assigned to its own cache block.
#2. No it does not as you can have the address of multiple location in memory in the cache.
.text
main:	la $a0, imageBufferInfo
	jal loadImage
	la $a0, templateBufferInfo
	jal loadImage
	la $a0, imageBufferInfo
	la $a1, templateBufferInfo
	la $a2, errorBufferInfo
	jal matchTemplate        # MATCHING DONE HERE
	la $a0, errorBufferInfo
	jal findBest
	la $a0, imageBufferInfo
	move $a1, $v0
	jal highlight
	la $a0, errorBufferInfo	
	jal processError
	li $v0, 10		# exit
	syscall
	

##########################################################
# matchTemplate( bufferInfo imageBufferInfo, bufferInfo templateBufferInfo, bufferInfo errorBufferInfo )
# NOTE: struct bufferInfo { int *buffer, int width, int height, char* filename }
matchTemplate:	
    			
	li $a0, 0 #y
	li $a1, 0 #x
	li $a2, 0 #j
	li $a3, 0 #i

#culculate height and width of image
	la $t7, imageBufferInfo  
	lw $t5, 4($t7) 
	lw $t4, 8($t7) 
	subi $t8, $t5, 8 # width of image
	subi $t9, $t4, 8 # height of image

	j LoopStart	
	
LoopX:
		la $s0, displayBuffer
		la $s1, errorBuffer
		#i and x, adding j and y, multiplying by the width, summing, and multiplying by four, and adding to the base address. 

		addi $s2, $a1, 0 #x + int
		add $s3, $a0, $a2 # y + j
		mul $s3, $s3, 512 # mult width
		add $s2, $s2, $s3 #sum
		mul $s2, $s2, 4 #mul by 4
		add $s2, $s2, $s0 # add to base
		lbu $s2, ($s2) # load from base + offset 
		sub $s2, $s2, $t0 #subtract displaybuffer and templatebuffer
		abs $s2, $s2  #get absolute value

		mul $s4, $a0, 512 # Y * width
		add $s4, $s4, $a1 # X + Y*width
		mul $s4, $s4, 4 #mul by 4
		add $s4, $s4, $s1 # add to base
		lw $s5, ($s4) # load from errorbuffer
		add $s5, $s5 $s2 #add absolute value to value is errorBuffer
		sw $s5, ($s4)#store word back into errorBuffer
		#this is repeated 7 time below for each t value

		addi $s2, $a1, 1 
		add $s3, $a0, $a2 
		mul $s3, $s3, 512 
		add $s2, $s2, $s3 
		mul $s2, $s2, 4 
		add $s2, $s2, $s0 
		lbu $s2, ($s2)  
		sub $s2, $s2, $t1
		abs $s2, $s2 

		mul $s4, $a0, 512 
		add $s4, $s4, $a1 
		mul $s4, $s4, 4 
		add $s4, $s4, $s1
		lw $s5, ($s4)
		add $s5, $s5 $s2
		sw $s5, ($s4)

		addi $s2, $a1, 2 
		add $s3, $a0, $a2 
		mul $s3, $s3, 512 
		add $s2, $s2, $s3 
		mul $s2, $s2, 4 
		add $s2, $s2, $s0 
		lbu $s2, ($s2) 
		sub $s2, $s2, $t2 
		abs $s2, $s2 

		mul $s4, $a0, 512 
		add $s4, $s4, $a1 
		mul $s4, $s4, 4 
		add $s4, $s4, $s1 
		lw $s5, ($s4) 
		add $s5, $s5 $s2 
		sw $s5, ($s4) 

		addi $s2, $a1, 3 
		add $s3, $a0, $a2 
		mul $s3, $s3, 512 
		add $s2, $s2, $s3 
		mul $s2, $s2, 4 
		add $s2, $s2, $s0 
		lbu $s2, ($s2) 
		sub $s2, $s2, $t3
		abs $s2, $s2 

		mul $s4, $a0, 512 
		add $s4, $s4, $a1 
		mul $s4, $s4, 4 
		add $s4, $s4, $s1 
		lw $s5, ($s4)
		add $s5, $s5 $s2
		sw $s5, ($s4)

		addi $s2, $a1, 4 
		add $s3, $a0, $a2 
		mul $s3, $s3, 512 
		add $s2, $s2, $s3 
		mul $s2, $s2, 4 
		add $s2, $s2, $s0 
		lbu $s2, ($s2)  
		sub $s2, $s2, $t4
		abs $s2, $s2 

		mul $s4, $a0, 512 
		add $s4, $s4, $a1 
		mul $s4, $s4, 4 
		add $s4, $s4, $s1 
		lw $s5, ($s4)
		add $s5, $s5 $s2
		sw $s5, ($s4)

		addi $s2, $a1, 5 
		add $s3, $a0, $a2 
		mul $s3, $s3, 512 
		add $s2, $s2, $s3 
		mul $s2, $s2, 4 
		add $s2, $s2, $s0 
		lbu $s2, ($s2)  
		sub $s2, $s2, $t5
		abs $s2, $s2 

		mul $s4, $a0, 512 
		add $s4, $s4, $a1 
		mul $s4, $s4, 4 
		add $s4, $s4, $s1 
		lw $s5, ($s4)
		add $s5, $s5 $s2
		sw $s5, ($s4)

		addi $s2, $a1, 6 
		add $s3, $a0, $a2 
		mul $s3, $s3, 512 
		add $s2, $s2, $s3 
		mul $s2, $s2, 4 
		add $s2, $s2, $s0 
		lbu $s2, ($s2)  
		sub $s2, $s2, $t6
		abs $s2, $s2 

		mul $s4, $a0, 512 
		add $s4, $s4, $a1
		mul $s4, $s4, 4 
		add $s4, $s4, $s1 
		lw $s5, ($s4)
		add $s5, $s5 $s2
		sw $s5, ($s4)

		addi $s2, $a1, 7 
		add $s3, $a0, $a2 
		mul $s3, $s3, 512 
		add $s2, $s2, $s3 
		mul $s2, $s2, 4 
		add $s2, $s2, $s0 
		lbu $s2, ($s2) 
		sub $s2, $s2, $t7
		abs $s2, $s2 

		mul $s4, $a0, 512 
		add $s4, $s4, $a1 
		mul $s4, $s4, 4 
		add $s4, $s4, $s1 
		lw $s5, ($s4)
		add $s5, $s5 $s2
		sw $s5, ($s4)
		addi $a1, $a1, 1 #x++		
LoopY:
		ble $a1, $t8, LoopX
		addi $a0, $a0, 1 #y++	
cont:
		li $a1, 0
		ble $a0, $t9, LoopY
		j cont2
										
LoopJ:
		#i and x, adding j and y, multiplying by the width, summing, and multiplying by four, and adding to the base address. 
		la $s0, templateBuffer	

		mul $t0, $a2, 8 #j x width
		addi $t0, $t0, 0  #sum
		mul $t0, $t0, 4 # multiply by 4
		add $s1, $s0, $t0 #add to base
		lbu $t0, ($s1) #load from s1

		mul $t1, $a2, 8 #j x width
		addi $t1, $t1, 1  #sum
		mul $t1, $t1, 4 # multiply by 4
		add $s1, $s0, $t1 #add to base
		lbu $t1, ($s1) #load from s1

		mul $t2, $a2, 8 #j x width
		addi $t2, $t2, 2  #sum
		mul $t2, $t2, 4 # multiply by 4
		add $s1, $s0, $t2 #add to base
		lbu $t2, ($s1) #load from s1

		mul $t3, $a2, 8 #j x width
		addi $t3, $t3, 3  #sum
		mul $t3, $t3, 4 # multiply by 4
		add $s1, $s0, $t3 #add to base
		lbu $t3, ($s1) #load from s1

		mul $t4, $a2, 8 #j x width
		addi $t4, $t4, 4  #sum
		mul $t4, $t4, 4 # multiply by 4
		add $s1, $s0, $t4 #add to base
		lbu $t4, ($s1) #load from s1

		mul $t5, $a2, 8 #jx width
		addi $t5, $t5, 5  #sum
		mul $t5, $t5, 4 # multiply by 4
		add $s1, $s0, $t5 #add to base
		lbu $t5, ($s1) #load from s1

		mul $t6, $a2, 8 #j x width
		addi $t6, $t6, 6  #sum
		mul $t6, $t6, 4 # multiply by 4
		add $s1, $s0, $t6 #add to base
		lbu $t6, ($s1) #load from s1

		mul $t7, $a2, 8 #j x width
		addi $t7, $t7, 7  #sum
		mul $t7, $t7, 4 # multiply by 4
		add $s1, $s0, $t7 #add to base
		lbu $t7, ($s1) #load from s1
		j cont
cont2:
		addi $a2, $a2, 1	#j++
LoopStart:
		li $a0, 0
		ble $a2, 7, LoopJ 
		jr $ra	
	
	
	
	
###############################################################
# loadImage( bufferInfo* imageBufferInfo )
# NOTE: struct bufferInfo { int *buffer, int width, int height, char* filename }
loadImage:	lw $a3, 0($a0)  # int* buffer
		lw $a1, 4($a0)  # int width
		lw $a2, 8($a0)  # int height
		lw $a0, 12($a0) # char* filename
		mul $t0, $a1, $a2 # words to read (width x height) in a2
		sll $t0, $t0, 2	  # multiply by 4 to get bytes to read
		li $a1, 0     # flags (0: read, 1: write)
		li $a2, 0     # mode (unused)
		li $v0, 13    # open file, $a0 is null-terminated string of file name
		syscall
		move $a0, $v0     # file descriptor (negative if error) as argument for read
  		move $a1, $a3     # address of buffer to which to write
		move $a2, $t0	  # number of bytes to read
		li  $v0, 14       # system call for read from file
		syscall           # read from file
        	# $v0 contains number of characters read (0 if end-of-file, negative if error).
        	# We'll assume that we do not need to be checking for errors!
		# Note, the bitmap display doesn't update properly on load, 
		# so let's go touch each memory address to refresh it!
		move $t0, $a3	   # start address
		add $t1, $a3, $a2  # end address
loadloop:	lw $t2, ($t0)
		sw $t2, ($t0)
		addi $t0, $t0, 4
		bne $t0, $t1, loadloop
		jr $ra
		
		
#####################################################
# (offset, score) = findBest( bufferInfo errorBuffer )
# Returns the address offset and score of the best match in the error Buffer
findBest:	lw $t0, 0($a0)     # load error buffer start address	
		lw $t2, 4($a0)	   # load width
		lw $t3, 8($a0)	   # load height
		addi $t3, $t3, -7  # height less 8 template lines minus one
		mul $t1, $t2, $t3
		sll $t1, $t1, 2    # error buffer size in bytes	
		add $t1, $t0, $t1  # error buffer end address
		li $v0, 0		# address of best match	
		li $v1, 0xffffffff 	# score of best match	
		lw $a1, 4($a0)    # load width
        	addi $a1, $a1, -7 # initialize column count to 7 less than width to account for template
fbLoop:		lw $t9, 0($t0)        # score
		sltu $t8, $t9, $v1    # better than best so far?
		beq $t8, $zero, notBest
		move $v0, $t0
		move $v1, $t9
notBest:	addi $a1, $a1, -1
		bne $a1, $0, fbNotEOL # Need to skip 8 pixels at the end of each line
		lw $a1, 4($a0)        # load width
        	addi $a1, $a1, -7     # column count for next line is 7 less than width
        	addi $t0, $t0, 28     # skip pointer to end of line (7 pixels x 4 bytes)
fbNotEOL:	add $t0, $t0, 4
		bne $t0, $t1, fbLoop
		lw $t0, 0($a0)     # load error buffer start address	
		sub $v0, $v0, $t0  # return the offset rather than the address
		jr $ra
		

#####################################################
# highlight( bufferInfo imageBuffer, int offset )
# Applies green mask on all pixels in an 8x8 region
# starting at the provided addr.
highlight:	lw $t0, 0($a0)     # load image buffer start address
		add $a1, $a1, $t0  # add start address to offset
		lw $t0, 4($a0) 	# width
		sll $t0, $t0, 2	
		li $a2, 0xff00 	# highlight green
		li $t9, 8	# loop over rows
highlightLoop:	lw $t3, 0($a1)		# inner loop completely unrolled	
		and $t3, $t3, $a2
		sw $t3, 0($a1)
		lw $t3, 4($a1)
		and $t3, $t3, $a2
		sw $t3, 4($a1)
		lw $t3, 8($a1)
		and $t3, $t3, $a2
		sw $t3, 8($a1)
		lw $t3, 12($a1)
		and $t3, $t3, $a2
		sw $t3, 12($a1)
		lw $t3, 16($a1)
		and $t3, $t3, $a2
		sw $t3, 16($a1)
		lw $t3, 20($a1)
		and $t3, $t3, $a2
		sw $t3, 20($a1)
		lw $t3, 24($a1)
		and $t3, $t3, $a2
		sw $t3, 24($a1)
		lw $t3, 28($a1)
		and $t3, $t3, $a2
		sw $t3, 28($a1)
		add $a1, $a1, $t0	# increment address to next row	
		add $t9, $t9, -1	# decrement row count
		bne $t9, $zero, highlightLoop
		jr $ra

######################################################
# processError( bufferInfo error )
# Remaps scores in the entire error buffer. The best score, zero, 
# will be bright green (0xff), and errors bigger than 0x4000 will
# be black.  This is done by shifting the error by 5 bits, clamping
# anything bigger than 0xff and then subtracting this from 0xff.
processError:	lw $t0, 0($a0)     # load error buffer start address
		lw $t2, 4($a0)	   # load width
		lw $t3, 8($a0)	   # load height
		addi $t3, $t3, -7  # height less 8 template lines minus one
		mul $t1, $t2, $t3
		sll $t1, $t1, 2    # error buffer size in bytes	
		add $t1, $t0, $t1  # error buffer end address
		lw $a1, 4($a0)     # load width as column counter
        	addi $a1, $a1, -7  # initialize column count to 7 less than width to account for template
pebLoop:	lw $v0, 0($t0)        # score
		srl $v0, $v0, 5       # reduce magnitude 
		slti $t2, $v0, 0x100  # clamp?
		bne  $t2, $zero, skipClamp
		li $v0, 0xff          # clamp!
skipClamp:	li $t2, 0xff	      # invert to make a score
		sub $v0, $t2, $v0
		sll $v0, $v0, 8       # shift it up into the green
		sw $v0, 0($t0)
		addi $a1, $a1, -1        # decrement column counter	
		bne $a1, $0, pebNotEOL   # Need to skip 8 pixels at the end of each line
		lw $a1, 4($a0)        # load width to reset column counter
        	addi $a1, $a1, -7     # column count for next line is 7 less than width
        	addi $t0, $t0, 28     # skip pointer to end of line (7 pixels x 4 bytes)
pebNotEOL:	add $t0, $t0, 4
		bne $t0, $t1, pebLoop
		jr $ra
