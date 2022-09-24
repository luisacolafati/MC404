.globl _start
.section .text
_start:
sw a1, -68(s0)
assembly:
mv a0, zero
rocks:
sw a1, -68(s0)
unicamp:
lh a0, -20(s0)
slli a1, a1, 2
sw ra, 44(sp)
add a0, a0, a1
IC:
mv a2, zero
add a1, a0, a1
slli a1, a1, 1
.section .data
.skip 1
are:
.skip 5
z:
.skip 1
.globl fi
fi:
