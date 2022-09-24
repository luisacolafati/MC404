.equ y, 23
.equ l, 45
.globl _start
.section .text
_start:
mv a2, a0
addi a2, zero, 9
sw s0, 72(sp)
lb a2, 0(a0)
IC:
sw a1, -20(s0)
sw a0, -32(s0)
xori a0, t2, 34
lw t0, -24(s0)
sw a2, -44(s0)
sb a0, 0(a1)
k:
slt a0, a0, a1
lbu a2, -12(s0)
sw a2, -16(s0)
.section .data
.skip 1
discovery:
.skip 2
.globl types
types:
.skip 2
.globl in
in:
