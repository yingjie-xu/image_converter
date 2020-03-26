# Student ID = 260862481
##########################set pixel #######################
.data
set_col:		.asciiz "Invalid column number\n"
			.align 2
set_row:		.asciiz "Invalid row number\n"
			.align 2
.text
.globl set_pixel
set_pixel:
	# $a0 -> image struct
	# $a1 -> row number
	# $a2 -> column number
	# $a3 -> new value (clipped at 255)
	###############return################
	#void
	# Add code here
	addi $sp, $sp, -4  #allocate space on the stack
	sw $ra, 0($sp)     #save the return address
	
	
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s6, $a3
	
	# $s3 saves width
	lw $s3, 0($s0)
	# if col num < width --> t1 = 1
	slt $t1, $s2, $s3
	bne $t1, 1, error_col_s
	
	# $s4 saves height
	lw $s4, 4($s0)
	# if row num < height --> t1 = 1
	slt $t1, $s1, $s4
	bne $t1, 1, error_row_s
	
	# $s5 stores the position to change
	move $s5, $zero
	mul $s5, $s1, $s3
	add $s5, $s5, $s2
	addi $s5, $s5, 12
	add $s5, $s0, $s5
	
	# if 256 <= $s6 --> $t3 = 1
	li $t2, 256
	sle $t3, $t2, $s6
	beq $t3, 1, reset
	j nothing
reset:
	li $s6, 255
nothing:
	sb $s6, 0($s5)
	
	lw $t4, 8($s0)
	# if $t4 < $s6 then set max to $s6
	slt $t5, $t4, $s6
	beq $t5, 1, change
	j quit_set
change:
	sw $s6, 8($s0)
	
quit_set:
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	jr $ra

######################## error ############################
error_col_s:
	li $v0, 4		#syscall for print string
	la $a0, set_col
	syscall
	j quit_set

error_row_s:
	li $v0, 4		#syscall for print string
	la $a0, set_row
	syscall
	j quit_set