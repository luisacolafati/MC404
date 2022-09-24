.globl _start
.section .text
_start:
slt a0, a3, t2
add a0, a0, a1
mv a0, zero
lui a5, 12
csrrwi a5, 6, 12
andi a0, a0, 1
sw a1, -20(s0)
lb a0, 0(a0)
slli a2, a2, 2
lhu a4, -16(s0)
sw s0, 40(sp)
people:
slli a1, a0, 2
slt a0, a3, t2
sb a0, -12(s0)
.section .bss
.skip 3
.globl fi
fi:
.skip 4
.globl the
the:
.skip 4
.globl are
are:
