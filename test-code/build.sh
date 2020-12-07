nasm -felf64 -F dwarf hello.asm
gcc -c file.c
ld hello.o file.o && ./a.out
echo "use gdb a.out to start debugging"
