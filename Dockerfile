FROM ubuntu:focal
MAINTAINER Carlos Nunez <dev@carlosnunez.me>
ENV GYB_INSTALL_PATH=/usr/local/bin

RUN apt-get -y update && \
    apt-get -y install curl python
RUN mkdir -p $GYB_INSTALL_PATH/gyb && touch $GYB_INSTALL_PATH/gyb/nobrowser.txt

RUN curl -o /tmp/gyb_install.sh -sSL https://git.io/gyb-install && chmod +x /tmp/gyb_install.sh
RUN /tmp/gyb_install.sh -l -d $GYB_INSTALL_PATH
RUN chmod -R 755 $GYB_INSTALL_PATH


WORKDIR $GYB_INSTALL_PATH/gyb
COPY ./run_gyb.sh ./run_gyb.sh
RUN chmod +x ./run_gyb.sh
ENTRYPOINT [ "./run_gyb.sh" ]
