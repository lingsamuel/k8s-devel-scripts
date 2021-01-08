#!/bin/bash

SHELL_LOCATION="$(readlink -f $(dirname "$0"))"

K8S=$HOME/Projects/kubernetes
MINIKUBE_HOME=$HOME/.minikube
MINIKUBE_PROFILE="minikube"

CLUSTER_VERSION=$(jq -r ".KubernetesConfig.KubernetesVersion" "$MINIKUBE_HOME/profiles/$MINIKUBE_PROFILE/config.json")

IP=$(jq -r ".Driver.IPAddress" $MINIKUBE_HOME/machines/$MINIKUBE_PROFILE/config.json)
SSH_OPT="-o PasswordAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=quiet -i $MINIKUBE_HOME/machines/$MINIKUBE_PROFILE/id_rsa"
SSH="ssh $SSH_OPT docker@$IP"
SCP="scp $SSH_OPT"

UPDATE_KUBECTL=0
UPDATE_KUBELET=1
UPDATE_CONTROLLER_MANAGER=0
UPDATE_APISERVER=0

### ==============
### Build Binaries
### ==============
pushd $K8S

if [[ ! $UPDATE_KUBECTL = 0 ]]; then
    make kubectl
fi
if [[ ! $UPDATE_KUBELET = 0 ]]; then
    export KUBE_STATIC_OVERRIDES="kubelet"
    make kubelet
fi
if [[ ! $UPDATE_CONTROLLER_MANAGER = 0 ]]; then
    make kube-controller-manager
fi
if [[ ! $UPDATE_APISERVER = 0 ]]; then
    make kube-apiserver
fi
# make kubectl kubelet kube-controller-manager kube-apiserver

### =========================
### Setup minikube docker-env
### =========================

setup_minikube_docker() {
    # eval $(minikube -p $MINIKUBE_PROFILE docker-env)
    unset DOCKER_CONFIG
    export DOCKER_TLS_VERIFY="1"
    export DOCKER_HOST="tcp://$IP:2376"
    export DOCKER_CERT_PATH="$MINIKUBE_HOME/certs"
    export MINIKUBE_ACTIVE_DOCKERD="minikube"
}

unset_minikube_docker() {
    export DOCKER_CONFIG=$HOME/.docker
    unset DOCKER_TLS_VERIFY
    unset DOCKER_HOST
    unset DOCKER_CERT_PATH
    unset DOCKER_CERT_PATH
}

setup_minikube_docker

### ======================
### Build component images
### ======================

build_binary_image() {
    local TARGET=$1
    if [[ -z $TARGET ]]; then
        echo "Target is empty!"
        exit 1
    fi
    ln -f $K8S/_output/bin/$TARGET $SHELL_LOCATION/$TARGET
    ln -sf $SHELL_LOCATION/$TARGET.dockerignore $SHELL_LOCATION/.dockerignore
    docker build -f $SHELL_LOCATION/$TARGET.Dockerfile $SHELL_LOCATION -t k8s.gcr.io/$TARGET:$CLUSTER_VERSION

    # clean
    rm $SHELL_LOCATION/.dockerignore $SHELL_LOCATION/$TARGET
}

if [[ ! $UPDATE_CONTROLLER_MANAGER = 0 ]]; then
    build_binary_image kube-controller-manager
fi
if [[ ! $UPDATE_APISERVER = 0 ]]; then
    build_binary_image kube-apiserver
fi
### =================
### Update components
### =================
$SCP $K8S/_output/bin/kubelet docker@$IP:/home/docker

if [[ ! $UPDATE_CONTROLLER_MANAGER = 0 ]]; then
    docker rm -f $(docker ps -a | grep k8s_kube-controller-manager | awk '{print $1}')
fi
if [[ ! $UPDATE_APISERVER = 0 ]]; then
    docker rm -f $(docker ps -a | grep k8s_kube-apiserver | awk '{print $1}')
fi

if [[ ! $UPDATE_KUBELET = 0 ]]; then
    # Restart Kubelet after new apiserver is restarted
    $SSH sudo systemctl stop kubelet
    $SSH sudo cp /home/docker/kubelet /var/lib/minikube/binaries/$CLUSTER_VERSION/
    $SSH sudo systemctl start kubelet
fi

pushd $K8S
