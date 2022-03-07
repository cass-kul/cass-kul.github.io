.data
    string: .asciz "hello world"
.text
    la t0, string        # t0 = address of the string
    addi a0, zero, -1    # a0 = character count, initially -1
count:
    lbu t1, (t0)         # t1: current character
    addi a0, a0, 1       # increase character count
    addi t0, t0, 1       # increase pointer
    bnez t1, count       # if current character is not \0, repeat
end:
