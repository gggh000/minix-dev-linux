./clear.sh
clear
TARGET_DISK_LOC=/var/lib/libvirt/images/
TARGET_DISK=/dev/nbd0
TARGET_DISK_VDI=/var/lib/libvirt/images/minix-boot-1.qcow2

#	For use with virtual box

TARGET_DISK_VDI=/var/lib/libvirt/images/minix-boot-1.vdi
NBD_IMAGE=nbd.out

echo "Convering vdi image to raw format..."
qemu-img convert -f vdi -O raw $TARGET_DISK_VDI $TARGET_DISK

nasm -felf64 -F dwarf int10.asm
ld int10.o
echo "use gdb a.out to start debugging"
tail -c $((` wc -c a.out | cut -d ' ' -f1`-0xb0)) a.out | head -c 446 > a1.out
dd if=a1.out of=$TARGET_DISK bs=1 count=446 conv=notrunc
hexdump -C $TARGET_DISK -n 512
dd if=$TARGET_DISK of=$NBD_IMAGE bs=512 count=1
#objdump -D -b binary -m i386  $NBD_IMAGE

echo "Convering raw image to vdi format compatible with virtualbox."
qemu-img convert -f raw -O vdi $TARGET_DISK $TARGET_DISK_VDI
ls -l $TARGET_DISK_LOC

