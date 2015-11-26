FROM resin/rpi-raspbian:wheezy
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -yq --no-install-recommends python python-dev python-pip libzmq-dev build-essential libffi-dev curl
ADD requeriments.txt .
RUN pip install pip --upgrade -q
RUN pip install -q -r requeriments.txt
RUN python -m ipykernel.kernelspec
RUN mkdir -p -m 700 /root/.jupyter/ && echo "c.NotebookApp.ip = '*'" >> /root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.port = 80" >> /root/.jupyter/jupyter_notebook_config.py
RUN curl -L -k "https://github.com/krallin/tini/releases/download/v0.6.0/tini" > tini
RUN mv tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini
EXPOSE 8888
ENTRYPOINT ["tini", "--"]
CMD ["jupyter", "notebook"]
