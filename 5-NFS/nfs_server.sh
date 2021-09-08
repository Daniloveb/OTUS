sudo su
#yum update -y
systemctl enable nfs && echo 'nfs enable'
systemctl start nfs && echo 'nfs start'
mkdir /usr/local/nfs
echo '/usr/local/nfs              *(rw,root_squash)' > /etc/exports

exportfs -r
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-port=111/tcp
firewall-cmd --permanent --add-port=54302/tcp
firewall-cmd --permanent --add-port=20048/tcp
firewall-cmd --permanent --add-port=2049/tcp
firewall-cmd --permanent --add-port=46666/tcp
firewall-cmd --permanent --add-port=42955/tcp
firewall-cmd --permanent --add-port=875/tcp
firewall-cmd --permanent --add-port=111/udp
firewall-cmd --permanent --add-port=54302/udp
firewall-cmd --permanent --add-port=20048/udp
firewall-cmd --permanent --add-port=2049/udp
firewall-cmd --permanent --add-port=46666/udp
firewall-cmd --permanent --add-port=42955/udp
firewall-cmd --permanent --add-port=875/udp
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload
mkdir /usr/local/nfs/upload
chmod 777 /usr/local/nfs/upload
