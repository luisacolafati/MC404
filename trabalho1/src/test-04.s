.globl _start
.section .text
_start:
sw ra, 76(sp)
sw ra, 44(sp)
addi sp, sp, -48
beq a1, a2, _start
sw a1, -16(s0)
lb a2, 0(a0)
addi a0, zero, 9
slli a2, a2, 2
slti a0, a1, 12
sw a0, -32(s0)
.section .data
.skip 5
.globl in
in:
.skip 4
monitor:
.skip 2
then:
.skip 2
loop:
.section .bss
.skip 5
k:
.skip 3
fi:
.skip 1
.globl of
of:
.skip 4
.globl mc404
mc404:
.skip 5
x:
