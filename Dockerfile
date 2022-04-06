# From offical Jenkins image.
# See: https://hub.docker.com/r/jenkins/jenkins
FROM jenkins/jenkins:2.332.1-lts

# Install Docker CE
# See: https://www.jenkins.io/doc/book/installing/docker/

USER root

RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli

# Install sshpass - needed to send password when connect to SFTP
RUN apt-get update && apt-get install -y sshpass

# Back to Jenkins user
USER jenkins

# Do not start Setup Wizard and set JVM memory limits
ENV JAVA_OPTS_XMX 2g
ENV JAVA_OPTS_XMS 1g
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Xmx${JAVA_OPTS_XMX} -Xms${JAVA_OPTS_XMS} ${JAVA_OPTS_EXTRA}"

# Script to create Jenkins administrator user
#ENV JENKINS_USER admin
#ENV JENKINS_PASS admin
#COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
