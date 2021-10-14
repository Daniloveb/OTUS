# Boot

1. Попасть в систему без пароля несколькими способами:

№1 
При загрузке машины нажать F12 для выбора загрузочного носителя
На этапе выбора ядра нажать "e"
В конце строки начинающейся с linux16 добавить init=/bin/sh и нажать сtrl-x для загрузки системы
Перемонтировать файловую систему в rw командой: mount -o remount,rw /
Задаем пароль для root
-passwd root
После смены пароля необходимо создать файл .autorelabel в /, выполнив
-touch /.autorelabel
Перезагружаемся и входим в систему с измененным паролем root.

№2
При загрузке машины нажать F12 для выбора загрузочного носителя
На этапе выбора ядра нажать "e"
В конце строки начинающейся с linux16 добавить rd.break и нажать сtrl-x для загрузки системы
Перемонтировать файловую систему в rw командой: mount -o remount,rw /sysroot
Далее, выполнить chroot в смонтированную директорию: chroot /sysroot
Сменить пароль: 
- passwd root
создаем файл .autorelabel

№3
В строке, начинающейся на linux16, меняем параметр ro на rw init=/sysroot/bin/sh и
Сразу попадаем в файловую систему, смонтированную на запись, и выполняем
-passwd root
-touch /.autorelabel
Перезагружаемся и входим в систему с измененным паролем root.

#Установить систему с LVM, после чего переименовать VG:
[vagrant@lvm ~]$ sudo vgs
VG #PV #LV #SN Attr VSize VFree VolGroup00 1 2 0 wz--n- <38.97g 0
[vagrant@lvm ~]$ sudo vgrename VolGroup00 OtusRoot
Volume group "VolGroup00" successfully renamed to "OtusRoot"
Далее правим /etc/fstab, /etc/default/grub, /boot/grub2/grub.cfg. Везде заменить старое название на новое.
[root@lvm vagrant]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
Executing: /sbin/dracut -f -v /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img 3.10.0-862.2.3.el7.x86_64
dracut module 'busybox' will not be installed, because command 'busybox' could not be found!
...

*** Creating image file ***

*** Creating image file done ***

*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
Перезагрузить машину и проверить:
[root@otuslinux ~]# vgs
VG #PV #LV #SN Attr VSize VFree
OtusRoot 1 2 0 wz--n- <38.97g 0


Добавить модуль в initrd:
Скрипты модулей хранятся в каталоге /usr/lib/dracut/modules.d/. Чтобы добавить свой модуль необходимо создать папку с именем 01test:
sudo mkdir /usr/lib/dracut/modules.d/01test
В нее поместим два скрипта:
module_setup.sh
  #!/bin/bash
  check() {
  return 0
  }
  depends() {
      return 0
  }
  install() {
      inst_hook cleanup 00 "${moddir}/test.sh"
  }
test.sh
#!/bin/bash
exec 0<>/dev/console 1<>/dev/console 2<>/dev/console
cat <<'msgend'
Hello! You are in dracut module!
___________________
< I'm dracut module >
-------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
msgend
sleep 10
echo " continuing...."
__________________________________________________
Пересобрать образ initrd:
sudo mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
sudo lsinitrd -m /boot/initramfs-$(uname -r).img | grep test
Перезагрузить машину отключив при загрузке опции rghb и quiet.