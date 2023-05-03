.globl main
.data
    heap: .space 1000000

.text
allocate_space:
    mv t0, a0
    mv a0, s9
    add s9, s9, t0
    ret

stack_create:   #TODO

stack_push:     #TODO

stack_pop:      #TODO

main:
    la s9, heap

    # Test code
    jal stack_create    # Create stack -> top pointer in a0

    addi sp, sp, -4
    sw a0, (sp)	        # Push top pointer on call stack

    # Push 1 to stack
    li a1, 1
    jal stack_push

    # Push 2 to stack
    lw a0, (sp)
    li a1, 2
    jal stack_push

    # Push 3 to stack
    lw a0, (sp)
    li a1, 3
    jal stack_push

    # Verify the state of the stack using the single step function!
    # It should look like the picture below.

    # Pop 3 from stack
    lw a0, (sp)
    jal stack_pop

    # Pop 2 from stack
    lw a0, (sp)
    jal stack_pop

    # Verify that a0 equals 2 now
    # Verify that the stack top now points to the value 1
    addi sp, sp, 4
