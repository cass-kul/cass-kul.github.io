.globl main
.data
    stack: .space 500

.text
main:
	# load the stack pointer
	la t0, stack

	# load the integers
	li t1, 4
	li t2, 5

	# store the integers
	sw t1, 0(t0)
	sw t2, 4(t0)
	addi t0, t0, 8

	# load the integers again
	addi t0, t0, -4
	lw t2, 0(t0)
	addi t0, t0, -4
	lw t1, 0(t0)
	
	# Look at the code above:
	# First, we stored with different offsets into t0
	#  and incremented it by 8 (2x4).
	# But then when we loaded the integers, we decremented
	#  t0 by 4 twice and loaded without offset.
	# Both approaches are equivalent! You can use either 
	#  to achieve the same result!
