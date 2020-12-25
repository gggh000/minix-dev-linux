#	Generate boot.bin file.
#	The size of boot.bin is 10 blocks + possibly little more.
#	At the beginning of each block, the 0-based block No. is printed.
#	For all other space, dot is filled.
#	Correct execution of this script should generate following hexdump output:
#00000000  30 2e 2e 2e 2e 2e 2e 2e  2e 2e 2e 2e 2e 2e 2e 2e  |0...............|
#00000010  2e 2e 2e 2e 2e 2e 2e 2e  2e 2e 2e 2e 2e 2e 2e 2e  |................|
#*
#00001000  31 2e 2e 2e 2e 2e 2e 2e  2e 2e 2e 2e 2e 2e 2e 2e  |1...............|
#00001010  2e 2e 2e 2e 2e 2e 2e 2e  2e 2e 2e 2e 2e 2e 2e 2e  |................|
#....
#*
#00009000  39 2e 2e 2e 2e 2e 2e 2e  2e 2e 2e 2e 2e 2e 2e 2e  |9...............|
#00009010  2e 2e 2e 2e 2e 2e 2e 2e  2e 2e 2e 2e 2e 2e 2e 2e  |................|
#*
#0000a000  31 30                                             |10|
#0000a002

BOOT_BIN=/sda/boot.bin
EXT_BLOCK_SIZE=4096
FILE_SIZE_BYTES=4096 * 12
ret=`mount | grep sda`

if [[ -z $ret ]] ; then 
	echo "Error. sda1 is not mounted."
	exit 1
fi

echo -ne "" > $BOOT_BIN
for i in {0..49149}; do
	
	if [[ $(($i % $EXT_BLOCK_SIZE)) -eq 0 ]] ; then
		echo -ne $(($i / $EXT_BLOCK_SIZE)) >> $BOOT_BIN
	else
		echo -ne "." >> $BOOT_BIN
	fi
done

hexdump -C $BOOT_BIN
