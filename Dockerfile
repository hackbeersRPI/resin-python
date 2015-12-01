FROM resin/rpi-raspbian:wheezy

#VARIABLEs
ENV DEBIAN_FRONTEND=noninteractive
ENV CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37"
ENV TINI_SUBREAPER=""

#ADD FILES
COPY requeriments.txt .
ADD tini.zip .
#COPY entry.sh/ /usr/bin/entry.sh
#COPY launch.service /etc/systemd/system/launch.service
#COPY pound.cfg .

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

#RUN  chmod +x /usr/bin/entry.sh
#RUN systemctl enable /etc/systemd/system/launch.service

#INSTALL PACKAGES
RUN apt-get update \
	&& apt-get install -yq --no-install-recommends \
	python \
	python-dev \
	python-pip \
	libzmq-dev \
	build-essential \
	libffi-dev \
	curl \
	cmake \
	git \
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
	&& jupyter kernelspec install-self

#RUN JUPITER
RUN mkdir -p -m 700 /root/.jupyter/ \
	&& echo "c.NotebookApp.ip = '0.0.0.0'" >> /root/.jupyter/jupyter_notebook_config.py \
	&& echo "c.NotebookApp.port = 80" >> /root/.jupyter/jupyter_notebook_config.py \
	&& echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py \
	&& echo "c.NotebookApp.allow_origin = *" \
	&& echo "c.NotebookApp.trust_xheaders = True" \
	&& echo "c.ConnectionFileMixin.ip = '0.0.0.0'" \
	&& echo "c.ConnectionFileMixin.connection_file = '/usr/local/share/jupyter/kernels/python2'"

#MAIN
ENTRYPOINT ["/tini/tini","-s","--"]
CMD ["jupyter", "notebook", "--transport=ipc"]
