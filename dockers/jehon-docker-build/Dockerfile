# Use an official Python runtime as a parent image
FROM ubuntu:rolling

ENV LANG C.UTF-8

RUN echo "Europe/Brussels" > /etc/timezone

# Add builder
RUN apt --yes update \
	&& DEBIAN_FRONTEND=noninteractive apt --yes install \
		make debhelper git-buildpackage binutils-arm-linux-gnueabihf apt-utils

# Set the working directory to /app
WORKDIR /app/app
RUN chmod 777 -R /app

COPY start.sh /start.sh
RUN chmod +x /start.sh
RUN groupadd hgrp -g 1000
RUN adduser --system --uid 1000 --gid 1000 husr

ENTRYPOINT [ "/start.sh" ]
