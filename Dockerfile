FROM jenkins/jenkins:lts-jdk11

USER root

# Install Docker CE
# See: https://docs.docker.com/engine/install/debian/
# And: https://github.com/faudeltn/Jenkins/blob/master/build/debian/Dockerfile
RUN apt-get update && \
    apt-get -y install apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
    add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
        $(lsb_release -cs) \
        stable" && \
    apt-get update && \
    apt-get -y install docker-ce

# Allow jenkins user to use Docker
RUN usermod -a -G docker jenkins

# Back to Jenkins user
USER jenkins

# Do not start Setup Wizard and set JVM memory limits
ENV JAVA_OPTS_XMX 2g
ENV JAVA_OPTS_XMS 1g
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false -Xmx${JAVA_OPTS_XMX} -Xms${JAVA_OPTS_XMS} ${JAVA_OPTS}"

RUN echo ${JAVA_OPTS}

# Script to create Jenkins administrator user
ENV JENKINS_USER admin
ENV JENKINS_PASS admin
COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

# Install plugins
COPY plugins.txt /usr/share/jenkins/ref/
#RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt
