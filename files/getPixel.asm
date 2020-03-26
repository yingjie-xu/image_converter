# Student ID = 260862481
##########################get pixel #######################
.data
err_col:		.asciiz "Invalid column number\n"
			.align 2
err_row:		.asciiz "Invalid row number\n"
			.align 2
.text
.globl get_pixel
get_pixel:
	# $a0 -> image struct
	# $a1 -> row number
	# $a2 -> column number
	################return##################
	# $v0 -> value of image at (row,column)
	#######################################
	# Add Code
	addi $sp, $sp, -4  #allocate space on the stack
	sw $ra, 0($sp)     #save the return address
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	
	# $s3 saves width
	lw $s3, 0($s0)
	# if col num < width --> t1 = 1
	slt $t1, $s2, $s3
	bne $t1, 1, error_col
	
	# $s4 saves height
	lw $s4, 4($s0)
	# if row num < height --> t1 = 1
	slt $t1, $s1, $s4
	bne $t1, 1, error_row
	
	move $s5, $zero
	mul $s5, $s1, $s3
	add $s5, $s5, $s2
	addi $s5, $s5, 12
	add $s5, $s0, $s5
	
	lbu $t0, 0($s5)
	
#	li $v0, 1
#	move $a0, $t0
#	syscall
	
quit_get:
	move $v0, $t0
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	jr $ra

######################## error ############################
error_col:
	li $v0, 4		#syscall for print string
	la $a0, err_col
	syscall
	move $t0, $zero
	j quit_get

error_row:
	li $v0, 4		#syscall for print string
	la $a0, err_row
	syscall
	move $t0, $zero
	j quit_get
