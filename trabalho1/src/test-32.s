.globl _start
.section .text
_start:
sw a2, -20(s0)
sb a0, 0(a1)
sb a0, -12(s0)
unicamp:
lbu a0, -12(s0)
csrrwi a5, 6, 12
addi sp, sp, -80
mv a2, zero
discovery:
csrrwi a5, 6, 12
sh a0, -28(s0)
y:
sb a0, 0(a1)
sh a0, -24(s0)
sh a0, -28(s0)
