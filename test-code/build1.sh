nasm -felf64 -F dwarf int10.asm
ld int10.o
echo "use gdb a.out to start debugging"
tail -c $((` wc -c a.out | cut -d ' ' -f1`-0x80)) a.out | head -c 446 > a1.out
dd if=a1.out of=/dev/sdb
hexdump -C /dev/sdb -n 512
objdump -D -b binary -m i386 a1.out
