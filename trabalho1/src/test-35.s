.equ there, 35
.equ IC, 37
.equ x, 95
.globl _start
.section .text
_start:
sw s0, 72(sp)
addi a0, a0, 1
add a1, a1, a2
addi s0, sp, 80
addi a0, a0, 1
xori a0, t2, 34
lw a0, -24(s0)
bne a0, a1, _start
add a1, a1, a2
sw a1, -20(s0)
sw ra, 44(sp)
csrrwi a5, 6, 12
.section .data
.skip 4
magic:
.skip 4
loop:
.skip 4
z:
.skip 1
mc404:
.section .bss
.skip 4
.globl assembly
assembly:
.skip 2
rocks:
.skip 5
monitor:
.skip 3
then:
