.globl _start
.section .text
_start:
lui a5, 12
mc404:
sw a2, -40(s0)
mv a2, a0
sw a1, -68(s0)
sw ra, 76(sp)
jal _start
sh a0, -28(s0)
lw t0, -24(s0)
rocks:
csrrwi a0, 6, 12
sw a1, -16(s0)
two:
lh a5, -20(s0)
sh a0, -24(s0)
csrrw a4, 7, a2
