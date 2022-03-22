.globl main
.text
handler:
	csrrw zero, uscratch, t0	#back-up value of t0 in uscratch
	csrrw t0, uepc, zero	#read uepc (address of faulting instruction) in t0
	addi t0, t0, 4			#add 4 to uepc to skip faulting instruction
	csrrw zero, uepc, t0	#Move skip address to uepc
	csrrw t0, uscratch, zero #Restore old t0 value
	uret
main:
	csrrsi zero, ustatus, 1 # set interrupt enable (only needed in RARS)
 	la t0, handler
 	csrrw zero, utvec, t0  # set utvec to address of custom exception handler
 	lw t0, 1          	   # trigger trap
 	li a7, 10		   
 	ecall		   	   # exit (0)
