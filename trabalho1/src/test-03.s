.globl _start
.section .text
_start:
add a1, a0, a1
lhu a4, -16(s0)
rocks:
lbu a2, -12(s0)
addi s0, sp, 48
monitor:
addi a0, zero, 9
addi a2, zero, 9
ret
sw a2, -16(s0)
csrrwi a0, 6, 12
mc404:
sw a1, -16(s0)
sw ra, 44(sp)
sw a0, -40(s0)
sw a0, -40(s0)
lhu a0, -16(s0)
