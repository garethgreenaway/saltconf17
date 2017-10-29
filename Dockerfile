FROM ubuntu:16.04

COPY base.txt /base.txt
COPY dev_python27.txt /dev_python27.txt

RUN apt-get update
RUN apt-get -y install wget

RUN wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add -

COPY saltstack.list /etc/apt/sources.list.d/saltstack.list

RUN apt-get update

# Install Salt packages
RUN apt-get -y install salt-master salt-minion salt-ssh salt-syndic salt-cloud salt-api vim tmux wget python-pip curl

RUN pip install --upgrade pip
RUN pip install --upgrade -r /dev_python27.txt
RUN pip install --upgrade CherryPy

ENV PYTHONPATH=/testing/:/testing/salt-testing/
ENV PATH=/testing/scripts/:/testing/salt/tests/:$PATH

VOLUME /testing
