.data
    result:	.space 8
    i:		.dword 6

.text
.globl main
func:
    addi	sp,sp,-48
    sw	s0,44(sp)
    addi	s0,sp,48
    sw	a0,-20(s0)
    sw	a1,-24(s0)
    sw	a2,-32(s0)
    sw	a3,-28(s0)
    sw	a4,-40(s0)
    sw	a5,-36(s0)
    sw	a6,-48(s0)
    sw	a7,-44(s0)
    lw	a4,-20(s0)
    lw	a5,-24(s0)
    add	a5,a4,a5
    mv	t1,a5
    srai	a5,a5,0x1f
    mv	t2,a5
    lw	a2,-32(s0)
    lw	a3,-28(s0)
    add	a4,t1,a2
    mv	a1,a4
    sltu	a1,a1,t1
    add	a5,t2,a3
    add	a3,a1,a5
    mv	a5,a3
    mv	a2,a4
    mv	a3,a5
    lw	a0,-40(s0)
    lw	a1,-36(s0)
    add	a4,a2,a0
    mv	a6,a4
    sltu	a6,a6,a2
    add	a5,a3,a1
    add	a3,a6,a5
    mv	a5,a3
    mv	a2,a4
    mv	a3,a5
    lw	a0,-48(s0)
    lw	a1,-44(s0)
    add	a4,a2,a0
    mv	a6,a4
    sltu	a6,a6,a2
    add	a5,a3,a1
    add	a3,a6,a5
    mv	a5,a3
    mv	a2,a4
    mv	a3,a5
    lw	a5,0(s0)
    lw	a0,0(a5)
    lw	a1,4(a5)
    add	a4,a2,a0
    mv	a6,a4
    sltu	a6,a6,a2
    add	a5,a3,a1
    add	a3,a6,a5
    mv	a5,a3
    mv	a0,a4
    mv	a1,a5
    lw	s0,44(sp)
    addi	sp,sp,48
    ret

main:
    # TODO
