./clear.sh
clear
CONFIG_BUILD_32=1
CONFIG_BUILD_64=2
CONFIG_BUILD_BIN=3
CONFIG_BUILD_OUTPUT_TYPE=$CONFIG_BUILD_BIN
MBR_BOOT_ASM=mbrboot

TARGET_DISK_IMG_LOC=/var/lib/libvirt/images/
TARGET_DISK_IMG=/var/lib/libvirt/images/minix-boot-1.qcow2

#	For use with virtual box

TARGET_DISK_IMG_VDI=/var/lib/libvirt/images/minix-boot-1.vdi

# 	echo "Convering vdi image to raw format..."
#	qemu-img convert -f vdi -O raw $TARGET_DISK_IMG_VDI $TARGET_DISK_IMG

if [[ $CONFIG_BUILD_OUTPUT_TYPE -eq $CONFIG_BUID_32 ]] ; then
	echo "Building 32  bit binary..."
	nasm -f bin -F dwarf $MBR_BOOT_ASM.asm
 	ld $MBR_BOOT_ASM.o
elif [[ $CONFIG_BUILD_OUTPUT_TYPE  -eq $CONFIG_BUILD_BIN ]] ; then
	echo "Building raw binary..."
	nasm -f bin $MBR_BOOT_ASM.asm
elif [[ $CONFIG_BUILD_OUTPUT_TYPE  -eq $CONFIG_BUILD_64 ]] ; then
	echo "Building 64-bit binary..."
	nasm -felf64 -F dwarf $MBR_BOOT_ASM.asm
	ld $MBR_BOOT_ASM.o
	echo "use gdb a.out to start debugging"
	tail -c $((` wc -c a.out | cut -d ' ' -f1`-0xb0)) a.out | head -c 446 > a1.out
else
	echo "Invalid build specified."
fi

#	Disabling following code for now.

FLAG=0
if [[ $FLAG -eq - ]] ; then
	dd if=$TARGET_DISK_IMG of=ptable.bin skip=446 bs=1 count=$((512-446))
	echo "created ptable bin:"
	hexdump -C ptable.bin 

	dd if=/dev/zero of=s1.bin bs=512 count=1
	echo "Created s1.bin:"
	ls -l s1.bin
	dd if=$MBR_BOOT_ASM of=s1.bin bs=512 count=1
	echo "output $MBR_BOOT_ASM content onto s1.bin "
	ls -l s1.bin
	hexdump -C s1.bin
	dd if=ptable.bin of=s1.bin seek=446 count=$((512-446)) bs=1
	echo "added ptable.bin onto s1.bin:"
	ls -l s1.bin
	hexdump -C s1.bin
fi

dd if=$MBR_BOOT_ASM of=$TARGET_DISK_IMG bs=1 count=446 conv=notrunc
hexdump -C $TARGET_DISK_IMG -n 512
objdump -D -b binary -m i386 $MBR_BOOT_ASM | head -32

echo "Convering raw image to vdi format compatible with virtualbox."
qemu-img convert -f raw -O vdi $TARGET_DISK_IMG $TARGET_DISK_IMG_VDI
ls -l $TARGET_DISK_IMG_LOC

# -----------------
#build mbr boot...
#MBR_BOOT1_A=mbrboot1-a
#MBR_BOOT1_C=mbrboot1-c
#nasm -felf64 -F dwarf $MBR_BOOT1_A.asm
#gcc -c $MBR_BOOT1_C.c
#ld $MBR_BOOT1_A.o $MBR_BOOT1_C.o -o boot.bin


