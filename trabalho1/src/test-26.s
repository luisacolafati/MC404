.globl _start
.section .text
_start:
addi sp, sp, 80
sw a2, -40(s0)
sw a2, -16(s0)
lhu a0, -16(s0)
slli a0, a0, 2
slli a0, a0, 2
lui a0, 4098
lh a5, -20(s0)
addi sp, sp, -80
lui a0, 4098
xor a0, t1, t2
lh a0, -20(s0)
lb a0, 0(a0)
auipc a0, 123
addi s0, sp, 48
.section .bss
.skip 4
.globl z
z:
.skip 5
.globl world
world:
.skip 5
.globl m
m:
.skip 5
x:
