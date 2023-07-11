# wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
wget https://s3.iwanhae.kr/public/jammy-server-cloudimg-amd64.img

qemu-img resize jammy-server-cloudimg-amd64.img 5G

modprobe nbd 
qemu-nbd --connect=/dev/nbd0 ./jammy-server-cloudimg-amd64.img
growpart /dev/nbd0 1
e2fsck -f /dev/nbd0p1
resize2fs /dev/nbd0p1 
fdisk /dev/nbd0 -l

mkdir tmp
mount /dev/nbd0p1 ./tmp

mv ./tmp/etc/resolv.conf ./tmp/etc/resolv.conf.bak
cat <<EOF > ./tmp/etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

cp init.bash tmp/init.bash
chroot ./tmp bash /init.bash

mv ./tmp/etc/resolv.conf.bak ./tmp/etc/resolv.conf
umount ./tmp
rm -d tmp
qemu-nbd --disconnect /dev/nbd0
rmmod nbd