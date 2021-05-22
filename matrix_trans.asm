	.text
	.globl main

main:
		move $fp, $sp
		sub $sp, $sp, 24

		la $a0, promptEnter
		li $v0, 4
		syscall

		li $v0, 5
		syscall
		sw $v0, ($fp)

		syscall
		sw $v0, -4($fp)

		syscall
		sw $v0, -8($fp)

		lw $a0, ($fp)
		li $v0, 1
		syscall

		la $a0, newline
		li $v0, 4
		syscall

		lw $a0, ($fp)
		li $v0, 1
		syscall

		la $a0, newline
		li $v0, 4
		syscall

		lw $a0, ($fp)
		li $v0, 1
		syscall

		la $a0, newline
		li $v0, 4
		syscall


		.data

promtEnter: .asciiz "Enter three positive integers m, n, s: "
newline: .asiiz "\n"