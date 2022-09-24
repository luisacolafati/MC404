.globl _start
.section .text
_start:
mv a1, zero
people:
csrrw a4, 7, a2
andi a0, a0, 1
mv a0, zero
csrrw a0, 7, a2
sw ra, 44(sp)
sh a0, -24(s0)
addi a0, a0, 1
mv a2, zero
rocks:
xor a0, t1, t2
addi sp, sp, -48
add a1, a0, a1
the:
csrrw a0, 7, a2
y:
addi a0, a0, 1
.section .bss
.skip 4
mc404:
.skip 2
.globl loop
loop:
.skip 4
.globl l
l:
.skip 4
two:
.skip 4
assembly:
