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
	cmake \
	unzip \
	python \
	python-dev \
	python-pip \
	vim \
	wget \
	shellinabox \
	haproxy

#COMPILE TINI
RUN unzip tini.zip
RUN 	cd tini \
	&& cmake . \
	&& make

#ISNTAL PIP PACKAGES
RUN 	pip install pip --upgrade  \
	&& pip install -r requeriments.txt

#RUN POUND
RUN mkdir /var/run/haproxy
ADD haproxy.cfg /etc/haproxy/haproxy.cfg

#SHELL
RUN useradd hack -m -d /home/hack -s /bin/bash
RUN echo "hack:temporal" | chpasswd
RUN echo "hack ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers
RUN /etc/init.d/shellinabox start

#MAIN
ENTRYPOINT ["/tini/tini","-s","--"]
CMD ["/usr/sbin/haproxy", "-f", "/etc/haproxy/haproxy.cfg"]
