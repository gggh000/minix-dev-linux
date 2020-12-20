rmmod kvm_intel
rmmod kvm
unset SESSION_MANAGER

P1=$1
VM_NAME=minix-boot
IMAGE_NAME=/var/lib/libvirt/images/minix-boot-1.vdi

if [[ $P1 == "stop" ]] ; then
	vboxmanage controlvm $VM_NAME poweroff
	vboxmanage storageattach $VM_NAME --type hdd --medium None  --storagectl SATA --device 0 --port 1
elif [[ $P1 == "start" ]] ; then
        echo "attaching hdd vbox vm..."
	vboxmanage storageattach $VM_NAME --type hdd --medium $IMAGE_NAME   --storagectl SATA --device 0 --port 1
	virtualbox -startvm $VM_NAME -dbg
else
        echo "invalid parameter: $P1 "
fi

