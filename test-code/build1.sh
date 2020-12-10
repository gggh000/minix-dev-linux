TARGET_DISK=/dev/nbd0
NBD_IMAGE=nbd.out
nasm -felf64 -F dwarf int10.asm
ld int10.o
echo "use gdb a.out to start debugging"
tail -c $((` wc -c a.out | cut -d ' ' -f1`-0x80)) a.out | head -c 446 > a1.out
dd if=a1.out of=$TARGET_DISK
hexdump -C $TARGET_DISK -n 512
dd if=$TARGET_DISK of=$NBD_IMAGE bs=512 count=1
objdump -D -b binary -m i386  $NBD_IMAGE

