.globl _start
.section .text
_start:
addi a0, a0, 1
sh a0, -28(s0)
lhu a0, -16(s0)
mv a2, zero
sw a0, -40(s0)
sw a1, -68(s0)
auipc a0, 123
addi a0, zero, 9
sh a0, -28(s0)
addi sp, sp, -80
call _start
addi s0, sp, 80
sw a1, -68(s0)
lb a0, 0(a0)
