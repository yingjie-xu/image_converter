#Student ID = 260862481
############################ Q1: file-io########################
.data
			.align 2
inputTest1:		.asciiz "./comp273A3/template/test1.txt"
			.align 2
inputTest2:		.asciiz "./comp273A3/template/test2.txt"
			.align 2
outputFile:		.asciiz "./comp273A3/template/copy.pgm"
			.align 2
str: 			.asciiz "P2\n24 7\n15\n"
			.align 2
err:			.asciiz "Fail to open the file "
			.align 2
buffer:			.space 1024
.text
.globl fileio

fileio:
	
	la $a0,inputTest1
	#la $a0,inputTest2
	jal read_file
	
	la $a0,outputFile
	jal write_file
	
	li $v0,10		# exit...
	syscall	
		

	
read_file:
	# $a0 -> input filename	
	# Opens file
	# read file into buffer
	# return
	# Add code here
	
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
	
	li $v0, 4          # system call for print string
	add $a0, $a1, $zero
	syscall
	
	jr $ra
	
write_file:
	# $a0 -> outputFilename
	# open file for writing
	# write following contents:
	# P2
	# 24 7
	# 15
	# write out contents read into buffer
	# close file
	# Add code here
	
	#open a file
	li   $v0, 13       # system call for open file
	li   $a1, 9        # Open for write
	li   $a2, 0
	syscall            # open a file (file descriptor returned in $v0)
	blt $v0, $zero, error  # report error if negative
	move $t0, $v0      # save the file descriptor 

	#write str to the file
	li   $v0, 15       # system call for write to file
	move $a0, $t0      # file descriptor 
	la   $a1, str      # write the str to the file
	li   $a2, 11    
	syscall            # read from file

	#write buffer to the file
	li   $v0, 15       # system call for write to file
	move $a0, $t0      # file descriptor 
	la   $a1, buffer   # write from buffer to file
	li   $a2, 1024     
	syscall            # read from file

	# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $t0      # file descriptor to close
	syscall            # close file
	
	jr $ra
	
error:
	li $v0, 4          # system call for print string
	la $a0, err
	syscall	  
	
	li $v0,10		# exit...
	syscall		  
