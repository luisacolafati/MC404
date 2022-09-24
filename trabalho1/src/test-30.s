.globl _start
.section .text
_start:
sh a0, -28(s0)
addi s0, sp, 80
xor a0, t1, t2
auipc a0, 123
sw a2, -40(s0)
addi sp, sp, 80
lh a5, -20(s0)
andi a0, a0, 1
lh a5, -20(s0)
sw a0, -32(s0)
addi sp, sp, 80
sw a2, -44(s0)
sw a2, -16(s0)
IC:
lh a5, -20(s0)
