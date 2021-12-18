# Docker

Создайте свой кастомный образ nginx на базе alpine

Создаем dockerfile, прикладываем новый index.html и config file.

Собираем образ  
'docker build -t daniloveb/nginx:v5 .'  
запускаем  
'docker run -d -p 8080:80 daniloveb/nginx:v5'  
проверяем  
'curl http://localhost:8080'  
Выкладываем в Docker hub  
'docker login  
docker push daniloveb/nginx:v5'  
Путь к образу  
https://hub.docker.com/repository/docker/daniloveb/nginx  

Ответы на вопросы
- Образ это слепок из которого разворачиваются экзепляры контейнеров.  
Как класс и объект из мира Development.  
- В контейнере нельзя собрать ядро т.к. контейнер использует ядро хостовой системы.
