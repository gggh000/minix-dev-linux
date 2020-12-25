clear
if [[ -z `lsmod | grep kvm` ]] ; then
	echo "kvm is already unloaded."
else
	echo "unloading kvm module..."
	ret1=`rmmod kvm_intel`
	ret2=`rmmod kvm`
	echo "ret1/ret2: $ret1/$ret2"

	if [[ $ret1 -ne 0 ]] || [[ $ret2 -ne 0 ]] ; then echo "Failure to rmmod kvm and/or kvm_intel..., giving up." exit 1 ; fi
fi

unset SESSION_MANAGER

P1=$1
VM_NAME=minix-boot
IMAGE_NAME_VDI=/var/lib/libvirt/images/minix-boot-1.vdi

if [[ $P1 == "stop" ]] ; then
	vboxmanage controlvm $VM_NAME poweroff
	vboxmanage storageattach $VM_NAME --type hdd --medium None  --storagectl SATA --device 0 --port 1
	echo "Closing medium $IMAGE_NAME_VDI..."
	echo "before closemedium..."
	vboxmanage list hdds
	UUID=`vboxmanage list hdds | grep ^UUID | tr -s " " | cut -d ' ' -f2`
	vboxmanage closemedium disk $UUID
	echo "after closemedium..."
	vboxmanage list hdds
elif [[ $P1 == "start" ]] ; then
        echo "attaching hdd vbox vm..."
	vboxmanage storageattach $VM_NAME --type hdd --medium $IMAGE_NAME_VDI   --storagectl SATA --device 0 --port 1
	virtualbox -startvm $VM_NAME -dbg
else
        echo "invalid parameter: $P1 "
fi
