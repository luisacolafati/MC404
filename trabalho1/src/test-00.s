.equ world, 16
.equ then, 36
.globl _start
.section .text
_start:
call _start
lb a2, 0(a0)
addi sp, sp, -80
slli a2, a2, 2
slli a1, a0, 2
xori a0, t2, 34
sw a0, -32(s0)
andi a0, a0, 1
addi s0, sp, 80
csrrwi a5, 6, 12
mc404:
slli a1, a1, 1
z:
lhu a0, -16(s0)
