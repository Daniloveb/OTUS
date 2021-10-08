# RPM

http://34.141.173.170/repo
# Ссылка на репозиторий с пакетом nginx, скомпилированным с openssl 1.1.1l

# Для доступа создайте файл /etc/yum.repos.d/otus.repo
# с ссодержимым
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1

# Проверяем доступность
yum repolist enabled | grep otus

# Ставим
![image](https://user-images.githubusercontent.com/43366397/136536565-5c41101d-7ba4-496f-b90d-45b5f68a6f74.png)



# Для создания пакета используем данные команды
yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils openssl-devel
cd /root
# Скачиваем и устанавливаем пакеты с исходным кодом
wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm --no-check-certificate
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
wget https://www.openssl.org/source/openssl-1.1.1l.tar.gz --no-check-certificate
tar -xvzf openssl-1.1.1l.tar.gz
rpm -Uvh nginx*.src.rpm

# Добавляем параметр в SPEC file
--with-openssl=/root/openssl-1.1.1l

# Устанавливаем зависимости
yum-builddep nginx
# Создаем пакет
rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
# устанавливаем nginx
yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
# настраиваем nginx
mkdir /usr/share/nginx/html/repo
cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
sed -i '/index  index.html index.htm/a \        autoindex on;' /etc/nginx/conf.d/default.conf
# регистрируем репозиторий
createrepo /usr/share/nginx/html/repo
