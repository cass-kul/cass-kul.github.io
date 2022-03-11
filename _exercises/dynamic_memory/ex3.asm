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
