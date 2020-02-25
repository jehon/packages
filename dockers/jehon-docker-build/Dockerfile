# Use an official Python runtime as a parent image
FROM ubuntu:rolling

ENV LANG C.UTF-8

RUN echo "Europe/Brussels" > /etc/timezone

# Add builder
RUN apt --yes update \
	&& DEBIAN_FRONTEND=noninteractive apt --yes install \
		make debhelper git-buildpackage binutils-arm-linux-gnueabihf


# Set the working directory to /app
WORKDIR /app

