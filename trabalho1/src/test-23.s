.globl _start
.section .text
_start:
sw s0, 40(sp)
sw s0, 40(sp)
ret
andi a0, a0, 1
srli a2, a1, 31
slli a1, a0, 2
sb a0, 0(a1)
addi a0, s0, -64
csrrw a4, 7, a2
mv a1, zero
.section .data
.skip 5
.globl in
in:
.skip 2
assembly:
.skip 4
fi:
