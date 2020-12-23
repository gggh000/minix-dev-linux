nasm -felf64 -F dwarf test.asm
gcc -c test.c
ld test.o test.o && ./a.out
echo "use gdb a.out to start debugging"
