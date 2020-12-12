# detach-disk not working while vm running due to hotplug disk is not supported for this type of disk
# https://serverfault.com/questions/457250/kvm-and-libvirt-how-do-i-hotplug-a-new-virtio-disk
# root@ixt-hq-44:/git.co/dev-learn/c/asm-c-linkage# ./config-target-vm.sh rm
# removing second hdd
# error: Failed to detach disk
# error: Operation not supported: This type of disk cannot be hot unplugged

P1=$1
VM_NAME=minix-boot
IMAGE_NAME=/var/lib/libvirt/images/minix-boot-1.qcow2
DISK_NAME=hdc

if [[ $P1 == "rm" ]] ; then
	echo "removing second hdd"
	virsh destroy $VM_NAME
	virsh list
	#sleep 5
	#virsh detach-disk --domain $VM_NAME $DISK_NAME --persistent --config
	virsh detach-disk --domain $VM_NAME $DISK_NAME --config
	virsh domblklist $VM_NAME

	#mv $IMAGE_NAME $IMAGE_NAME.bak.1
	#ls -l /var/lib/libvirt/images/
	#qemu-img create -f raw $IMAGE_NAME 8G
	#ls -l /var/lib/libvirt/images/

	#echo "attaching/mounting qcow on host..."
	#echo "nbd devices before connect..."
	#ls -l /dev/nbd*| grep nbd
	#modprobe nbd max_part=8
	#qemu-nbd --connect=/dev/nbd0 $IMAGE_NAME --format=raw --nocache
	#qemu-nbd --connect=/dev/nbd0 $IMAGE_NAME --nocache
	#echo "nbd devices after connect..."
	#ret=`ls -l /dev/nbd*| grep nbd0p1 | wc -l`

	#echo "ret: $ret"

	#if [[ $ret -eq 0 ]] ; then 
	#	echo "nbd0p1 is not found. The image should have linux partition. disrepancy!!!" ; 
	#	exit 1
	#else
		ls -l /dev/nbd*
	#fi

	#echo "Showing paritions on new qcow disk image..."
	#parted /dev/nbd0 mklabel msdos
	#parted /dev/nbd0 mkpart primary ext2 0 512
	#parted /dev/nbd0 set 1 boot on
	#fdisk -l /dev/nbd0
	

	
elif [[ $P1 == "add" ]] ; then
	#echo "disconnect sd device..."
	#qemu-nbd --disconnect /dev/nbd0
	#modprobe -r nbd
	echo "attaching second hdd"
	sleep 3
	#service qemu-kvm restart ; sleep 1
	virsh attach-disk --domain $VM_NAME --source $IMAGE_NAME --target $DISK_NAME  --config  --cache none --persistent
	# detach during live vm running not working so following unnecessary unless detach part works.
	#virsh attach-disk --domain $VM_NAME --source $IMAGE_NAME --target $DISK_NAME --config --live
	sleep 3
	virsh domblklist $VM_NAME
	virsh start $VM_NAME
	virsh list
else
	echo "invalid parameter: $P1 "
fi
