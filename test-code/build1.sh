./clear.sh
clear
CONFIG_BUILD_32=1
CONFIG_BUILD_64=2
CONFIG_BUILD_BIN=3
CONFIG_BUILD_OUTPUT_TYPE=$CONFIG_BUILD_BIN
MBR_BOOT_ASM=mbrboot
BOOT_BIN_ELF=boot.elf.bin
BOOT_BIN=boot.bin
BOOT_BIN_SIZE_MAX=32768

TARGET_DISK_IMG_LOC=/var/lib/libvirt/images/
TARGET_DISK_IMG=/var/lib/libvirt/images/minix-boot-1.qcow2

#	For use with virtual box

TARGET_DISK_IMG_VDI=/var/lib/libvirt/images/minix-boot-1.vdi

# artifacts used for building boot.bin:

BOOT_BIN_1_A=boot_bin_1-a
BOOT_BIN_1_C=boot_bin_1-c

#       install library needed for 32-bit program:

sudo apt-get install gcc-multilib -y
	
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

FLAG0=0
if [[ $FLAG0 -eq - ]] ; then
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

echo "build boot.bin..."
nasm -felf32 -F dwarf $BOOT_BIN_1_A.asm
gcc -m32 $BOOT_BIN_1_C.c $BOOT_BIN_1_A.o -o $BOOT_BIN_ELF
#ld $BOOT_BIN_1_A.o $BOOT_BIN_1_C.o -o $BOOT_BIN_ELF

#	Not quite working. needs to parse i.e. 0x04000b0. to only keep b0. For now, use hardcoded code value of b0=176.

MAIN_ENTRY=`objdump -D $BOOT_BIN_ELF | grep "\<main\>"  | grep -v "\#" | cut -d ' ' -f1`
MAIN_ENTRY_DEC=`echo $((16#$MAIN_ENTRY))`
echo "MAIN_ENTRY: $MAIN_ENTRY / $MAIN_ENTRY_DEC"
if [[ -z $MAIN_ENTRY ]] ; then
	echo "Error. Unable to find program entry for $BOOT_BIN_ELF"
else
	echo "Program entry for $BOOT_BIN_ELF: $MAIN_ENTRY..."
fi
dd if=$BOOT_BIN_ELF of=$BOOT_BIN bs=1 skip=$MAIN_ENTRY_DEC
cp boot.bin /sda/boot.bin

BOOT_BIN_SIZE=`ls -l boot.bin | cut -d ' ' -f 5`
echo "$BOOT_BIN size: $BOOT_BIN_SIZE..."

if [[ $BOOT_BIN_SIZE -gt $BOOT_BIN_SIZE_MAX ]] ; then
	echo "Error. $BOOT_BIN size is greater than current max: $BOOT_BIN_SIZE_MAX..."
	echo "I am deleting back the $BOOT_BIN to prevent silent error during program execution."
	echo "Consider reducing the size as much as possible to fit."
	rm -rf $BOOT_BIN
	rm -rf /sda/$BOOT_BIN.
else
	echo "OK..."
fi

