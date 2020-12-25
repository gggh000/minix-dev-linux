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

source api.sh

# Get starting sector of primary partition.

SECTOR_START_PP=`fdisk -l $TARGET_DISK_IMG | grep Linux | head -1 | tr -s ' ' | cut -d ' ' -f3`
if [[ -z $SECTOR_START_PP ]] ; then
        echo "Unable to get starting sector. "
        exit 1
fi
BYTES_PER_SECTOR=512
OFFSET_PP=$(($SECTOR_START_PP * $BYTES_PER_SECTOR))
echo "offset of primary partition: $OFFSET_PP"
mkdir $MOUNT_POINT_PP -p
echo mount $TARGET_DISK_IMG -o loop,offset=$OFFSET_PP $MOUNT_POINT_PP
mount $TARGET_DISK_IMG -o loop,offset=$OFFSET_PP $MOUNT_POINT_PP
echo "Content of primary partition..."
ls -l  $MOUNT_POINT_PP

#build boot.bin...
#BOOT_BIN_1_A=boot_bin_1-a
#BOOT_BIN_1_C=boot_bin_1-c
#nasm -felf64 -F dwarf $BOOT_BIN_1_A.asm
#gcc -c $BOOT_BIN_1_C.c
#ld $BOOT_BIN_1_A.o $BOOT_BIN_1_C.o -o boot.bin
