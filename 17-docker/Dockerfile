FROM alpine:latest

MAINTAINER Danilov Evgeny

RUN apk update && apk upgrade && apk add nginx
COPY ./nginx.conf /etc/nginx/
COPY ./default.conf /etc/nginx/conf.d/
RUN  mkdir -p /www
COPY ./index.html /www/index.html
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
CMD ["nginx"]
