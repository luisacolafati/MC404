.globl _start
.section .text
_start:
csrrw a0, 7, a2
lhu a4, -16(s0)
lhu a0, -16(s0)
andi a0, a0, 1
lbu a0, -12(s0)
lb a2, 0(a0)
csrrwi a0, 6, 12
of:
sw a2, -40(s0)
in:
csrrw a4, 7, a2
lhu a0, -16(s0)
lhu a4, -16(s0)
lb a0, 0(a0)
.section .data
.skip 5
l:
.skip 3
fi:
.skip 1
.globl the
the:
