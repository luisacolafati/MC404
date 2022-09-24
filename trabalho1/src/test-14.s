.equ l, 26
.equ then, 47
.globl _start
.section .text
_start:
sw s0, 40(sp)
fi:
lbu a2, -12(s0)
slli a2, a2, 2
sh a0, -24(s0)
sb a0, 0(a1)
sw s0, 72(sp)
rocks:
addi a0, zero, 9
loop:
addi sp, sp, 48
lb a2, 0(a0)
addi s0, sp, 80
lh a5, -20(s0)
sw ra, 76(sp)
jal _start
