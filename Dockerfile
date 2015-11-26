FROM resin/rpi-raspbian:jessie
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -yq --no-install-recommends python python-dev python-pip libzmq-dev build-essential libffi-dev curl pound
ADD requeriments.txt .
ADD pound.cfg /etc/pound/pound.cfg
RUN pound
RUN ln -sf /usr/local/bin/pip /usr/bin/pip
RUN pip install pip --upgrade -q
RUN pip install -q -r requeriments.txt
RUN python -m ipykernel.kernelspec
RUN mkdir -p -m 700 /root/.jupyter/ && echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.port = 80" >> /root/.jupyter/jupyter_notebook_config.py
EXPOSE 80
ENTRYPOINT ["jupyter", "notebook"]
