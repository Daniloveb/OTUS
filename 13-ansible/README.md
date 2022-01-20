# Ansible

Использовались два сервера 192.168.1.40 - ansible :сервер  
192.168.1.97 c7-test  : клиент  
Для авторизации создаем пару ключей и копируем private_key в папку /opt/ansible/key/  
public key в ~/.ssd/authorized_keys на клиенте  

```
root@ansible:/opt# ansible --version
ansible 2.10.8
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/opt/ansible/my_modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.9.2 (default, Feb 28 2021, 17:03:44) [GCC 10.2.1 20210110]
```
ansible.cfg
```
root@ansible:/opt# cat /etc/ansible/ansible.cfg
# config file for ansible -- http://ansible.com/
# ==============================================

inventory      = /opt/ansible/hosts
library        = /opt/ansible/my_modules/
roles_path    = /opt/ansible/roles
host_key_checking = False
private_key_file = /opt/ansible/key/private_key
log_path = /var/log/ansible.log

```
Создаем в папке /opt/ansible/roles структуру командой 
```
ansible-galaxy init nginx-test
```
используем файлы Tasks, Templates & Handlers
```
---
# tasks file for nginx-test
# enable EPEL repo by installing the epel-release package
- name: install EPEL repo
  become: yes
  yum: name=epel-release state=present

- name: Install Nginx Web Server on RedHat Family
  yum:
    name=nginx
    state=latest
  when:
    ansible_os_family == "RedHat"
  notify:
    - nginx restart

- name: Install Nginx Web Server on Debian Family
  apt:
    name=nginx
    state=latest
  when:
    ansible_os_family == "Debian"
  notify:
    - nginx restart

- name: Replace nginx.conf
  template:
    src: templates/nginx.conf
    dest: /etc/nginx/nginx.conf
  notify:
        - nginx restart

- name: Index page
  template:
    src: templates/index.html
    dest: /usr/share/nginx/html/index.html
```

Для запуска используем playbook nginx_deploy.yml
```
---
- name: nginx role
  hosts: c7-test
  roles:
    - nginx-test
```

#### Тест

```
root@ansible:~/ansible/playbooks# ansible-playbook nginx_deploy.yml

PLAY [nginx role] *****************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************
ok: [c7-test]

TASK [nginx-test : install EPEL repo] *********************************************************************************
changed: [c7-test]

TASK [nginx-test : Install Nginx Web Server on RedHat Family] *********************************************************
changed: [c7-test]

TASK [nginx-test : Install Nginx Web Server on Debian Family] *********************************************************
skipping: [c7-test]

TASK [nginx-test : Replace nginx.conf] ********************************************************************************
changed: [c7-test]

TASK [nginx-test : Index page] ****************************************************************************************
changed: [c7-test]

RUNNING HANDLER [nginx-test : nginx restart] **************************************************************************
changed: [c7-test]

PLAY RECAP ************************************************************************************************************
c7-test                    : ok=6    changed=5    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

```

```
[root@c7-test ~]# curl localhost:8080
<!doctype html>
<html lang="ru">
<head>
  <meta charset="utf-8" />
  <title>Hi nginx</title>
  <link rel="stylesheet" href="style.css" />
</head>
<body>
 ...
</body>
</html>[root@c7-test ~]#
```



