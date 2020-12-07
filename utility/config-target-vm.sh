# Guyen Gankhuyag
# helper script for toggling between
# 1. Attach qcow to target vm.
# 2. Detach qcow from target vm.

# usage:
# Attach qcow image to VM: ./config-target-vm.sh add
# Detach qcow image to VM: ./config-target-vm.sh rm

# Target vm is defined by VM_NAME and qemu support vm format.
# Qcow image is defiend by IMAGE_NAME.

# Operational description.
#
# Attaching qcow image also involves following steps: 
# Disconnecting qcow image from host.
# Attach qcow image to target VM.
# Power up target VM.
# Display relevant status: VMs running, qcow image(s) attached to target VM.
#
# Detaching qcow image also involves following steps:
# Power down target VM.
# Detach qcow from target VM.o
# Load nbd module.
# Connect qcow image to nbd module.
# Display relevant status: VMs running, connected qcows on host system. 
 
# issues:
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
	virsh detach-disk --domain $VM_NAME $DISK_NAME --persistent --config
	virsh domblklist $VM_NAME
	echo "attaching/mounting qcow on host..."
	echo "sd devices before connect..."
	ls -l | grep nbd
	modprobe nbd max_part=8
	qemu-nbd --connect=/dev/nbd0 $IMAGE_NAME
	echo "sd devices after connect..."
	ls -l | grep nbd
	
elif [[ $P1 == "add" ]] ; then
	echo "disconnect sd device..."
	qemu-nbd --disconnect /dev/nbd0
	rmmod nbd
	echo "attaching second hdd"
	virsh attach-disk --domain $VM_NAME --source $IMAGE_NAME --target hdc --config
	# detach during live vm running not working so following unnecessary unless detach part works.
	#virsh attach-disk --domain $VM_NAME --source $IMAGE_NAME --target hdc --config --live
	virsh domblklist $VM_NAME
	virsh start $VM_NAME
	virsh list
else
	echo "invalid parameter: $P1 "
fi
