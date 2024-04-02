FROM rockylinux:8

ARG USER=carlos

#Required Packages installation
RUN set -ex \
    && yum makecache \
    && yum -y update \
    && yum -y install dnf-plugins-core \
    && yum config-manager --set-enabled powertools \
    && yum -y install wget bzip2 perl gcc gcc-c++ git gnupg make munge munge-devel python3-devel python3-pip python3 mariadb-server \
    mariadb-devel psmisc bash-completion vim-enhanced http-parser-devel json-c-devel procps iputils openssh-server \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN alternatives --set python /usr/bin/python3
RUN pip3 install Cython nose

#Downloading, configuring and Installing slurm from git
RUN set -x \
    && git clone -b slurm-21-08-6-1 --single-branch --depth=1 https://github.com/SchedMD/slurm.git \
    && pushd slurm \
    && ./configure --enable-debug --prefix=/usr --sysconfdir=/etc/slurm \
        --with-mysql_config=/usr/bin  --libdir=/usr/lib64 \
    && make install \
    && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example \
    && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example \
    && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example \
    && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh \
    && popd \
    && rm -rf slurm 

#Creating slurm user and necessary files
RUN groupadd -r --gid=990 slurm 
RUN useradd -r -g slurm --uid=990 slurm 
RUN mkdir /etc/sysconfig/slurm /var/spool/slurmd /var/run/slurmd /var/run/slurmdbd /var/lib/slurmd /var/log/slurm /data 
RUN touch /var/lib/slurmd/node_state /var/lib/slurmd/front_end_state /var/lib/slurmd/job_state /var/lib/slurmd/resv_state 
RUN touch /var/lib/slurmd/trigger_state /var/lib/slurmd/assoc_mgr_state /var/lib/slurmd/assoc_usage /var/lib/slurmd/qos_usage /var/lib/slurmd/fed_mgr_state 
RUN chown -R slurm:slurm /var/*/slurm* 
COPY slurm.conf /etc/slurm/slurm.conf
COPY slurmdbd.conf /etc/slurm/slurmdbd.conf
RUN chown slurm:slurm /etc/slurm/slurmdbd.conf \
    && chmod 600 /etc/slurm/slurmdbd.conf
RUN /sbin/create-munge-key

#Installing gosu to execute command with user privileges
RUN set -ex \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

#Setting ssh up
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_dsa_key -N '' \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_ed25519_key -N '' \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
RUN mkdir /var/run/sshd
RUN echo 'root:1234' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd


#Creating user and configuring keys
RUN useradd -d /home/${USER} -g slurm --uid=1001 ${USER} \
    && echo "${USER}:1234" | chpasswd \
    && mkdir -p /home/${USER}/.ssh \
    && chown ${USER}:slurm /home/${USER}/.ssh \
    && chmod 700 /home/${USER}/.ssh
COPY id_rsa.pub /home/${USER}/.ssh/authorized_keys
COPY id_rsa /home/${USER}/.ssh/
RUN chown ${USER}:slurm -R /home/${USER}/.ssh/ \
    && chmod 600 /home/${USER}/.ssh/authorized_keys \
    && chmod 600 /home/${USER}/.ssh/id_rsa*

#EXPOSE 22
#CMD ["/usr/sbin/sshd", "-D"]

RUN rm /run/nologin
COPY start_services.sh /root/
ENTRYPOINT ["/root/start_services.sh"]
