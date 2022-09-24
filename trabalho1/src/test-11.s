.globl _start
.section .text
_start:
sw s0, 72(sp)
lb a2, 0(a0)
sw a0, -36(s0)
xor a0, t1, t2
slli a1, a1, 2
beq a1, a2, _start
addi sp, sp, 80
jal _start
mv a1, zero
addi sp, sp, -80
.section .data
.skip 3
.globl k
k:
.skip 4
.globl types
types:
.skip 2
discovery:
.section .bss
.skip 2
m:
.skip 3
.globl two
two:
.skip 5
rocks:
.skip 5
unicamp:
.skip 3
.globl magic
magic:
