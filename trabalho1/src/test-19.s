.equ assembly, 22
.equ loop, 93
.equ in, 79
.globl _start
.section .text
_start:
lhu a4, -16(s0)
lbu a2, -12(s0)
monitor:
lhu a0, -16(s0)
magic:
xor a0, t1, t2
there:
lui a5, 12
m:
addi sp, sp, 48
l:
addi a0, a0, 1
sh a0, -24(s0)
slli a1, a1, 1
addi sp, sp, -48
mv a2, zero
lb a0, 0(a0)
andi a1, a1, -4
slli a1, a1, 1
.section .data
.skip 3
IC:
.skip 3
.globl then
then:
.skip 3
two:
.skip 1
.globl fi
fi:
.skip 1
discovery:
