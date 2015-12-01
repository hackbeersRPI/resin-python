FROM resin/rpi-raspbian:wheezy-2015-04-08

#VARIABLEs
ENV DEBIAN_FRONTEND=noninteractive
ENV CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37"
ENV TINI_SUBREAPER=""

#ADD FILES
COPY requeriments.txt .
ADD tini.zip .

#DISABLE SERVICES
#RUN systemctl mask \
 #   dev-hugepages.mount \
 #   sys-fs-fuse-connections.mount \
 #   sys-kernel-config.mount \
 #   display-manager.service \
 #   getty@.service \
 #   systemd-logind.service \
 #   systemd-remount-fs.service \
 #   getty.target \
 #   graphical.target

#INSTALL PACKAGES
RUN apt-get update \
	&& apt-get install -yq --no-install-recommends \
	python \
	python-dev \
	python-pip \
	libzmq-dev \
	build-essential \
	libffi-dev \
	cmake \
	unzip

#COMPILE TINI
RUN unzip tini.zip
RUN 	cd tini \
	&& cmake . \
	&& make

#ISNTAL PIP PACKAGES
RUN 	/usr/bin/pip install pip --upgrade  \
	&& ln -sf /usr/local/bin/pip /usr/bin/pip \
	&& /usr/bin/pip install -r requeriments.txt \

#MAIN
ENTRYPOINT ["/tini/tini","-s","--"]
CMD ["jupyter", "console"]
