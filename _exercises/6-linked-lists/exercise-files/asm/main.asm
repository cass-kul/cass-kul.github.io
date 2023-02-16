.text
.globl main
main:
	# Write your own testing code here

	jal run_test_suite
	li a7, 10
	ecall
