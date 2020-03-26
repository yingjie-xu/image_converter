#Student ID = 260862481
#################################invert Image######################
.data
.text
.globl invert_image
invert_image:
	# $a0 -> image struct
	#############return###############
	# $v0 -> new inverted image
	############################
	# Add Code
	addi $sp, $sp, -4  #allocate space on the stack
	sw $ra, 0($sp)     #save the return address
	
	
	move $s0, $a0
	
	#s1 = max
	lw $s1, 8($s0)
	
	lw $s2, 0($s0)
	lw $s3, 4($s0)
	mul $s4, $s2, $s3
	
	addi $s5, $s0, 12
	
	move $t0, $zero # loop counter
	
invert_loop:
	lb $t1, 0($s5)
	sub $t1, $s1, $t1
	sb $t1, 0($s5)
	
	addi $s5, $s5, 1
	addi $t0, $t0, 1
	beq $t0, $s4, quit_invert
	j invert_loop
	
quit_invert:
	move $v0, $s0
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	jr $ra
