.data
list_memory: .space 1000000
.globl main

.text
allocate_array:         # Assume s9 keeps track of next free memory location
    mv    a0, s9        # Return old value of s9 as a pointer to new list
    addi  s9, s9, 40    # Update the value of list pointer in s9
    ret

main:
    # Initialize the list pointer
    la s9, list_memory
    
    # Create List 1 and store its address in s0
    jal allocate_array
    mv s0, a0
    
    # Create List 2 and store its address in s1
    jal allocate_array
    mv s1, a0
    
    # Fill List 1 with [42, 21, 10, 1, 2, 55, 3, 1, 3]
    li t0, 42
    sw t0, 0(s0)  # s0[0]
    # [...]
    li t0, 3      # s0[8]
    sw t0, 32(s0)
    
    # Fill List 2 with [12, 4, 76]
    li t0, 12
    sw t0, 0(s1)
    # [...]
    li t0, 76
    sw t0, 8(s1)
    
    # Expand the list
    jal allocate_array
    sw a0, 36(s0)
    
    # Store last value 9 in List 1
    li t0, 9
    lw t1, 36(s0) # Load address of second lisk chunk
    sw t0, 0(t1)  # Store 9 at the beginning of second list chunk
