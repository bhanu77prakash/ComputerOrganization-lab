		.text
		.globl main
main: 									
		# Making space for the local variables sum and number.
		move $fp, $sp;			#set frame pointer as the base for local variables
		subu $sp, $sp, 8;			#creating space for the sum variable.
									# -4($fp) = &n and &sum = -8($fp) 
		

		#Making syscall to print "Enter a positive integer:"

		la $a0, out1
		li $v0, 4
		syscall

		# Making syscall to scan an integer n
		li $v0, 5								
		syscall 								#Integer is read and stored in v0
		sw $v0, -4($fp)							#storing the n in -4($fp)
					
		lw $t0, -4($fp)							#the value of n is loaded into the register t0
		subu $t2, $t2, $t2						#sum is made 0.
		li $t1, 1								#value of local variable i is loaded with value 1.
		blt	$t1, $t0, loop						#check condition for the for loop. i.e if only i<n then enter the for loop.
		b exit_cond								#if initially itself i>=n then skip the for loop and go to end.

loop:											#Label for the for loop that is used in the program. 
		bge	$t1, $t0, exit_cond					#if i>=n break the loop and reach the exit condition.
		div $t0, $t1							#This and below line together executes for the line remainder = number%i.(to check if i is a factor of n or not)
		mfhi $t3								#t3 is the register for storing the remainder when number is divided by i.
		beq $t3, 0, if_cond						#if remainder == 0 i.e i is a factor of n
		add $t1, $t1, 1							#if i is not a factor, increase i by one and go back to loop.
		b loop									#Go back to loop start.
if_cond:
		add $t2, $t2, $t1						#add i to sum of the factors i.e sum($t2 reg)
		add $t1, $t1, 1							#increase value of i by 1;
		b loop 									#Go back to loop start.

exit_cond:										#Label for outside part of for loop.
		beq $t2, $t0, true_num					#if sum(sum of factors) == number goto the true part.
		
		# Making syscall to print failure message in case of not a perfect number.
		la $a0, failout							
		li $v0, 4 								
		syscall
		b exit_prog								# Goto exit part of the program.
true_num:
		
		#Making syscall to print sucess message in case of perfect number.
		la $a0, successout
		li $v0, 4 
		syscall
		b exit_prog  							# Goto exit part of program after printing .
exit_prog:
		

		# Syscall for exit
		li $v0, 10
		syscall

		.data									# The string literals are stored in data part of the program.	
out1: .asciiz	 "Enter a positive integer: "
successout: .asciiz	 "entered number is a perfect number\n"
failout:	.asciiz "entered number is not a perfect number\n"

# end of perfectnumber.asm