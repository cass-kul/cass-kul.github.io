.data
next_free: .word 0
.globl out_of_memory
out_of_memory: .word 0
.globl malloc
.globl free

.text
malloc:
	lw t0, out_of_memory
	beqz t0, .Lcont
	li a0, 0
	ret
.Lcont:
#First, we will go through the free chain to see if any previously freed chunk is big enough for our allocation
#We will take the strategy that any chunk that fits is good enough
#There are many different strategies to take here, each have advantages and disadvantages
	li t0, 4
	mul a0, a0, t0		#Convert words to bytes
	#The following loop will search through the free chunks until it finds one that fits the requested allocation size
	#If none fit, a new chunk is allocated
	lw t0, next_free
	la t3, next_free	
	j skip			
chunk_loop:
	mv t3, t2			
skip:
	beqz t0, new_chunk	#If there is no free chunk, allocate a new one
	lw t1, 4(t0)		#If there is a free chunk, get the size of that chunk in t1
	mv t2, t0			#Copy the free chunk address (in case we will use the chunk)
	lw t0, 0(t0)		#Load the address of the next free chunk in t0 (in case the current chunk is too small)
	blt t1, a0, chunk_loop	#Not enough space in the free chunk, find the next one by looping
	
	#If you get in this part of the code you have found a big enough chunk in the free list
	#The address of this chunk is in t2
	#Re-use this chunk by removing it from the free list
	#Make sure to restore the free list properly
	
	#t3 should now have the location where we need to store the address of the next chunk
	#t0 contains the address of the next chunk
	sw t0, (t3)
	
	#Return the actual chunk addr
	mv a0, t2
	#Don't point to the metadata
	addi a0, a0, 8
	ret
new_chunk:
	
	# sbrk(bytes + 8)
	addi a0, a0, 8 #Reserve 2 extra words (metadata)
	li a7, 9
	ecall
	
	# a0 has address of reserved memory
	addi a0, a0, 8 #Point to start of chunk
	ret

#Address of chunk to free in a0
#next_free always points to the chunk metadata, not the chunk data (chunk data addr = chunk metadata addr + 8)
free:
	lw t0, next_free #Address of the next free chunk in t0
	addi a0, a0, -8  #Move to chunk metadata
	sw t0, (a0)	  #Store address of next free chunk in this free chunk
	sw a0, next_free, t0 #Update next free to point to the newly freed chunk
	ret
