FROM ubuntu
LABEL Name="sonarqube" Version="1.0" Maintainer="Onepoint Australia" Environment="DEV"

RUN apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
    mysql-server \
    mysql-client \
    wget \
    unzip \
    supervisor \
    syslog-ng \
    openssh-server && \
    apt-get clean

# Folder needed by PHP and Openssh
RUN mkdir -p /var/run/sshd

# Copy configuration files
COPY config/supervisor/supervisord.conf /etc/supervisor/
COPY config/openssh/ /etc/ssh/
COPY entrypoint.sh /

# Configuring SSH -- please disable this in prod
RUN echo "root:Docker!" | chpasswd && \
    useradd -d /home/human -m -s /bin/bash human && echo "human:J3anne#Iz&H3re%" | chpasswd && \
    mkdir -p /home/human/.ssh/ && \
    chmod 0700 /home/human/.ssh/
COPY config/openssh/id_rsa_onepoint_human.pub /home/human/.ssh/
RUN chmod 0600 /home/human/.ssh/id_rsa_onepoint_human.pub && \
    touch /home/human/.ssh/authorized_keys && \
    chmod 0600 /home/human/.ssh/authorized_keys && \
    cat /home/human/.ssh/id_rsa_onepoint_human.pub >> /home/human/.ssh/authorized_keys && \
    chown -R human:human /home/human/.ssh/

# Port 9000 is for SonarQube
EXPOSE 2222 9000

# Run Supervisor
ENTRYPOINT [ "/bin/bash", "entrypoint.sh" ]