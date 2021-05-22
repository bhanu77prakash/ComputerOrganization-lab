# This code still has the values 330 and 481 in the conngruential scheme. Please change the value to lower values in case to check for higher order determinants.
# higher order implies >=4

# Main idea of this code:
# 			This code evaluates the determinant recursively by using cofactor matrix and finding the determinant of cofactor matrix.
# 			For each element in the top row of the matrix find the cofactors and their determinants recursively and find the overall determinant.
#			The base case for this recursion is when size of matrix is 1*1. Then determinant is the value itself.

# All the co-factors and their determinants are printed at each recursive call. The final determinant is printed at the end.

	.text
	.globl main

main:
			# Making space for the variables n,m,seed, i, j.
		move $fp, $sp
		sub $sp, $sp, 24

		
			# Making syscall to print "Enter the order of the square matrix whose determinant is to be found: "
		la $a0, inputn
		li $v0, 4
		syscall

			# Making syscall to scan the integer n
		li $v0, 5
		syscall
		sw $v0, -4($fp)
		
			# Making syscall to print "seed: "
		la $a0, inputseed
		li $v0, 4
		syscall

			# Making syscall to scan the integer seed
		li $v0, 5
		syscall
		sw $v0, -8($fp)
		
			# Creating n*n*4 bytes for matrix A.
		lw $t0, -4($fp)
		lw $t1, -4($fp)
		mul $t1, $t1, $t0
		mul $t1, $t1, 4

		sub $t3, $fp, 24						# t3 has the base address of the matrix A


		sub $sp, $sp, $t1
		sub $sp, $sp, 4
		sw $fp, 4($sp)						

			# Evaluating the values of matrix A
		li $t0, 0								# i = 0
		li $t5, 481								# storing the value 481 in reg t5
		lw $t4, -8($fp)							# fp-16 has the value of seed. t4 = seed

fillin_loop:		
				
		bge $t0, $t1, fillin_exit				# if i>= n*n then exit
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
		
		lw $a0, -4($fp)							# a0 = fp-8 = n . First argument to the function
		move $a1, $t3							# a2 = base address of the A matrix . Third argument to the function
		sw $t3, -20($fp)						# Storing the callee saved registers in memory

		jal matPrint							# Calling the matrix Print function

		lw $a0, -4($fp)							# a0 = n. First argument to the function
		lw $a1, -20($fp)						# a1 = base address of matrix A. Second argument to the function findDet. 

		jal findDet								# Calling the determinant find function.

		move $t3, $v0							# storing the return value from the function findDet.
		
		la $a0, determinant						# Printing the statement "Finally the determinant is: "
		li $v0, 4
		syscall

		move $a0, $t3							# Printing the returned determinant value.
		li $v0, 1
		syscall

		la $a0, newline 						# Printing a new line
		li $v0, 4
		syscall

		li $v0, 10								# syscall for exit
		syscall

matPrint:	
	
		move $t1, $a0							# first argument n is copied to t1. t1 =  n
		move $t2, $a0							# t2 is also given value n to compute n*n value
		move $s2, $a1							# second argument is copied to s2. s2 = base address of the input matrix
		mul $t2, $t1, $t2						# computing the value n*n
		li $t0, 1								# i = 1
		
print_loop:

		bgt $t0, $t2, printloop_exit			# if i>= n*n then exit
		
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
		jr $ra									# return statement

findDet:
		move $fp, $sp 							# Previous stack pointer is present frame pointer to start the function.
		sub $sp, $sp, 40						# Creating space for local variables.
		beq $a0, 1, base_case					# if n == 1 => only one element in matrix and hence base case needs to be executed.
		b rec_case								# Else goto recursion.

base_case:
		# Callee saved registers. 
		sw $ra, -36($fp)						# store the return address value
		sw $a1, -12($fp)						# store the base address of the input matrix.
		
		move $t3, $a0							# storing the value of a0 in t3
		la $a0, submatrix						# Printing the statement "The matrix passed on this invocation is: "
		li $v0, 4
		syscall

		move $a0, $t3							# restoring back a0 i.e value of n.
		jal matPrint							# function call for matPrint

		lw $ra, -36($fp)						# restoring the return address.

		la $a0, subdet							# Printing the statement "The determinant value returned in this invocation is: "
		li $v0, 4
		syscall

		lw $t3, -12($fp)						# Restoring the base address of the input matrix.
		lw $a0, ($t3)							# Printing the base case i.e the one value in the matrix itself.
		li $v0, 1
		syscall

		la $a0, newline 						# Printing a new line
		li $v0, 4
		syscall

		lw $v0, ($a1)							# storing the determinant value in v0
		move $sp, $fp 							# Restroing back the stack pointer for the caller function
		jr $ra 									# Return statement. 

rec_case:
		sw $sp, -16($fp) 						# storing the base address for the temp matrix.
		move $t0, $a0							# store the value of n in t0
		move $t1, $a0							# store the value of n in t1
		mul $t1, $t1, $t0 						# computing the value of n*n
		mul $t1, $t1, 4 						# computing the value 4*n*n for the space of the temp matrix.

		sub $sp, $sp, $t1 						# Creating space for the temp matrix of size n*n
		sub $sp, $sp, 4	
		move $t2, $a1							# storing the base address of A in t2
		li $t3, 0								# t3 = D = 0
		li $t4, 1								# t4 contains the value of sign(for alternating the sign of cofactor matrix determinant)
		li $t5, 0 								# iterator f = 0

for_loop_1:
		bge $t5, $t0, for_exit1 				# if f>=n then exit this for loop
		sw $t3, -20($fp) 						# fp - 20 stores the value of D
		sw $t0, -8($fp)							# storing the value of n at fp - 8
		sw $t2, -12($fp) 						# Storing the value of base address of input matrix at fp - 12
		sw $t4, -24($fp) 						# Storing the value of sign at fp - 24
		sw $t5, -28($fp)						# Storing the value of f in fp - 28
		sw $fp, 4($sp) 							# Storing the frame pointer address in sp+4
		lw $a0, -12($fp)						# Loading first argument one for the coFactor function i.e input matrix
		lw $a1, -16($fp) 						# Loding second argument for the coFactor function i.e temp matrix.
		li $a2, 0 								# Loading third argument for the coFactor function i.e 0
		move $a3, $t5 							# Loading fourth argument for the coFactor function i.e f
		lw $t9, -8($fp) 						# Seding the reg t9 as the fifth argument to the coFactor function. i.e n

		sw $ra, -36($fp) 						# store the return address before the function call.
		jal coFactor 							# Call coFactor function to find co-factor matrix.

		lw $fp , 4($sp)  						# Restore the frame pointer.
		lw $t3, -20($fp)						# Restore the D value. D is the determinant value so far.
		lw $t0, -8($fp)							# restoring the value of n at fp - 8
		lw $t2, -12($fp) 						# restoring the value of base address of input matrix at fp - 12
		lw $t4, -24($fp) 						# restoring the value of sign at fp - 24
		lw $t5, -28($fp) 						# restoring the value of f at fp - 28
		lw $ra, -36($fp) 						# restoring the value of return address at fp - 36
		mul $t6, $t5, 4 						# computing the value 4*f to access the value of mat[0][f].
		sub $t6, $t2, $t6  						# t6  = &mat[0][f]
		lw $t6, ($t6) 							# t6 = mat[0][f]
		mul $t6, $t4, $t6 						# t6 = t6 * t4 => multipying with sign.
		
		sw $t3, -20($fp) 						# fp - 20 stores the value of D
		sw $t0, -8($fp)							# storing the value of n at fp - 8
		sw $t2, -12($fp) 						# Storing the value of base address of input matrix at fp - 12
		sw $t4, -24($fp) 						# Storing the value of sign at fp - 24
		sw $t5, -28($fp)						# Storing the value of f in fp - 28
		sw $fp, 4($sp) 							# Storing the frame pointer address in sp+4
		sw $t6, -32($fp) 						# Storing a temp value in fp - 32 that is required later.
 
		lw $a1, -16($fp) 						# Loading second argument for the recursive call of the det function. co factor matrix is now passed as input matrix for det function
		sub $a0, $t0, 1  						# Loading first argument to the function n-1 i.e size of the co-factor the matrix.

		sw $ra, -36($fp)  						# store the return address before jumping to recursive call.
		jal findDet 							# Recursive call to the determinant function.

		lw $fp, 4($sp)   						# Restoring the value of the frame pointer after returning from the function.
		lw $t3, -20($fp) 						# Restore the D value. D is the determinant value so far.
		lw $t0, -8($fp)							# storing the value of n at fp - 8
		lw $t2, -12($fp)						# restoring the value of base address of input matrix at fp - 12
		lw $t4, -24($fp) 						# restoring the value of sign at fp - 24
		lw $t5, -28($fp) 						# restoring the value of f at fp - 28
		lw $t6, -32($fp) 						# restoring the temp value stored at fp - 32 
		lw $ra, -36($fp) 						# restoring the value of return address at fp - 36
		mul $t6, $v0, $t6 						# computing the statement D = D + sign * mat[0][f] * detOfMat(temp). Here the temp is the co factor matrix.
		add $t3, $t3, $t6 				
		li $t7, 0 								# temp reg storing value 0
		sub $t4, $t7, $t4 						# inverting the sign for the next cofactor matrix determinant.
		add $t5, $t5, 1 						# Increasing the iterator.
		b for_loop_1 							# Go back to for loop

for_exit1:
		la $a0, submatrix 						# Printing the statement "The matrix passed on this invocation is:"
		li $v0, 4
		syscall

		sw $t3, -20($fp) 						# store the value of determinant in fp - 20
		sw $ra, -36($fp)  						# store the return address at fp - 36
		lw $a0, -8($fp)							# a0 = fp-8 = n . First argument to the function
		lw $a1, -12($fp)						# a1 = base address of the A matrix . Second argument to the function
		jal matPrint 							# Function call for matrix print.

		lw $t3, -20($fp) 						# Restore the D value. D is the determinant value so far. 
		lw $ra, -36($fp)  						# restoring the value of return address at fp - 36

		la $a0, subdet 							# Printing the statement "The determinant value returned in this invocation is:"
		li $v0, 4
		syscall

		move $a0, $t3 							# Printing the determinant value in this recursion step.
		li $v0, 1
		syscall

		la $a0, newline 						# Printing a new line,
		li $v0, 4
		syscall

		move $v0, $t3 							# Store the determinant in the return value register v0
		move $sp, $fp 							# Restore back the stck pointer of the caller function.
		jr $ra 									# Return statement.

coFactor:										# A helper function that finds the cofactor matrix of a given value A[i][j] and stores it in a temp matrix that is also an input argument to the function.
		li $t0, 0 								# a local variable that is used in indexing temp matrix. i = 0 
		li $t1, 0 								# a local variable that is used in indexing temp matrix. j = 0

		li $t2, 0 								# a local variable that is used in indexing A matrix. l = 0
for_loop_2: 
		bge $t2, $t9, for_exit2 				# if l>=n that is row is out of bound then exit
		li $t3, 0 								# a local variable that is used in indexing A matrix. m = 0

for_loop_3:
		bge $t3, $t9, for_exit3   				# if m>=n that is column is out of bound then exit
		beq $t2, $a2, if_exit1 					# to find cofactor matrix i!=l and j!=m i.e delete that row and delete that column.
		beq $t3, $a3, if_exit1 					
		sub $t6, $t9, 1 						# The following 5 lines are for computing the address of the value temp[i][j]
		mul $t4, $t0, $t6
		add $t4, $t4, $t1
		mul $t4, $t4, 4
		sub $t4, $a1, $t4
		
		mul $t5, $t2, $t9 						# The following 4 lines are for computing the address of the value A[l][m]
		add $t6, $t5, $t3 						
		mul $t6, $t6, 4
		sub $t6, $a0, $t6
		
		lw $t5, ($t6)							# t5 loads A[l][m]
		sw $t5, ($t4) 							# temp [i][j] = A[l][m]
		add $t1, $t1, 1     					# increase iterator.

		sub $t6, $t9, 1  						# The following if_condition is for to check if col of temp matrix is going >= n-1. If yes then increase row and make j = 0
		beq $t1, $t6, if_cond_2
		b if_exit1
if_cond_2:
		li $t1, 0
		add $t0, $t0, 1

if_exit1:

		add $t3, $t3, 1							# increase iterator.
		b for_loop_3 							# Go back to for loop

for_exit3:
		add $t2, $t2, 1							# increase iterator.
		b for_loop_2							# go back to for loop
for_exit2:

		jr $ra									# return statement
.data											# string literals
		
inputn: .asciiz "Enter the order of the square matrix whose determinant is to be found:"
inputseed: .asciiz "Enter some positive integer for the value of the seed s:"
promptEnter: .asciiz "Enter three positive integers m, n, s: \n"
newline: .asciiz "\n"
space: .asciiz "\t"
original: .asciiz "\nThe given matrix is:\n"
determinant: .asciiz "\nFinally the determinant is: "
submatrix: .asciiz "\nThe matrix passed on this invocation is: \n"
subdet: .asciiz "\nThe determinant value returned in this invocation is: \n"