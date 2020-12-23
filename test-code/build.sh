nasm -felf64 -F dwarf test1-a.asm
gcc -c test1-c.c
ld test1-a.o test1-c.o -o test.out
