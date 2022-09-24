.equ IC, 35
.equ mc404, 58
.equ magic, 26
.globl _start
.section .text
_start:
lui a0, 4098
slli a0, a0, 2
mv a1, zero
slt a0, a3, t2
andi a1, a1, -4
addi s0, sp, 80
mv a1, zero
sw s0, 40(sp)
slli a2, a2, 2
ret
andi a1, a1, -4
sw a2, -40(s0)
addi sp, sp, -48
sb a0, 0(a1)
sw a2, -16(s0)
.section .data
.skip 3
m:
.skip 2
k:
.skip 3
.globl of
of:
