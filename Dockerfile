FROM rockylinux:8

ARG USER=carlos

RUN set -ex \
    && yum makecache \
    && yum -y update \
    && yum -y install dnf-plugins-core \
    && yum config-manager --set-enabled powertools \
    && yum -y install \
       wget \
       bzip2 \
       perl \
       gcc \
       gcc-c++\
       git \
       gnupg \
       make \
       munge \
       munge-devel \
       python3-devel \
       python3-pip \
       python3 \
       mariadb-server \
       mariadb-devel \
       psmisc \
       bash-completion \
       vim-enhanced \
       http-parser-devel \
       json-c-devel \
       procps \
       iputils \
       openssh-server \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN alternatives --set python /usr/bin/python3

RUN pip3 install Cython nose

RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_dsa_key -N '' \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_ed25519_key -N '' \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_ecdsa_key -N ''

RUN mkdir /var/run/sshd

RUN echo 'root:PASSWORD' | chpasswd

RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN groupadd -r --gid=990 slurm \
    && useradd -r -g slurm --uid=990 slurm 

RUN useradd -d /home/${USER} -g slurm --uid=1001 ${USER} \
    && echo "${USER}:1234" | chpasswd \
    && mkdir -p /home/${USER}/.ssh \
    && chown ${USER}:slurm /home/${USER}/.ssh \
    && chmod 700 /home/${USER}/.ssh

RUN /sbin/create-munge-key
COPY id_rsa.pub /home/${USER}/.ssh/authorized_keys
COPY id_rsa /home/${USER}/.ssh/

RUN chown ${USER}:slurm -R /home/${USER}/.ssh/ \
    && chmod 600 /home/${USER}/.ssh/authorized_keys \
    && chmod 600 /home/${USER}/.ssh/id_rsa*
RUN rm /run/nologin

CMD ["/usr/sbin/sshd", "-D"]
