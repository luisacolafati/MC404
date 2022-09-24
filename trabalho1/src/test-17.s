.globl _start
.section .text
_start:
slli a0, a0, 2
sw ra, 44(sp)
sw a0, -32(s0)
lhu a0, -16(s0)
slti a0, a1, 12
srli a2, a1, 31
mv a2, a0
slli a2, a2, 2
auipc a0, 123
addi a0, a0, -1
sw a1, -68(s0)
assembly:
ret
.section .bss
.skip 5
.globl loop
loop:
.skip 1
y:
.skip 4
.globl there
there:
