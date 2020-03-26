# Student ID = 260862481
####################################write Image#####################
.data
err:			.asciiz "Fail to open the file\n"
			.align 2
err1:			.asciiz "Incorrect input for writeImage\n"
			.align 2
buffer:			.space 1024
.text
.globl write_image
write_image:
	# $a0 -> image struct
	# $a1 -> output filename
	# $a2 -> type (0 -> P5, 1->P2)
	################# returns #################
	# void
	# Add code here.
	addi $sp, $sp, -4  #allocate space on the stack
	sw $ra, 0($sp)     #save the return address
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	la $s3, buffer
	
	# check the image type and go to the corresponding place
	beq $s2, 0, P5
	beq $s2, 1, P2
	j error_t
P5:
	# write P5 into buffer
	li $t1, 'P'
	sb $t1, 0($s3)
	li $t1, '5'
	sb $t1, 1($s3)
	li $t1, '\n'
	sb $t1, 2($s3)
	j next
P2:
	# write P2 into buffer
	li $t1, 'P'
	sb $t1, 0($s3)
	li $t1, '2'
	sb $t1, 1($s3)
	li $t1, '\n'
	sb $t1, 2($s3)
	
next:
	#move the pointer
	addi $s3, $s3, 3
	
	#save width in $s4
	lw $s4, 0($s0) 
	
	#save height in $s5
	lw $s5, 4($s0) 
	
	#save header info to the buffer
	jal save_int_word
	addi $s0, $s0, 4
	jal save_int_word
	li $t1, '\n'
	sb $t1, 0($s3)
	addi $s3, $s3, 1
	addi $s0, $s0, 4
	jal save_int_word
	addi $s0, $s0, 4

	#change line and move pointer
	li $t1, '\n'
	sb $t1, 0($s3)
	addi $s3, $s3, 1
	
	
#################### save image content ###########################
	
	# $s6 loop counter for width
	move $s6, $zero
	
	# $s7 loop counter for height
	move $s7, $zero

# a nested loop to save the int by loop through rows and columns
outer_loop:
	addi $s7, $s7, 1

inner_loop:
	addi $s6, $s6, 1
	jal save_int_byte
	beq $s6, $s4, out
	j inner_loop

out:
	move $s6, $zero  # reset counter for width
	li $t8, '\n'
	sb $t8, 0($s3)
	addi $s3, $s3, 1
	
	beq $s7, $s5, out_loop
	j outer_loop

out_loop:

####################### save_to_file ##############################	
	#open a file
	li   $v0, 13       # system call for open file
	move $a0, $s1
	li   $a1, 9        # Open for write-only 
	li   $a2, 0
	syscall            # open a file (file descriptor returned in $v0)
	blt $v0, $zero, error_open  # report error if negative
	move $t0, $v0      # save the file descriptor 
	
	#read from file
	li   $v0, 15       # system call for write to file
	move $a0, $t0      # file descriptor 
	la   $a1, buffer   # address of buffer to which to write
	li   $a2, 1024     # hardcoded buffer length
	syscall            # read from file
	
	# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $t0      # file descriptor to close
	syscall            # close file
	
back:
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	jr $ra

######################## save_int_word ######################
# $s3 --> position to save
# $s0 --> position to read from the struct
#############################################################
save_int_word:
	addi $sp, $sp, -4  #allocate space on the stack
	sw $ra, 0($sp)     #save the return address
	
	
	lw $t1, 0($s0)
	li $t2, 10
	div $t1, $t2
	mfhi $t3 # reminder to $t3  --> 1st
	addi $t3, $t3, 48
	mflo $t4 # quotient to $t4
	beq $t4, 0, one
	
	div $t4, $t2
	mfhi $t5 # reminder to $t5 --> 2nd
	addi $t5, $t5, 48
	mflo $t4 # quotient to $t4
	beq $t4, 0, two
	
	div $t4, $t2
	mfhi $t6 # reminder to $t6 --> 3rd
	addi $t6, $t6, 48
	mflo $t4 # quotient to $t4
	beq $t4, 0, three
	
	mfhi $t7 # reminder to $t7 --> 4th
	addi $t7, $t7, 48
	j four
	
one:
	# if one byte
	sb $t3, 0($s3)
	li $t8, ' '
	sb $t8, 1($s3)
	addi $s3, $s3, 2
	j go_back
two:
	# if two byte
	sb $t5, 0($s3)
	sb $t3, 1($s3)
	li $t8, ' '
	sb $t8, 2($s3)
	addi $s3, $s3, 3
	j go_back
three:
	# if three byte
	sb $t6, 0($s3)
	sb $t5, 1($s3)
	sb $t3, 2($s3)
	li $t8, ' '
	sb $t8, 3($s3)
	addi $s3, $s3, 4
	j go_back
four:
	# if four byte
	sb $t7, 0($s3)
	sb $t6, 1($s3)
	sb $t5, 2($s3)
	sb $t3, 3($s3)
	li $t8, ' '
	sb $t8, 4($s3)
	addi $s3, $s3, 5
	
go_back:
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	jr $ra

######################## save_int_byte ######################
# $s3 --> position to save
# $s0 --> position to read from the struct
#############################################################
save_int_byte:
	addi $sp, $sp, -4  #allocate space on the stack
	sw $ra, 0($sp)     #save the return address
	
	
	lbu $t1, 0($s0)
	li $t2, 10
	div $t1, $t2
	mfhi $t3 # reminder to $t3  --> 1st
	addi $t3, $t3, 48
	mflo $t4 # quotient to $t4
	beq $t4, 0, one_byte
	
	div $t4, $t2
	mfhi $t5 # reminder to $t5 --> 2nd
	addi $t5, $t5, 48
	mflo $t4 # quotient to $t4
	beq $t4, 0, two_byte
	
	div $t4, $t2
	mfhi $t6 # reminder to $t6 --> 3rd
	addi $t6, $t6, 48
	j three_byte
	
one_byte:
	li $t8, ' '
	sb $t8, 0($s3)
	li $t8, ' '
	sb $t8, 1($s3)
	sb $t3, 2($s3)
	li $t8, ' '
	sb $t8, 3($s3)
	addi $s3, $s3, 4
	j end_byte
two_byte:
	li $t8, ' '
	sb $t8, 0($s3)
	sb $t5, 1($s3)
	sb $t3, 2($s3)
	li $t8, ' '
	sb $t8, 3($s3)
	addi $s3, $s3, 4
	j end_byte
three_byte:
	sb $t6, 0($s3)
	sb $t5, 1($s3)
	sb $t3, 2($s3)
	li $t8, ' '
	sb $t8, 3($s3)
	addi $s3, $s3, 4
	
end_byte:
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	addi $s0, $s0, 1
	jr $ra


##################### error #######################
error_open:
	li $v0, 4          # system call for print string
	la $a0, err
	syscall	  
	j back

error_t:
	li $v0, 4          # system call for print string
	la $a0, err1
	syscall	  
	j back
