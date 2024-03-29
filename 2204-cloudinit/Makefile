all:
	make download
	make resize
	make mount
	make prepare-resolv.conf
	make install
	make restore-resolv.conf
	make unmount

# Ubuntu 22.04
# IMAGE_LINK=https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-disk-kvm.img
IMAGE_LINK=https://s3.iwanhae.kr/public/jammy-server-cloudimg-amd64-disk-kvm.img
download:
	@echo "Downloading cloud image"
	@curl -L -o cloud.img ${IMAGE_LINK}
	@echo "Download complete"

resize: cloud.img
	@echo "Resizing cloud image"
	qemu-img resize cloud.img 20G
	@echo "Resize complete"

mount: cloud.img
	@echo "Create mnt directory"
	@mkdir -p mnt
	
	@echo "Prepare mounting QCOW2"
	@modprobe nbd max_part=8

	@echo "Create Block Device"
	@qemu-nbd --connect=/dev/nbd0 cloud.img
	@fdisk -l /dev/nbd0

	@echo "Grow Part"
	growpart /dev/nbd0 1
	e2fsck -f /dev/nbd0p1
	resize2fs /dev/nbd0p1

	@echo "Mounting on mnt"
	@mount /dev/nbd0p1 mnt

unmount: mnt
	@echo "Unmounting"
	@umount mnt
	@qemu-nbd --disconnect /dev/nbd0
	@rmdir mnt

install: mnt init.sh
	@echo "Move init.sh to mnt"
	@cp init.sh mnt/init.sh
	@chmod +x mnt/init.sh
	@echo "Installing"
	@chroot mnt /init.sh

prepare-resolv.conf:
	@echo "Prepare resolv.conf"
	@mv mnt/etc/resolv.conf mnt/etc/resolv.conf.bak
	@echo "nameserver 8.8.8.8" > mnt/etc/resolv.conf

restore-resolv.conf:
	@echo "Restore resolv.conf"
	@mv mnt/etc/resolv.conf.bak mnt/etc/resolv.conf