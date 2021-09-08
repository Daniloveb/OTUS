sudo su
yum update -y
sed -ie '/^UUID/a 192.168.50.10:/usr/local/nfs /mnt nfs rw,vers=3,sync,proto=udp,noauto,rsize=32768,wsize=32768 0 0' /etc/fstab
systemctl restart remote-fs.target
