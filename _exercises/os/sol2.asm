.data
input:
	.string "Please input your name below "
welcome:
	.string "Welcome "
error_msg:
	.string "Input error"
user:
	.space 10

.text
main:
	la a0, input
	la a1, user
	# a1: address of username array
	li a2, 10
	li a7, 54
	ecall  # InputDialogString (read username)
	# a1: status value
	# with the bnez we check whether the status value was 0 (OK) or not: if not, we jump to the error handler
	bnez a1, error
	# if we get here (we did not jump away), we know that the status was OK, we don't need to worry about it anymore
	la a0, welcome
	la a1, user
	# a1: address of username array (again)
	li a7, 59
	ecall  # MessageDialogString (show welcome message)
	b exit
error:  
     la a0, error_msg
     li a1, 0
     li a7, 55
     ecall
exit:   
	li a7, 10
     ecall
