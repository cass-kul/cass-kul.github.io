.data
next_free: .word 0
heap: .space 1000000


.globl main
.text

#a0: amount of words to allocate
#Allocation format:
# 4 bytes | 4 bytes | a0 words
# First 4 bytes store either 0 (if the chunk is allocated) or the address of the next free chunk
# (if the chunk is not allocated, thus part of a free list)
# Second 4 bytes store the size in bytes of the third region
# The third region is a0 words in size and contains the actually reserved memory

allocate:
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
	beqz t0, new_chunk		#If there is no free chunk, allocate a new one
	lw t1, 4(t0)		#If there is a free chunk, get the size of that chunk in t1
	mv t2, t0			#Copy the free chunk address (in case we will use the chunk)
	lw t0, 0(t0)		#Load the address of the next free chunk in t0 (in case current chunk is too small)
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
	sw zero, (s9)	#Store 0 in the first 4 bytes to denote the fact this chunk is allocated
	sw a0, 4(s9)	#Store the chunk size in the next 4 bytes
	addi s9, s9, 8 	#Move the s9 by 8 - the actual start of the newly reserved memory
	mv t0, a0		#Back-up the bytes to reserve in t0
	mv a0, s9		#Return the actual start of the newly reserved memory
	add s9, s9, t0 	#Reserve bytes by incrementing the s9
	ret


#Address of chunk to free in a0
#next_free always points to the chunk metadata, not the chunk data (chunk data addr = chunk metadata addr + 8)
free:
	lw t0, next_free 	#Address of the next free chunk in t0
	addi a0, a0, -8  	#Move to chunk metadata
	sw t0, (a0)	#Store address of next free chunk in this free chunk
	sw a0, next_free, t0 #Update next free to point to the newly freed chunk
	ret

main:
	la s9, heap
		
	li a0, 1		#Allocate 4 bytes
	jal allocate
	li t0, 123
	sw t0, (a0)	#Store 123 in newly allocated region
	
	jal free		#Free allocated 4 bytes
	
	li a0, 2
	jal allocate  #Allocate 8 bytes
	li t0, 234
	sw t0, (a0)   #Store 234 in newly allocated region
	
	jal free	    #Free allocated 8 bytes
	
	li a0, 1
	jal allocate #Allocate 4 bytes - should re-use 8 byte region that was just freed
	li t0, 345
	sw t0, (a0)  #Store 345 in the 8-byte region (even though 4 bytes were asked, we used a bigger chunk)

			
	li a0, 1	   #allocate 4 bytes
	jal allocate #Re-use first 4 bytes
	li t0, 456
	sw t0, (a0)
