.globl _start
.section .text
_start:
lhu a0, -16(s0)
l:
slli a2, a2, 2
the:
lb a0, 0(a0)
world:
sw s0, 72(sp)
slt a0, a0, a1
add a0, a0, a1
csrrw a4, 7, a2
sb a0, -12(s0)
in:
mv a2, zero
sh a0, -24(s0)
lb a2, 0(a0)
sw a0, -40(s0)
addi s0, sp, 80
.section .data
.skip 5
of:
.skip 1
k:
.skip 3
magic:
.skip 2
y:
.skip 1
unicamp:
