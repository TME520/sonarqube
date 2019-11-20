FROM ubuntu
LABEL Name="sonarqube" Version="1.0" Maintainer="Onepoint Australia" Environment="DEV"

RUN add-apt-repository ppa:webupd8team/java

RUN apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
    mysql-server \
    mysql-client \
    wget \
    unzip \
    supervisor \
    syslog-ng \
    openssh-server \
    oracle-java8-installer && \
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

RUN java -version && \
    mysql -u root -pmysql -e "create database sonar" && \
    wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.0.zip && \
    unzip sonarqube-8.0.zip -d /opt && \
    cd /opt && \
    mv sonarqube-8.0 sonar && \
    groupadd sonar && \
    useradd -c "user to run SonarQube" -d /opt/sonar -g sonar sonar && \
    chown sonar:sonar /opt/sonar -R

# COPY config/sonarqube/sonar.properties /opt/sonar/conf/sonar.properties
# COPY config/sonarqube/sonar.sh /opt/sonar/bin/linux-x86-64/

# Port 9000 is for SonarQube
EXPOSE 2222 9000

# Run Supervisor
ENTRYPOINT [ "/bin/bash", "entrypoint.sh" ]