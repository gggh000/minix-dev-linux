#	Use this script for two functions.
#	./config-target-vm.sh add - will attach the TARGET_DISK_IMG disk to kvm guest VM and start booting from this drive.
#	Prior to attaching, dismount from /sda will take place.

#	./config-target-vm.sh rm - will shutdown the kvm guest VM and detach the TARGET_DISK_IMG and mount on host file system
#	under mount point /sda.

#	when mounting under host file system, the first partition offset is found by using fdisk and offset into first partition
#	to mount. The TARGET_DISK_IMG assumes there is only one primary, first partition which taking entire TARGET_DISK_IMG size
#	and formatted as an ext2. 

P1=$1
VM_NAME=minix-boot
TARGET_DISK_IMG=/var/lib/libvirt/images/minix-boot-1.qcow2
DISK_NAME=hdc
MOUNT_POINT_PP=/sda

if [[ ! -f $TARGET_DISK_IMG ]] ; then
	echo "Error. Can not find $TARGET_DISK_IMG. File does not exist. "
	exit 1
fi

if [[ $P1 == "rm" ]] ; then
	echo "removing second hdd"
	virsh destroy $VM_NAME
	virsh list
	virsh detach-disk --domain $VM_NAME $DISK_NAME --config
	virsh domblklist $VM_NAME
	echo "Done removing use: TARGET_DISK_IMG=/var/lib/libvirt/images/minix-boot-1.qcow2 to dump content using i.e. hexdump"

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

	
elif [[ $P1 == "add" ]] ; then
	umount $MOUNT_POINT_PP

	# Logic does not work if error like /sda was not there or was not mounted initially.
	#if [[ $? -ne 0 ]] ; then 
	#	echo "Failed to unmount $MOUNT_POINT_PP, unable to continue: $?..."
	#	exit 1
	#else
	#	echo "umount of $MOUNT_POINT_PP is successful."
	#fi
	echo "attaching second hdd"
	virsh attach-disk --domain $VM_NAME --source $TARGET_DISK_IMG --target $DISK_NAME  --config  --cache none --persistent
	virsh domblklist $VM_NAME
	virsh start $VM_NAME
	virsh list
else
	echo "invalid parameter: $P1 "
fi
