.equ magic, 24
.globl _start
.section .text
_start:
mv a0, zero
srli a2, a1, 31
addi sp, sp, 80
lui a5, 12
addi a0, a0, 1
addi a0, a0, -1
mv a0, zero
sw a1, -20(s0)
addi sp, sp, 80
addi sp, sp, 48
lh a5, -20(s0)
sw a2, -44(s0)
lui a5, 12
.section .data
.skip 3
.globl assembly
assembly:
.skip 5
.globl are
are:
.skip 5
mc404:
.skip 4
.globl z
z:
