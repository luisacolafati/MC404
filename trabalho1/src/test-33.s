.equ are, 73
.globl _start
.section .text
_start:
slli a1, a1, 2
lui a5, 12
slli a1, a1, 1
mv a2, a0
then:
csrrwi a0, 6, 12
addi sp, sp, 80
lbu a0, -12(s0)
sw a2, -20(s0)
sw s0, 40(sp)
xori a0, t2, 34
sh a0, -28(s0)
csrrw a4, 7, a2
lh a0, -20(s0)
