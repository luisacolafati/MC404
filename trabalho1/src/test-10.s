.globl _start
.section .text
_start:
slli a1, a0, 2
bne a0, a1, _start
sw ra, 44(sp)
are:
lbu a2, -12(s0)
lbu a2, -12(s0)
sb a0, -12(s0)
add a1, a1, a2
call _start
mc404:
slt a0, a0, a1
sw a0, -36(s0)
sw a2, -44(s0)
slt a0, a3, t2
.section .data
.skip 1
magic:
.skip 4
monitor:
.skip 4
IC:
.skip 1
there:
.skip 4
l:
