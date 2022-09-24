.globl _start
.section .text
_start:
lui a5, 12
jal _start
sw a0, -40(s0)
lh a0, -20(s0)
mv a2, zero
addi a0, zero, 9
lhu a4, -16(s0)
addi a0, a0, -1
bne a0, a1, _start
addi a0, a0, -1
.section .data
.skip 2
then:
.skip 1
types:
.skip 3
.globl of
of:
.skip 5
in:
