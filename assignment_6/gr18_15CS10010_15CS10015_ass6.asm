	.text
	.globl main

main:
			# Making space for the variables n,m,seed, i, j.
		move $fp, $sp
		sub $sp, $sp, 24

			# Making syscall to print "Enter three positive integers:"
		la $a0, promptEnter
		li $v0, 4
		syscall
		
			# Making syscall to print "m: "
		la $a0, inputm
		li $v0, 4
		syscall

			# Making syscall to scan the integer m
		li $v0, 5
		syscall
		sw $v0, -4($fp)
		
			# Making syscall to print "n: "
		la $a0, inputn
		li $v0, 4
		syscall

			# Making syscall to scan the integer n
		li $v0, 5
		syscall
		sw $v0, -8($fp)
		
			# Making syscall to print "seed: "
		la $a0, inputseed
		li $v0, 4
		syscall

			# Making syscall to scan the integer seed
		li $v0, 5
		syscall
		sw $v0, -16($fp)
		
			# Creating m*n*4 bytes for both A and B matrices.
		lw $t0, -4($fp)
		lw $t1, -8($fp)
		mul $t1, $t1, $t0
		mul $t1, $t1, 4

		sub $t3, $fp, 24						# t3 has the base address of the matrix A
		sub $sp, $sp, $t1						

		sub $sp, $sp, 40

		move $s6, $sp							# s6 has the base address of the matrix B
		sub $sp, $sp, $t1

			# Evaluating the values of matrix A
		li $t0, 0								#i = 0
		li $t5, 481								#storing the value 481 in reg t5
		lw $t4, -16($fp)						#fp-16 has the value of seed. t4 = seed

fillin_loop:		
				
		bge $t0, $t1, fillin_exit				# if i>= m*n then exit
		mul $s0, $t0, 4							# s0 = 4*i
		sub $s2, $t3, $s0						# s2 = A-4*i = &A[i]. Here as the matrix is developed in row major form.
		mul $s3, $t4, 330						# s3 = 330*X(n-1)
		add $s3, $s3, 100						# s3 = 330*X(n-1)+100 
		div $s3, $t5							# s3 = (330*X(n-1)+100)/481
		mfhi $s3								# s3 has the remainder when divided by 481
		sw  $s3, ($s2)							# A[i] = calculated value = (330*X(n-1)+100)%481

		move $t4, $s3							# X(n) = X(n-1) for the next value
		add $t0, $t0, 1							# i = i+1
		b fillin_loop							# goto for loop

fillin_exit:
		la $a0, original
		li $v0, 4
		syscall
		
		lw $a0, -8($fp)							# a0 = fp-8 = n . First argument to the function
		lw $a1, -4($fp)							# a1 = fp-4 = m . Second argument to the function
		move $a2, $t3							# a2 = base address of the A matrix . Third argument to the function
		sw $t3, -20($fp)						# Storing the callee saved registers in memory

		jal matPrint							# Calling the matrix Print function

		la $a0, transposed
		li $v0, 4
		syscall
		
		lw $t3, -20($fp)						# restoring the callee saved reg t3 i.e base address of the array A.
		lw $a0, -8($fp)							# a0 = n. First argument to the function
		lw $a1, -4($fp)							# a1 = m. Second argument to the function matrix transpose
		move $a2, $t3							# a2 = base address of matrix A
		move $a3, $s6							# a3  = base address of the matrix B

		jal matTrans							# Calling the matrix transpose function

		la $a0, newline							# Printing a new line
		li $v0, 4
		syscall

		
		
		lw $a0, -4($fp)							# a0 = m. First argument to the function.
		lw $a1, -8($fp)							# a1 = n
		move $a2, $s6							# a2 = base address of the matrix B
		jal matPrint							# Calling the function matrix transpose

		li $v0, 10								# syscall for exit
		syscall

matPrint:	
	
		move $t1, $a0							# first argument n is copied to t1. t1 =  n
		move $t2, $a1							# second argument m is copied to t2. t2 =  m
		move $s2, $a2							# third argument is copied to s2. s2 = base address of the input matrix
		mul $t2, $t1, $t2						# computing the value m*n
		li $t0, 1								# i = 1
		
print_loop:

		bgt $t0, $t2, printloop_exit			# if i>= m*n then exit
		
		lw $a0, ($s2)							# a0 = A[i][j]. And making syscall to print the number
		li $v0, 1
		syscall
		
		la $a0, space							# syscall to print space
		li $v0, 4								
		syscall 

		div $t0, $t1							# to check if n numbers are finished or not. to check if a row is finished or not.
		mfhi $t3

		beq $t3, 0, print_newline				# If the line has ended, new line is printed
		b next									# Otherwise next function is called to move $s2 to next element and increase iterator $t0

print_newline:									# Prints newline character "\n"
		la $a0, newline
		li $v0, 4
		syscall

next:		
		sub $s2, $s2, 4							# s2 is moved down on stack one step
		add $t0, $t0, 1							# t0 is incremented (i++)

		b print_loop							# goes back to print_loop
printloop_exit:

		jr $ra									# return

matTrans:
		move $t0, $a0							# store the value of n in t0
		move $t1, $a1							# store the value of m in t1
		move $t2, $a2							# storing the base address of A in t2
		move $t3, $a3							# storing the base address of B in t3
		
		li $t4, 0								# i=0
		li $t5, 0								# j=0

for_loop1:
		bge $t4, $t1, for_loop1_exit			# if i>=m then exit 

for_loop2:
		bge $t5, $t0, for_loop2_exit			# if j>=n then exit

		mul $t6, $t4, $t0						# t6 = i*m to calculate the row in mat A
		add $t6, $t6, $t5						# t6 = i*m + j => A[i][j]
		mul $t6, $t6, 4							# 4 bytes for each int 

		sub $t6, $t2, $t6						# t6 = &A[i][j]
		lw $t7, ($t6)							# t7 = A[i][j]

		mul $t6, $t5, $t1						# t6 = j*n to calculate the row in mat B
		add $t6, $t6, $t4						# t6 = j*n + i => B[j][i]
		mul $t6, $t6, 4							# 4 bytes for each int 
		sub $t6, $t3, $t6						# t6 = &B[j][i]

		sw $t7, ($t6)							# B[j][i] = t7 = A[i][j]
		add $t5, $t5, 1							# j = j+1
		b for_loop2								# go back to inner for loop
for_loop2_exit:
		li $t5, 0								# j = 0 for next row iteration
		add $t4, $t4, 1							# i = i+1
		b for_loop1								# go back to outer for loop
for_loop1_exit:
		jr $ra									# return statement
		
.data									# string literals
		
inputm: .asciiz "m:"
inputn: .asciiz "n:"
inputseed: .asciiz "seed:"
promptEnter: .asciiz "Enter three positive integers m, n, s: \n"
newline: .asciiz "\n"
space: .asciiz "\t"
original: .asciiz "\nThe original matrix is:\n\n"
transposed: .asciiz "\nThe transposed matrix is: \n"