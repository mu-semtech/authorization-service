FROM semtech/mu-cl-resources:1.8.1

MAINTAINER Jonathan Langens <flowofcontrol@gmail.com>

COPY ./config/resources /config

ENV BOOT=mu-cl-resources
