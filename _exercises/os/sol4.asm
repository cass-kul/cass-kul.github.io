.globl main
.data
	
	trapframe: .space 8		#Mini-trapframe that stores a0 - a7 during trap handler execution 
	print_str_1: .string "Exception with cause "
	print_str_2: .string " occured at address "

.text
handler:
	csrrw zero, uscratch, t0	#back-up value of t0 in uscratch
	la t0, trapframe		#Back up values a0 and a7 to our small trapframe
	sw a0, (t0)
	sw a7, 4(t0)
	
	la a0, print_str_1		#Print first string
	li a7, 4
	ecall
	
	csrrw a0, ucause, zero  	#Print exception cause
	li a7, 1 
	ecall
	
	la a0, print_str_2		#Print second string
	li a7, 4
	ecall
	
	csrrw a0, uepc, zero	#Print exception address as hexadecimal
	li a7, 34 
	ecall
	
	addi a0, a0, 4			#add 4 to uepc to skip faulting instruction
	csrrw zero, uepc, a0	#Move skip address to uepc
	
	lw a0, (t0)			#Restore a0 and a7 from trapframe
	lw a7, 4(t0)
	csrrw t0, uscratch, zero #Restore old t0 value
	uret
main:
	csrrsi zero, ustatus, 1 # set interrupt enable (only needed in RARS)
 	la t0, handler
 	csrrw zero, utvec, t0  # set utvec to address of custom exception handler
 	lw t0, 1          	   # trigger trap
 	li a7, 10		   
 	ecall		   	   # exit (0)
