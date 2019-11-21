FROM ubuntu
LABEL Name="sonarqube" Version="1.0" Maintainer="Onepoint Australia" Environment="DEV"

# Getting APT to use our apt-cacher-ng instance
RUN sed -i 's/http\:\/\//http\:\/\/ews-apt-cache-ng-dev.azurewebsites.net\//g' /etc/apt/sources.list

# Install packages
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
    java-common \
    sudo \
    vim \
    software-properties-common && \
    apt-get clean

# Install Amazon Corretto 8
RUN wget https://d3pxv6yz143wms.cloudfront.net/8.232.09.1/java-1.8.0-amazon-corretto-jdk_8.232.09-1_amd64.deb && \
    dpkg -i java-1.8.0-amazon-corretto-jdk_8.232.09-1_amd64.deb

# Folder needed by PHP and Openssh
RUN mkdir -p /var/run/sshd

# Setting things right for MySQL
VOLUME /var/lib/mysql
RUN mkdir /var/run/mysqld/ && \
    find /var/lib/mysql -type f -exec touch {} \; && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# Copy configuration files
COPY config/supervisor/supervisord.conf /etc/supervisor/
COPY config/openssh/ /etc/ssh/

# Configuring SSH -- please disable this in prod
RUN echo "root:Docker!" | chpasswd && \
    useradd -d /home/human -m -s /bin/bash human && echo "human:J3anne#Iz&H3re%" | chpasswd && adduser human sudo && \
    mkdir -p /home/human/.ssh/ && \
    chmod 0700 /home/human/.ssh/
COPY config/openssh/id_rsa_onepoint_human.pub /home/human/.ssh/
RUN chmod 0600 /home/human/.ssh/id_rsa_onepoint_human.pub && \
    touch /home/human/.ssh/authorized_keys && \
    chmod 0600 /home/human/.ssh/authorized_keys && \
    cat /home/human/.ssh/id_rsa_onepoint_human.pub >> /home/human/.ssh/authorized_keys && \
    chown -R human:human /home/human/.ssh/

RUN java -version && \
    wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.0.zip && \
    unzip sonarqube-8.0.zip -d /opt && \
    cd /opt && \
    mv sonarqube-8.0 sonar && \
    groupadd sonar && \
    useradd -c "User to run SonarQube" -d /opt/sonar -g sonar sonar && \
    chown sonar:sonar /opt/sonar -R

COPY config/sonarqube/sonar.properties /opt/sonar/conf/sonar.properties
COPY config/sonarqube/sonar.sh /opt/sonar/bin/linux-x86-64/

# Port 9000 is for SonarQube
EXPOSE 2222 9000

# Run Supervisor
COPY entrypoint.sh /
ENTRYPOINT [ "/bin/bash", "entrypoint.sh" ]