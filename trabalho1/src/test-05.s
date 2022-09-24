.globl _start
.section .text
_start:
mv a0, zero
sw a0, -32(s0)
mv a2, a0
addi s0, sp, 48
add a0, a1, a0
sw a0, -32(s0)
sw s0, 72(sp)
addi sp, sp, 48
addi s0, sp, 48
sw a2, -44(s0)
lb a2, 0(a0)
sw a1, -68(s0)
xori a0, t2, 34
andi a1, a1, -4
slli a0, a0, 2
