#!/bin/bash
#######################################BH###

#Check if we are root
if (( $EUID != 0 )); then
#    sudo su
        echo "Usage:" $0
        echo " Please run it as Root"
        echo "sudo" $0
        exit
fi
DOCKER_VERSION="17.05"
DOCKER_COMPOSE_VERSION="1.10"
DOCKER_USER=""
DOCKER_SECRET=""

function install_docker {
    if [ $(sudo docker version | grep $DOCKER_VERSION |wc -l ) -le  1 ]; then
         echo "***************     Installing docker-engine"
         apt-get -y install apt-transport-https
         apt-get update
         apt-get --assume-yes install software-properties-common python-software-properties
         apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
         apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
         apt-cache policy docker-engine
         apt-get --assume-yes install linux-image-extra-$(uname -r) linux-image-extra-virtual
         apt-get update
         apt-get --assume-yes -y install docker-engine

    else
         echo " ******* docker-engine is already installed"
    fi

}


function install_docker_compose {
    if [ $(  docker-compose version | grep $DOCKER_COMPOSE_VERSION |wc -l ) -eq 0 ]; then
       echo "***************     Installing docker-compose"
       curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
       chmod +x /usr/local/bin/docker-compose
    else
       echo "***************     DockerCompose is already installed"
    fi
}

function docker_login {
    if [ $(docker info | grep Username |wc -l) -eq 0 ]; then
       if [ "$DOCKER_USER" == " " ]; then
           echo " Please enter your login credentials to docker-hub"
           docker login
       else
           #Login and enter the credentials you received separately when prompt
           echo "docker login" $DOCKER_USER $DOCKER_SECRET
           docker login --username=$DOCKER_USER --password=$DOCKER_SECRET
       fi

       if [ $? == 0 ]; then
         echo "Login Succeeded!"
       else
         echo "Cannot Login to docker, Exiting!"
         echo "$(date): An error occured during the installation: Cannot login to docker" >> "$LOGFILE"
         exit 1
       fi
    fi
}

install_docker

install_docker_compose

docker_login
