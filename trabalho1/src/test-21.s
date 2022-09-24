.equ k, 92
.equ mc404, 18
.equ of, 22
.globl _start
.section .text
_start:
lw t0, -24(s0)
types:
lw a0, -24(s0)
sw ra, 76(sp)
lb a2, 0(a0)
ret
add a0, a0, a1
lui a0, 4098
sw ra, 44(sp)
lb a0, 0(a0)
add a1, a1, a2
add a0, a1, a0
.section .data
.skip 5
there:
.skip 1
unicamp:
.skip 3
the:
