.equ discovery, 27
.globl _start
.section .text
_start:
slli a2, a2, 2
bne a0, a1, _start
sw a0, -32(s0)
call _start
jal _start
slli a1, a1, 2
mv a1, zero
mv a2, zero
sw s0, 72(sp)
addi s0, sp, 80
addi a0, s0, -64
