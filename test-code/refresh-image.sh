#Using /var/lib/libvirt/images/minix-boot-1.qcow2 as source, it will update all other images:
#- sda1.bin (primary partition)
#- vdi image (for virtualbox)
#- exact clone (to be used in minix-boot-clone-ubuntu-boot

TARGET_DISK_IMG=/var/lib/libvirt/images/minix-boot-1.qcow2
echo "Creating sda1.bin..."
dd if=$TARGET_DISK_IMG of=sda1.bin skip=1024 bs=1024
echo "Converting to vdi image..."
qemu-img convert -f raw -O vdi $TARGET_DISK_IMG $TARGET_DISK_IMG_VDI
echo "Cloning..."
cp $TARGET_DISK_IMG /var/lib/libvirt/images/minix-boot-1-clone.qcow2
echo "done..."


