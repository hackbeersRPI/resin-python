FROM resin/rpi-raspbian:jessie

#VARIABLEs
ENV container lxc
ENV DEBIAN_FRONTEND=noninteractive
EXPOSE 80

#ADD FILES
COPY requeriments.txt .
COPY entry.sh /usr/bin/entry.sh
COPY launch.service /etc/systemd/system/launch.service

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

RUN  chmod +x /usr/bin/entry.sh
RUN systemctl enable /etc/systemd/system/launch.service

#INSTALL PACKAGES
RUN apt-get update \
	&& apt-get install -yq --no-install-recommends \
	python \
	python-dev \
	python-pip \
	libzmq-dev \
	build-essential \
	libffi-dev \
	curl

#ISNTAL PIP PACKAGES
RUN 	pip install pip --upgrade -q \
	&& pip install -q -r requeriments.txt \
	&& python -m ipykernel.kernelspec

#RUN JUPITER
RUN mkdir -p -m 700 /root/.jupyter/ \
	&& echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py \
	&& echo "c.NotebookApp.port = 80" >> /root/.jupyter/jupyter_notebook_config.py

#MAIN
ENTRYPOINT ["/usr/bin/entry.sh"]
CMD ["jupyter", "notebook"]
