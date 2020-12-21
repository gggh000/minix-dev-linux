./clear.sh
clear
CONFIG_BUILD_32=1
CONFIG_BUILD_64=2
CONFIG_BUILD_BIN=3
CONFIG_BUILD_OUTPUT_TYPE=$CONFIG_BUILD_BIN


TARGET_DISK_LOC=/var/lib/libvirt/images/
#TARGET_DISK=/dev/nbd0
TARGET_DISK=/var/lib/libvirt/images/minix-boot-1.qcow2

#	For use with virtual box

TARGET_DISK_VDI=/var/lib/libvirt/images/minix-boot-1.vdi
NBD_IMAGE=nbd.out

echo "Convering vdi image to raw format..."
qemu-img convert -f vdi -O raw $TARGET_DISK_VDI $TARGET_DISK

if [[ $CONFIG_BUILD_OUTPUT_TYPE -eq $CONFIG_BUID_32 ]] ; then
	echo "Building 32  bit binary..."
	nasm -f bin -F dwarf int10.asm
 	ld int10.o
elif [[ $CONFIG_BUILD_OUTPUT_TYPE  -eq $CONFIG_BUILD_BIN ]] ; then
	echo "Building raw binary..."
	nasm -f bin int10.asm
	mv int10 a1.out

elif [[ $CONFIG_BUILD_OUTPUT_TYPE  -eq $CONFIG_BUILD_64 ]] ; then
	echo "Building 64-bit binary..."
	nasm -felf64 -F dwarf int10.asm
	ld int10.o
	echo "use gdb a.out to start debugging"
	tail -c $((` wc -c a.out | cut -d ' ' -f1`-0xb0)) a.out | head -c 446 > a1.out
else
	echo "Invalid build specified."
fi
dd if=a1.out of=$TARGET_DISK bs=1 count=446 conv=notrunc
hexdump -C $TARGET_DISK -n 512
dd if=$TARGET_DISK of=$NBD_IMAGE bs=512 count=1
objdump -D -b binary -m i386  a1.out | head -32

echo "Convering raw image to vdi format compatible with virtualbox."
qemu-img convert -f raw -O vdi $TARGET_DISK $TARGET_DISK_VDI
ls -l $TARGET_DISK_LOC

