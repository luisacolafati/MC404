.globl _start
.section .text
_start:
slli a1, a1, 1
sh a0, -24(s0)
loop:
csrrw a4, 7, a2
lhu a4, -16(s0)
lh a5, -20(s0)
sw a0, -40(s0)
slli a1, a1, 2
then:
sh a0, -24(s0)
csrrw a4, 7, a2
sw a1, -68(s0)
bne a0, a1, _start
lh a0, -20(s0)
mc404:
lui a5, 12
addi a0, s0, -64
discovery:
sw a0, -44(s0)
.section .data
.skip 1
.globl fi
fi:
.skip 1
of:
.skip 1
are:
.skip 3
.globl y
y:
.skip 5
m:
