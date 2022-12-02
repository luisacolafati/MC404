lab05.o: lab05.s
	clang-12 --target=riscv32 -march=rv32g -mabi=ilp32d -mno-relax lab05.s -c -o lab05.o

executavel.x: lab05.o
	ld.lld-12 lab05.o -o executavel.x