.data
    string: .asciz "hello world"
    substring: .asciz "helo"
.globl main
.text
main:
    la t0, string
    la t6, substring
    li a0, 0
resetsub:
    mv t1, t6               # reset the substring (t1) to its start
loop:
    lbu t2, (t0)            # t2: next character of the string
    lbu t3, (t1)            # t3: next character of the substring
    bnez t3, nonzerosub
    li a0, 1                # we have reached the end of the substring: success!
    j end
nonzerosub:
    bne t2, t3, noneq       # if the two characters are not equal
    bne t2, zero, nonendstr # if we have not reached the end of the string
    li a0, 1                # we have reached the end of the string: success!
    j end
nonendstr:
    addi t1, t1, 1          # move both strings forward one character
    addi t0, t0, 1
    j loop
noneq:
    bne t1, t6, resetsub    # if we are not on the first character of the substring, reset
    beq t2, zero, end       # if we are at the end of the string, quit
    addi t0, t0, 1          # otherwise, move forward in the string
    j loop
end:
