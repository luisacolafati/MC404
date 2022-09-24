.globl _start
.section .text
_start:
addi a2, zero, 9
addi sp, sp, -80
rocks:
ret
addi a0, a0, 1
sw ra, 44(sp)
lb a0, 0(a0)
k:
sw a0, -36(s0)
lbu a0, -12(s0)
addi a2, zero, 9
addi a0, a0, -1
lh a0, -20(s0)
lh a0, -20(s0)
