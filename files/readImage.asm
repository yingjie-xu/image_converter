#Student ID = 260862481
#########################Read Image#########################
.data
err:			.asciiz "Fail to open the file\n"
			.align 2
err_2:			.asciiz "File type incorrect\n"
			.align 2
buffer:			.space 1024
.text
		.globl read_image
read_image:
	# $a0 -> input file name
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	#	int width;
	#       int height;
	#	int max_value;
	#	char contents[width*height];
	#	}
	##############################################
	# Add code here
	
	addi $sp, $sp, -4  #allocate space on the stack
	sw $ra, 0($sp)     #save the return address
	
	#open a file
	li   $v0, 13       # system call for open file
	li   $a1, 0        # Open for reading
	li   $a2, 0
	syscall            # open a file (file descriptor returned in $v0)
	blt $v0, $zero, error  # report error if negative
	move $t0, $v0      # save the file descriptor 
	
	#read from file
	li   $v0, 14       # system call for read from file
	move $a0, $t0      # file descriptor 
	la   $a1, buffer   # address of buffer to which to read
	li   $a2, 1024     # hardcoded buffer length
	syscall            # read from file
	
	# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $t0      # file descriptor to close
	syscall            # close file
	
	add $s0, $zero, $a1  # store buffer content in $s0
	
	################## image_type_check ###################
	jal read_white_space
	lbu $t0, 0($s0)
	li $t1, 'P'
	bne $t0, $t1, type_error
	
	addi $s0, $s0, 1
	lbu $t0, 0($s0)
	li $t1, '2'
	beq $t0, $t1, type_fine
	li $t1, '5'
	beq $t0, $t1, type_fine
	j type_error
type_fine:
	addi $s0, $s0, 1
	
	# $s1 = width
	jal read_white_space
	jal read_int
	move $s1, $v0
	
	# $s2 = height
	jal read_white_space
	jal read_int
	move $s2, $v0
	
	# $s3 = max_value
	jal read_white_space
	jal read_int
	move $s3, $v0
	
	# $s4 = width*height
	mul $s4, $s1, $s2
	addi $t5, $s4, -1
	
	# $s5 = total size needed
	addi $s5, $s4, 12
	
	li $v0, 9          # system call for allocate space 
	add $a0, $s5, $zero
	syscall
	
	# $s5 = address of allocated space
	move $s5, $v0
	sw $s1, 0($s5)
	sw $s2, 4($s5)
	sw $s3, 8($s5)
	addi $t6, $s5, 12
	
	# $t2 is the loop counter
	move $t2, $zero
content_loop:
	jal read_int
	move $t3, $v0
	sb $t3, 0($t6)
	
#	li $v0, 1          # system call for print int
#	add $a0, $t3, $zero
#	syscall
	
	addi $t6, $t6, 1
	addi $t2, $t2, 1
	beq $t2, $t5, continue
	
	j content_loop

	
continue:
# Here I want to read the last int by using the check_int function
	move $t4, $zero    #store result in $t4
	jal read_white_space
	addi $s0, $s0, 1
	lbu $t0, 0($s0)
	sub $t0, $t0, 48
#	mul $t4, $t4, 10
	add $t4, $t4, $t0
	jal check_int
	beq $v0, 0, save
	
	addi $s0, $s0, 1
	lbu $t0, 0($s0)
	sub $t0, $t0, 48
	mul $t4, $t4, 10
	add $t4, $t4, $t0
	jal check_int
	beq $v0, 0, save

	addi $s0, $s0, 1
	lbu $t0, 0($s0)
	sub $t0, $t0, 48
	mul $t4, $t4, 10
	add $t4, $t4, $t0
	jal check_int
	beq $v0, 0, save
save:
	sb $t4, 0($t6)
	
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	move $v0, $s5
	jr $ra             #go back
	
##################### read_white_space ##############################
# $v0 = 0 if a white space not found
# $v0 = 1 if a white space is found
# return values are used to move to the next value
#####################################################################
read_white_space:
	addi $sp, $sp, -4  #allocate space on the stack
	sw $ra, 0($sp)     #save the return address
	move $t3, $zero

# call the sub-procedure here
loop_space:
	beq $t3, 10, out_loop
	addi $t3, $t3, 1
	addi $s0, $s0, 1    # move to the next char in the buffer
	lbu $t0, 0($s0)     # put the first byte in $t0
	li $t1, '\n'       # put the \n in t1
	beq $t0, $t1, loop_space 
	li $t1, ' '        # put the space in t1
	beq $t0, $t1, loop_space 
	
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack

	move $v0, $zero
	addi $s0, $s0, -1 
	beq $t3, 1, not_found
	addi $v0, $zero, 1
not_found:
	jr $ra             #go back
out_loop:
	li $v0, 1
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	jr $ra   
	
##################### read_int ############################
# return $v0 
###########################################################
read_int:
	addi $sp, $sp, -4  #allocate space on the stack
	sw $ra, 0($sp)     #save the return address
	move $t4, $zero    #store result in $t4

# call the sub-procedure here
loop_int:
	addi $s0, $s0, 1    # move to the next char in the buffer
	lbu $t0, 0($s0)     # put the first byte in $t0
	sub $t0, $t0, 48
	mul $t4, $t4, 10
	add $t4, $t4, $t0
	jal read_white_space
	beq $v0, 0, loop_int
	
	move $v0, $t4

	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	jr $ra             #go back
	
######################### check_int #################################
# This function is only used to handle the last int from the image file 
# $v0 = 0 if a int not found
# $v0 = 1 if a int is found
# return values are used to move to the next value
#####################################################################
check_int:
	addi $sp, $sp, -4  #allocate space on the stack
	sw $ra, 0($sp)     #save the return address
	addi $s0, $s0, 1
	lbu $t0, 0($s0)     # put the first byte in $t0
	li $t1, '0'       
	beq $t0, $t1, found_int
	li $t1, '1'       
	beq $t0, $t1, found_int
	li $t1, '2'       
	beq $t0, $t1, found_int
	li $t1, '3'       
	beq $t0, $t1, found_int
	li $t1, '4'       
	beq $t0, $t1, found_int
	li $t1, '5'       
	beq $t0, $t1, found_int
	li $t1, '6'       
	beq $t0, $t1, found_int
	li $t1, '7'       
	beq $t0, $t1, found_int
	li $t1, '8'       
	beq $t0, $t1, found_int
	li $t1, '9'       
	beq $t0, $t1, found_int
	j not_int
found_int:
	li $v0, 1
	addi $s0, $s0, -1 
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	jr $ra   
not_int:
	li $v0, 0 
	addi $s0, $s0, -1 
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	jr $ra   

##################### error ############################
error:
	li $v0, 4          # system call for print string
	la $a0, err
	syscall	  
	
	j continue	  

type_error:
	li $v0, 4          # system call for print string
	la $a0, err_2
	syscall	  
	
	j continue	
