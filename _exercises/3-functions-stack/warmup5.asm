.globl main

# We use the program stack which is already set up for us.
# Thus, we don't need the data variable we called stack anymore.
# We can just use the stack pointer.
.text
main:
    # load the stack pointer
    # sp already points to the stack! Nothing to do.

    # load the integers
    li t1, 4
    li t2, 5

    # store the integers
    # WARNING! We are using the stack pointer here!
    # This means that we need to make space on the stack
    #  BEFORE we store the integers.
    addi sp, sp, -8 # Stack grows downwards
    sw t1, 0(sp)
    sw t2, 4(sp)

    # load the integers again
    lw t1, 0(sp)
    addi sp, sp, 4 # Stack grows downwards and we move it after we loaded the integers
    lw t2, 0(sp)
    addi sp, sp, 4
