.equ the, 83
.equ fi, 64
.globl _start
.section .text
_start:
lb a0, 0(a0)
call _start
slli a1, a0, 2
in:
xori a0, t2, 34
IC:
sw a0, -44(s0)
lw t0, -24(s0)
sw s0, 40(sp)
lbu a2, -12(s0)
csrrw a4, 7, a2
sw a1, -16(s0)
sw a0, -44(s0)
sw s0, 40(sp)
csrrw a4, 7, a2
.section .bss
.skip 5
.globl then
then:
.skip 4
discovery:
.skip 2
loop:
.skip 1
k:
.skip 1
y:
