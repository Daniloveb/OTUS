groupadd admin
usermod -aG admin root
useradd user

yum update -y
yum install epel-release -y
yum install pam_script -y

echo "auth  required  pam_script.so" >> /etc/pam.d/sshd

