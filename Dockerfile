# Copyright (c) Forge
# SPDX-License-Identifier: MPL-2.0

FROM docker.io/rockylinux/rockylinux:9

RUN rm -f /lib/systemd/system/multi-user.target.wants/*
RUN rm -f /etc/systemd/system/*.wants/*
RUN rm -f /lib/systemd/system/local-fs.target.wants/*
RUN rm -f /lib/systemd/system/sockets.target.wants/*udev*
RUN rm -f /lib/systemd/system/sockets.target.wants/*initctl*
RUN rm -f /lib/systemd/system/basic.target.wants/*
RUN rm -f /lib/systemd/system/anaconda.target.wants/*

RUN dnf -y upgrade
RUN dnf -y install \
        rpm \
        openssh-server \
        dnf-plugins-core \
        initscripts \
        sudo \
        which \
        python3 \
        iproute

RUN dnf clean all

RUN rm -f /lib/systemd/system/multi-user.target.wants/getty.target

RUN useradd -m forge
RUN echo "forge ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN echo "forge:forge" | chpasswd

RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

RUN mkdir -p /home/forge/.ssh
RUN chmod 700 /home/forge/.ssh
RUN chown forge:forge /home/forge/.ssh

COPY ssh/authorized_keys /home/forge/.ssh/authorized_keys
RUN chmod 600 /home/forge/.ssh/authorized_keys
RUN chown forge:forge /home/forge/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/lib/systemd/systemd"]
