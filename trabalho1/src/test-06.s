.globl _start
.section .text
_start:
xor a0, t1, t2
sb a0, 0(a1)
addi a0, a0, 1
ret
xori a0, t2, 34
sh a0, -24(s0)
sb a0, 0(a1)
add a0, a1, a0
addi s0, sp, 48
sw ra, 44(sp)
