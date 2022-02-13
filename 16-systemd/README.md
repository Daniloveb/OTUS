# Systemd

## Задачи

Systemd

Описание/Пошаговая инструкция выполнения домашнего задания:
Выполнить следующие задания и подготовить развёртывание результата выполнения с использованием Vagrant и Vagrant shell provisioner (или Ansible, на Ваше усмотрение):

Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.  

## Выполнение

### 1. Создание timer сервиса

Скрипт мониторинга лога
```
#!/bin/bash
marker=$1
log=$2
DATE=`date`
logger teak
if grep $marker $log &> /dev/null
then
logger "$DATE: alert " # logger отправляет лог в системный журнал (/var/log/messages)
else
exit 0
fi
```
unit файл сервиса:
```
[Unit]
Description=My log service
Wants=mylog.timer

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/mylog.conf
ExecStart=/opt/eye.sh $marker $log
```
unit файл timer:
```
[Unit]
Description=Run mylog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=mylog.service

[Install]
WantedBy=timer.target
```
Конфигурационный файл для сервиса
```
marker="ALERT"
log=/var/log/mylog.log
```

Последовательность запуска в разделе shell provision vagrant файла
```
     yum update -y
      yum install -y httpd mc
      cp /vagrant/mylog.conf /etc/sysconfig/
      cp /vagrant/mylog.log /var/log/
      cp /vagrant/eye.sh /opt/
      cp /vagrant/mylog.service /vagrant/mylog.timer /etc/systemd/system/
      systemctl daemon-reload
      systemctl start mylog.service
      systemctl enable mylog.service
```

Проверяем
```
[root@sys vagrant]# tail -f /var/log/messages
Feb 13 05:52:02 sys systemd: Starting My log service...
Feb 13 05:52:02 sys root: teak
Feb 13 05:52:02 sys root: Sun Feb 13 05:52:02 UTC 2022: alert
Feb 13 05:52:02 sys systemd: Started My log service.
Feb 13 05:52:02 sys systemd: Starting Cleanup of Temporary Directories...
Feb 13 05:52:02 sys systemd: Started Cleanup of Temporary Directories.
Feb 13 05:53:12 sys systemd: Starting My log service...
Feb 13 05:53:12 sys root: teak
Feb 13 05:53:12 sys root: Sun Feb 13 05:53:12 UTC 2022: alert
Feb 13 05:53:12 sys systemd: Started My log service.
```

###2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).

```
yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
```

раскомментируем 2 последние строки в файле /etc/sysconfig/spawn-fcgi
```
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"
```

Создадим файл сервиса vim /etc/systemd/system/spawn-fcgi.service :
```
[Unit]
Description=spawn-fcgi
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
```

Проверяем
```
[root@sys opt]# systemctl start spawn-fcgi
[root@sys opt]# systemctl status spawn-fcgi
● spawn-fcgi.service - spawn-fcgi
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2022-02-13 06:09:02 UTC; 24s ago
 Main PID: 20922 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           ├─20922 /usr/bin/php-cgi
           ├─20923 /usr/bin/php-cgi
           ├─20924 /usr/bin/php-cgi
           ├─20925 /usr/bin/php-cgi
           ├─20926 /usr/bin/php-cgi
           ├─20927 /usr/bin/php-cgi
           ├─20928 /usr/bin/php-cgi
           ├─20929 /usr/bin/php-cgi
           ├─20930 /usr/bin/php-cgi
           ├─20931 /usr/bin/php-cgi
           ├─20932 /usr/bin/php-cgi
           ├─20933 /usr/bin/php-cgi
           ├─20934 /usr/bin/php-cgi
           ├─20935 /usr/bin/php-cgi
           ├─20936 /usr/bin/php-cgi
           ├─20937 /usr/bin/php-cgi
           ├─20938 /usr/bin/php-cgi
           ├─20939 /usr/bin/php-cgi
           ├─20940 /usr/bin/php-cgi
           ├─20941 /usr/bin/php-cgi
           ├─20942 /usr/bin/php-cgi
           ├─20943 /usr/bin/php-cgi
           ├─20944 /usr/bin/php-cgi
           ├─20945 /usr/bin/php-cgi
           ├─20946 /usr/bin/php-cgi
           ├─20947 /usr/bin/php-cgi
           ├─20948 /usr/bin/php-cgi
           ├─20949 /usr/bin/php-cgi
           ├─20950 /usr/bin/php-cgi
           ├─20951 /usr/bin/php-cgi
           ├─20952 /usr/bin/php-cgi
           ├─20953 /usr/bin/php-cgi
           └─20954 /usr/bin/php-cgi

Feb 13 06:09:02 sys systemd[1]: Started spawn-fcgi.

```
    

###3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.

Используем шаблон сервиса. Наличие '@' в имени сервиса (перед точкой) указывает на то, что это шаблон.
Ссылку на конф. кодируем через instance name - %I

Юнит файл /etc/systemd/system/httpd@.service:
```
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/%I
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```