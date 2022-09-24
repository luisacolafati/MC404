.globl _start
.section .text
_start:
addi sp, sp, -48
lw t0, -24(s0)
sw s0, 72(sp)
fi:
slli a2, a2, 2
add a1, a1, a2
mv a2, zero
sw a1, -16(s0)
slli a1, a0, 2
call _start
csrrwi a0, 6, 12
add a0, a1, a0
lhu a0, -16(s0)
