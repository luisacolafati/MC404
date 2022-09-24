.equ of, 78
.globl _start
.section .text
_start:
addi s0, sp, 48
lui a0, 4098
andi a1, a1, -4
sw ra, 76(sp)
slli a2, a2, 2
l:
sw a2, -40(s0)
sw a0, -32(s0)
sb a0, -12(s0)
addi sp, sp, 80
the:
sw ra, 76(sp)
