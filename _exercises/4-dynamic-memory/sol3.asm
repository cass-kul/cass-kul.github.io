.globl main
.data
heap: .space 1000000

.text
allocate_space:
    	mv t0, a0
    	mv a0, s9
    	add s9, s9, t0
   	ret

stack_create:
	addi sp, sp, -4
	sw ra, (sp)
	li a0, 4
	jal allocate_space

	sw zero, (a0)		#Don't assume allocated memory is zero
				#For this simple allocator this is the case,
				#but more complex allocators might break this assumption

	lw ra, (sp)
	addi sp, sp, 4
	ret

#Stack push should replace top (in a0) with a new address
#The new element should point to the old top
stack_push:
	addi sp, sp, -12
	sw ra, (sp)
	sw a0, 4(sp)		#Back up the top address on the stack
	sw a1, 8(sp)		#Back up the value-to-push

	li a0, 8			#Allocate space for 2 words
	jal allocate_space              #New node address in a0

	lw t0, 4(sp)		#Address of top poiner in t0

	#Modify top
	lw t1, (t0)		#Load old top address in t1
	sw a0, (t0)		#Store new node address as new top value

	#Init node
	sw t1, 4(a0)		#Store old top address in new node pointer
	lw t1, 8(sp)		#Load value-to-push in t1
	sw t1, (a0)		#Store value-to-push in new node

	lw ra, (sp)
	addi sp, sp, 12
	ret

stack_pop:
	lw t0, (a0)		#t0 = address of first node on stack
	lw t1, 4(t0)		#t1 =  address of second node on stack
	sw t1, (a0)		#Adjust top pointer to point to second stack node
	lw a0, (t0)		#a0 = value of first node on stack
	ret

main:
    la s9, heap

  	#Test code
    jal stack_create    #Create stack -> top pointer in a0

    addi sp, sp, -4
    sw a0, (sp)	   #Push top pointer on call stack

    #Push 1 to stack
    li a1, 1
    jal stack_push

    #Push 2 to stack
    lw a0, (sp)
    li a1, 2
    jal stack_push

    #Push 3 to stack
    lw a0, (sp)
    li a1, 3
    jal stack_push

    #Verify the state of the stack using the single step function!
    #At this point, the top pointer should point to the value 3.
    #The next word in memory is a pointer to the value 2.
    #At that location, 2 is stored.
    #The next word in memory is then a pointer to the value 1.
    #The next word in memory after value 1 should be the value 0.

    #Pop 3 from stack
    lw a0, (sp)
    jal stack_pop

    #Pop 2 from stack
    lw a0, (sp)
    jal stack_pop

    #Verify that a0 equals 2 now
    #Verify that the stack top now points to the value 1
    addi sp, sp, 4
