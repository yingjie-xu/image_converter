# Student ID = 260862481
###############################rescale image######################
.data
.text
.globl rescale_image
rescale_image:
	# $a0 -> image struct
	############return###########
	# $v0 -> rescaled image
	######################
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
	
	#s7 = min after the find min loop
	move $s7, $s1
	
find_min_loop:
	lbu $t1, 0($s5)
	blt $t1, $s7, set_min
	j no_need
set_min:
	move $s7, $t1
no_need:
	addi $s5, $s5, 1
	addi $t0, $t0, 1
	beq $t0, $s4, quit_loop
	j find_min_loop
	
quit_loop:
	#$s6 = max - min
	sub $s6, $s1, $s7
	beqz $s6, quit_rescale
	
	
	addi $s5, $s0, 12
	move $t0, $zero # loop counter
	
	mtc1 $s6, $f1
	cvt.s.w $f1, $f1 #max - min
	li $t3, 255
	mtc1 $t3, $f3
	cvt.s.w $f3, $f3 #255
	mtc1 $s7, $f7
	cvt.s.w $f7, $f7 #min
	
rescale_loop:
	# do the calculation in the CP1 here
	lbu $t1, 0($s5)
	mtc1 $t1, $f5
	cvt.s.w $f5, $f5
	sub.s $f5, $f5, $f7
	mul.s $f5, $f5, $f3
	div.s $f5, $f5, $f1
	round.w.s $f9, $f5
	mfc1 $t5, $f9
	sb $t5, 0($s5)
	
	addi $s5, $s5, 1
	addi $t0, $t0, 1
	beq $t0, $s4, set_max
	j rescale_loop

#################### change_max_value here ######################
set_max:
	move $t0, $zero # loop counter
	addi $s5, $s0, 12
find_max_loop:
	lbu $t1, 0($s5)
	bgt $t1, $s1, change_max
	j no_need_max
change_max:
	move $s1, $t1
no_need_max:
	addi $s5, $s5, 1
	addi $t0, $t0, 1
	beq $t0, $s4, quit_max_loop
	j find_max_loop

quit_max_loop:
	sb $s1, 8($s0)

quit_rescale:
	move $v0, $s0
	lw $ra, 0($sp)     #restore the return address
	addi $sp, $sp, 4   #restore stack
	jr $ra
