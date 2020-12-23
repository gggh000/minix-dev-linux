# 	Guyen Gankhuyag
# 	2020.
# 	Create qcow raw image for kvm boot which will be used as a boot drive for minix-boot development project.
#	The size of drive is 5GB.
#	The content consists of legacy MBR + 1 primary partition starting at 2048th sector. If the primary partition does not start on 2048th sector, this may be a problem.
#	MBR is marked as bootable.
#	MBR code is injected by a build1.sh script.
#	Primary partition is ext2 file system.
#	With 5GB drive with entire drive dedicated to primary ext2 partition, it shows following characteristics upon formatting with ext2:
#	blocksize=4096
#	block group size=32768
#	blocksize (in bytes) = 32768 * 4096 = 128MB.

#	There is a single boot.bin file which is loaded by MBR boot loader.
#	MBR boot loader will handle only direct block pointers (max 12) in its directory entry therefore, boot.bin's maximum size
#	is 12 x 4095 = 49152 bytes. 
	
#	Build1.sh script will build the boot.bin and replace, upon detecting the file size exceeding 49152 bytes then it should cause build error.

#	boot.bin's offset relative to its start of raw disk image is as follows:
#	root@ubuntu-desktop:/git.co/minix-dev-linux/test-code# hexdump -C $IMAGE_NAME | grep boot.bin
#	00443030  d4 0f 08 01 62 6f 6f 74  2e 62 69 6e 00 00 00 00  |....boot.bin....|
#	
#	MBR code is hardcoded to load from this offset, therefore boot.bin in the image should not be resized, moved, renamed, otherwise boot will fail if as a result of 
#	any of these, its block address change!

#	boot.bin is created with 49152 size already by this script, filled with zero.

#	Create boot.bin file

#	Create VM temporary.
#	Create or attach disk of 5GB called /var/lib/libvirt/images/minix-boot-1.qcow as raw image.

#	Mount as /sda

#	Create boot.bin in the root directory of /sda.
	
dd if=/dev/zero of=/sda/boot.bin bs=4096 count=12






