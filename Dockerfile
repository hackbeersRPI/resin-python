FROM resin/rpi-raspbian:jessie

#VARIABLEs
ENV container lxc
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
#RUN git clone https://github.com/krallin/tini.git tini
RUN unzip tini.zip 
WORKDIR tini
RUN cmake . \
	&& make 

#ISNTAL PIP PACKAGES
WORKDIR /
RUN 	pip install pip --upgrade -q \
	&& pip install -q -r requeriments.txt \
	&& python -m ipykernel.kernelspec

#RUN JUPITER
RUN chmod +x jupyter.sh
RUN mkdir -p -m 700 /root/.jupyter/ \
	&& echo "c.NotebookApp.ip = '127.0.0.1'" >> /root/.jupyter/jupyter_notebook_config.py \
	&& echo "c.NotebookApp.port = 8888" >> /root/.jupyter/jupyter_notebook_config.py \
	&& echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py \
	&& echo "c.NotebookApp.allow_origin = *" \
	&& echo "c.NotebookApp.trust_xheaders = True"

#MAIN
ENTRYPOINT ["/tini/tini","-s","--"]
CMD ["jupyter", "notebook"]
