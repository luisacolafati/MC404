.globl _start
.section .text
_start:
jal _start
slt a0, a3, t2
mv a0, zero
call _start
sw a1, -68(s0)
sw a2, -16(s0)
sw a2, -44(s0)
sw a1, -16(s0)
sw s0, 72(sp)
mv a0, zero
sw a0, -40(s0)
add a1, a0, a1
.section .data
.skip 1
.globl monitor
monitor:
.skip 5
rocks:
.skip 1
.globl unicamp
unicamp:
.skip 4
of:
.section .bss
.skip 5
are:
.skip 1
.globl mc404
mc404:
.skip 4
l:
.skip 5
.globl loop
loop:
.skip 5
.globl m
m:
