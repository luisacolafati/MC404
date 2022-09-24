.globl _start
.section .text
_start:
lhu a0, -16(s0)
sw a1, -20(s0)
IC:
sh a0, -24(s0)
lw a0, -24(s0)
sw ra, 76(sp)
csrrw a4, 7, a2
sw a1, -16(s0)
add a1, a1, a2
of:
lh a5, -20(s0)
mv a1, zero
add a0, a1, a0
srli a2, a1, 31
lbu a2, -12(s0)
sw a0, -36(s0)
.section .bss
.skip 4
world:
.skip 5
fi:
.skip 4
.globl people
people:
