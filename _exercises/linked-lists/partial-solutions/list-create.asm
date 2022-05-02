.eqv OK 1
.eqv UNINITIALIZED_LIST -1
.eqv OUT_OF_MEMORY -2
.eqv INDEX_OUT_OF_BOUNDS -3
.eqv UNINITIALIZED_RETVAL -4

.text
.globl list_create
list_create:
	# Back up ra on stack
	addi sp, sp, -4
	sw ra, (sp)

	# Malloc 1 word
	li a0, 1
	jal malloc

	# Check whether maloc failed
	bnez a0, end

	# Malloc failed (it is zero). Return out of memory.
	li a0, OUT_OF_MEMORY

end: 
	# Restore ra and return
	lw ra, (sp)
	addi sp, sp, 4
	ret
