#This program is based on insertion sort(not exactly but similar).		
#After reading each element, the array is traversed to check if the element may present in the k largest numbers or not.
#After this program, the array(k size) consists of k largest elements. This means that the minimum of this array is the required answer.
		
		.text
		.globl main
main: 											
		# Making space for the local variables sum and number.
		
		move $fp, $sp
		subu $sp, $sp, 20

		#Making syscall to print "Enter the value of k: "

		la $a0, out1
		li $v0, 4
		syscall

		# Making syscall to scan the integer k
		li $v0, 5								
		syscall 								#Integer is read and stored in v0
		sw $v0, -4($fp)							#storing k in -4($fp)

		#Making syscall to print "Enter the count of elements to be read: "

		la $a0, out2
		li $v0, 4
		syscall

		# Making syscall to scan the integer n
		li $v0, 5								
		syscall 								#Integer is read and stored in v0
		sw $v0, -8($fp)							#storing n in -8($fp)

		# Creating space for k sized array
		lw 	$t1, -4($fp)						#t1 = k;
		mul $t2, $t1, 4							#t2 = t1*4 => t2 = 4*k;
		subu $sp, $sp, $t2						#sp is shifted by 4*k size

		li $t2, 0								#t2 = i = 0;
		lw $t3, -8($fp)							#t3=n
		bgt $t1, $t3, if_fail_4					#if (k>n) then return failure
		#bge	$t2, $t1, for_exit 					#if(i>=k) then exit 

		
for_loop:										#for_loop is responsible for reading the first k elements of input
		bge	$t2, $t1, for_exit 					#if(i>=k) then exit
		mul $t4, $t2, 4							#t4 = t2*4 => t4 = i*4
		subu $t3, $fp, $t4						#t3 = fp-t4 => t3 = &a[i]
		la $a0, out5
		li $v0, 4
		syscall
		li $v0, 5								
		syscall 								#Integer is read and stored in v0
		sw $v0, -12($t3)						#storing n in a[i], fp-12 is the base address for the array 		
		add	$t2, $t2, 1							#i = i+1
		b for_loop 								# goback to for loop

for_exit:										#for_exit is called once k elements are read
		#move $t2, $t1							#i = k;
		lw	$t3, -8($fp)						#t3 = n;
		bge	$t2, $t3, for_exit_2				#if(i>=n) then exit this for loop

		#In this for loop, the remaining n-k elements are read and if min(array) < scanned integer, then replace the element with scanned integer. 
		#After this for loop this program ensures to have k largest elements in the array.
		#The minimum of the k sized array is the required value.
		
for_loop_2:	
		bge	$t2, $t3, for_exit_2				#if(i>=n) then exit this for loop
		la $a0, out5							#Making syscall for printing "Enter a number: "
		li $v0, 4
		syscall
		li $v0, 5								
		syscall 								#Integer is read and stored in v0
		move $t4, $v0 							# t4 = temp  is read;
		li	$t5, 0								# load t5 i.e min(local variable) with 0;
		li	$t6, 0								# j = 0
		bge	$t6, $t1, for_exit_3				#if(j>=k) then exit this for loop

for_loop_3:								
		bge $t6, $t1, for_exit_3				#if(j>=k) then exit this for loop	
		mul	$t7, $t6, 4							#t7 = t6*4 => t7 = j*4
		subu $s1, $fp, $t7						#s1 = fp-t7 => s1 = &a[j]
		mul $s2, $t5, 4							#s2 = t5*4 => s2 = min*4
		subu $s3, $fp, $s2						#s3 = fp-s2 => s3 = &a[min]
		lw $s4, -12($s3)						
		lw $s5, -12($s1)
		bge $s5, $s4, if_fail_1					#if(a[min]>=a[j]) then goto else part

if_cond_1:
		move $t5, $t6							#if(a[min] < a[j]) then min = j
		add $t6, $t6, 1							#j = j+1
		b for_loop_3							#goback to for loop 3
		
if_fail_1:
		add $t6, $t6, 1							#j = j+1
		b for_loop_3							# go back to for loop 3

for_exit_3:
		mul $s2, $t5, 4							#s2 = t5*4 => s2 = min*4
		subu $s3, $fp, $s2						#s3 = fp-s2 => s3 = &a[min]
		lw $s4, -12($s3)
		bge $s4,$t4,if_fail_2					#if(a[min]>= temp i.e entered value) then goto else part

if_cond_2:
		mul $s2, $t5, 4							#s2 = t5*4 => s2 = min*4
		subu $s3, $fp, $s2						#s3 = fp-s2 => s3 = &a[min]
		sw	$t4, -12($s3) 
		add $t2, $t2, 1							#i = i+1
		b for_loop_2							# go back to for loop 2

if_fail_2:
		add	$t2, $t2, 1							#i = i+1
		b for_loop_2							# go back to for loop 2

		#Finding the min of the a[k] array that gives the k-th largest element in given array
for_exit_2:
		lw $t5, -12($fp)						# min = a[0]
		li $t2, 0								# i = 0
		bge $t2, $t1, for_exit_4				#if(i>=k) then goto else part

for_loop_4:
		bge $t2, $t1, for_exit_4				#if(i>=k) then goto else part
		mul $t4, $t2, 4							#t4 = t2*4 => t4 = i*4
		subu $t3, $fp, $t4						#t3 = fp-t4 => t3 = &a[i]
		lw $s1, -12($t3)
		bge $s1, $t5, if_fail_3					#if(a[i]>=min)then goto else part

if_cond_3:
		lw $t5, -12($t3)						#if(a[i]<min) then min = a[i]
		add $t2, $t2, 1							#i = i+1
		b for_loop_4							#goback to for loop 4

if_fail_3:
		add $t2, $t2, 1							# i= i+1
		b for_loop_4							#go back to for loop 4

for_exit_4:
		#Making syscall for printing "The k-th largest number (k="
		la $a0, out3
		li $v0, 4
		syscall
		
		#Making syscall for printing the value of k
		move $a0, $t1
		li $v0, 1
		syscall
		
		#Making syscall for printing ") among given numbers is: "
		la $a0, out6
		li $v0, 4
		syscall
		
		#Making syscall for printing the value of min in the a array i.e kth largest number 
		move $a0, $t5							#a0 = min;
		li $v0, 1
		syscall

		#Syscall to print new line char
		la $a0, out4
		li $v0, 4
		syscall
		
		
		# Syscall for exit
		li $v0, 10
		syscall
		
if_fail_4:					#if_fail_4 is called in case k>n i.e. invalid input
	
		la $a0, out7
		li $v0, 4
		syscall
		
		li $v0, 10
		syscall

		# The data part consists of the string literals that are to be printed to the standard input.
		.data
out1: .asciiz	 "Enter the value of k: "
out2: .asciiz    "Enter the count of elements to be read: "
out3: .asciiz    "The k-th largest number (k = "
out6: .asciiz 	 ") among given numbers is: "
out4: .asciiz    "\n"
out5: .asciiz	 "Enter a number: "
out7: .asciiz  	 "Error: k cannot be greater than n"

# end of KthLargestNumber.asm