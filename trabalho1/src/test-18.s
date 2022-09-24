.globl _start
.section .text
_start:
addi sp, sp, 48
mv a0, zero
addi a0, a0, 1
addi a0, zero, 9
slli a1, a0, 2
sb a0, -12(s0)
lw t0, -24(s0)
srli a2, a1, 31
of:
lbu a0, -12(s0)
lb a0, 0(a0)
slli a2, a2, 2
are:
lh a5, -20(s0)
lui a0, 4098
.section .bss
.skip 3
.globl types
types:
.skip 3
.globl there
there:
.skip 1
.globl monitor
monitor:
.skip 3
.globl z
z:
.skip 5
loop:
