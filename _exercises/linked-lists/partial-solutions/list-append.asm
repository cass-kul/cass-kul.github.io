.eqv OK 1
.eqv UNINITIALIZED_LIST -1
.eqv OUT_OF_MEMORY -2
.eqv INDEX_OUT_OF_BOUNDS -3
.eqv UNINITIALIZED_RETVAL -4

.text
.globl list_append
list_append:
	# Store RA, a0 and a1 on the stack
	addi sp, sp, -12
	sw ra, 0(sp)
	sw a0, 4(sp)
	sw a1, 8(sp)
	
	# Malloc 2 words
	li a0, 2
	jal malloc
	
	# Abort if malloc failed
	beqz a0, oom
	
	# Store int in list item
	lw t0, 8(sp)
	sw t0, (a0)
	# Make sure new item points to null
	sw zero, 4(a0)
	
	# Check whether list is empty
	lw t0, 4(sp)
	beqz t0, uninit_list
	# Check whether first list item exists
	lw t1, (t0)
	beqz t1, list_zero

	# First is not empty
	# proceed to first list item and start looping
	mv t0, t1
	
find_end: 
	# find item that points to null (last item in list)
	lw t1, 4(t0) # load next item
	beqz t1, end_loop # end loop if it points to null
	mv t0, t1 # otherwise, move to next item
	j find_end

end_loop: # t0 has end
	# store pointer to item at end of list
	sw a0, 4(t0) # store pointer to new item
	j ok
	
list_zero: 
	#list is empty, store pointer to new item in head pointer
	sw a0, (t0)
	j ok
	
	
oom:
	# Malloc failed, just return out of mem error.
	li a0, OUT_OF_MEMORY
	j end
	
uninit_list:
	# Our list is not initialized.
	# In a0 we still have the previously malloc'ed pointer.
	# Free that memory and return uninitialized list error.
	jal free
	li a0, UNINITIALIZED_LIST
	j end

ok:	li a0, OK 

end:
	# Restore RA from stack
	lw ra, (sp)
	addi sp, sp, 12
	ret
