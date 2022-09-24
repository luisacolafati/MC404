.globl _start
.section .text
_start:
lw t0, -24(s0)
addi sp, sp, -80
addi a0, a0, -1
lbu a2, -12(s0)
sw a0, -32(s0)
mv a1, zero
lbu a2, -12(s0)
lhu a0, -16(s0)
ret
addi a2, zero, 9
slli a0, a0, 2
m:
sw a2, -16(s0)
.section .data
.skip 5
y:
.skip 1
mc404:
.skip 3
x:
.skip 5
k:
.skip 1
z:
.section .bss
.skip 3
then:
.skip 4
.globl magic
magic:
.skip 5
fi:
.skip 4
.globl two
two:
