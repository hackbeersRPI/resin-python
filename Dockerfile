FROM resin/rpi-raspbian:jessie

#VARIABLEs
ENV DEBIAN_FRONTEND=noninteractive
ENV CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37"
ENV TINI_SUBREAPER=""

#ADD FILES
COPY requeriments.txt .
ADD tini.zip .

#DISABLE SERVICES
RUN systemctl mask \
    dev-hugepages.mount \
    sys-fs-fuse-connections.mount \
    sys-kernel-config.mount \
    display-manager.service \
    getty@.service \
    systemd-logind.service \
    systemd-remount-fs.service \
    getty.target \
    graphical.target

#INSTALL PACKAGES
RUN apt-get update \
	&& apt-get install -yq --no-install-recommends \
	build-essential \
	libffi-dev \
	cmake \
	unzip \
	python \
	python-dev \
	python-pip \
	vim \
	wget \
	shellinabox \
	pound

#COMPILE TINI
RUN unzip tini.zip
RUN 	cd tini \
	&& cmake . \
	&& make

#ISNTAL PIP PACKAGES
RUN 	pip install pip --upgrade  \
	&& pip install -r requeriments.txt

#RUN POUND
RUN mkdir /var/run/pound
ADD pound.cfg /etc/pound/pound.cfg
RUN pound

#SHELL
RUN useradd python
RUN useradd python -m -d /home/python -s /bin/bash
RUN echo "python:python" | chpasswd
RUN echo "python ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers
RUN /etc/init.d/shellinabox start

#MAIN
ENTRYPOINT ["/tini/tini","-s","--"]
CMD ["/bin/bash"]
