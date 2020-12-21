clear
CONFIG_SET_UUID=0
if [[ -z `lsmod | grep kvm` ]] ; then
	echo "kvm is already unloaded."
else
	echo "unloading kvm module..."
	rmmod kvm_intel
	rmmod kvm

	if [[ $? -ne 0 ]] ; then echo "Failure to rmmod kvm and/or kvm_intel..., giving up." exit 1 ; fi
fi

unset SESSION_MANAGER

P1=$1
VM_NAME=minix-boot
IMAGE_NAME=/var/lib/libvirt/images/minix-boot-1.vdi

if [[ $P1 == "stop" ]] ; then
	vboxmanage controlvm $VM_NAME poweroff
	vboxmanage storageattach $VM_NAME --type hdd --medium None  --storagectl SATA --device 0 --port 1
	vboxmanage list hdds
	echo "Closing medium $IMAGE_NAME..."
	#vboxmanage closemedium disk aab4e396-1a1d-4803-8208-7bbf44cffd99
	vboxmanage closemedium disk $IMAGE_NAME
	vboxmanage list hdds

elif [[ $P1 == "start" ]] ; then
        echo "attaching hdd vbox vm..."

	if [[ $CONFIG_SET_UUID -eq 1 ]] ; then
		vboxmanage storageattach $VM_NAME --type hdd --medium $IMAGE_NAME   --storagectl SATA --device 0 --port 1 --setuuid  6932e31d26e6419d95f04f6b5dd257ee
	else
		vboxmanage storageattach $VM_NAME --type hdd --medium $IMAGE_NAME   --storagectl SATA --device 0 --port 1
	fi
	virtualbox -startvm $VM_NAME -dbg
else
        echo "invalid parameter: $P1 "
fi
