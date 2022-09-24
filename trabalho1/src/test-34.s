.globl _start
.section .text
_start:
slli a1, a1, 2
sw a0, -36(s0)
sw ra, 76(sp)
andi a1, a1, -4
addi sp, sp, -48
addi a2, zero, 9
mv a1, zero
slt a0, a3, t2
sw a0, -44(s0)
sw a2, -40(s0)
srli a2, a1, 31
srli a2, a1, 31
addi s0, sp, 48
andi a1, a1, -4
.section .data
.skip 1
.globl magic
magic:
.skip 4
.globl monitor
monitor:
.skip 5
are:
.skip 2
.globl z
z:
.skip 5
IC:
