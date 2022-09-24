.equ x, 56
.equ rocks, 40
.equ are, 36
.globl _start
.section .text
_start:
sw a2, -16(s0)
mv a1, zero
add a1, a0, a1
slt a0, a3, t2
sw a0, -32(s0)
lb a2, 0(a0)
the:
slli a1, a0, 2
addi a0, s0, -64
sw a1, -20(s0)
IC:
sw a0, -40(s0)
sw a2, -44(s0)
addi sp, sp, -80
lui a5, 12
.section .data
.skip 3
.globl z
z:
.skip 3
of:
.skip 4
l:
.skip 5
.globl y
y:
.skip 2
unicamp:
.section .bss
.skip 1
.globl mc404
mc404:
.skip 5
.globl assembly
assembly:
.skip 5
there:
.skip 5
.globl monitor
monitor:
