desmontador.s: desmontador.c
	clang-12 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax desmontador.c -S -o desmontador.s

desmontador.o: desmontador.s
	clang-12 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax desmontador.s -c -o desmontador.o

desmontador.x: desmontador.o
	ld.lld-12 desmontador.o -o desmontador.x