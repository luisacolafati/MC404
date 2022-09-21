	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p0_m2p0_a2p0_f2p0_d2p0"
	.file	"arquivo1.c"
	.globl	main
	.p2align	2
	.type	main,@function
main:
	addi	sp, sp, -32
	sw	ra, 28(sp)
	sw	s0, 24(sp)
	addi	s0, sp, 32
	mv	a0, zero
	sw	a0, -32(s0)
	sw	a0, -12(s0)
	addi	a0, zero, 10
	sh	a0, -16(s0)
	lui	a0, 136775
	addi	a0, a0, -910
	sw	a0, -20(s0)
	lui	a0, 456050
	addi	a0, a0, 111
	sw	a0, -24(s0)
	lui	a0, 444102
	addi	a0, a0, 1352
	sw	a0, -28(s0)
	addi	a0, zero, 1
	addi	a1, s0, -28
	addi	a2, zero, 13
	call	write
	lw	a0, -32(s0)
	lw	s0, 24(sp)
	lw	ra, 28(sp)
	addi	sp, sp, 32
	ret
.Lfunc_end0:
	.size	main, .Lfunc_end0-main

	.globl	_start
	.p2align	2
	.type	_start,@function
_start:
	addi	sp, sp, -16
	sw	ra, 12(sp)
	sw	s0, 8(sp)
	addi	s0, sp, 16
	call	main
	lw	s0, 8(sp)
	lw	ra, 12(sp)
	addi	sp, sp, 16
	ret
.Lfunc_end1:
	.size	_start, .Lfunc_end1-_start

	.type	.L__const.main.str,@object
	.section	.rodata.str1.1,"aMS",@progbits,1
.L__const.main.str:
	.asciz	"Hello World!\n"
	.size	.L__const.main.str, 14

	.ident	"Ubuntu clang version 12.0.0-3ubuntu1~20.04.5"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym main
	.addrsig_sym write
