# K8s Devel Scripts

Setup a modified (single node) kvm2 minikube cluster.

```bash
minikube start --driver=kvm2
./update.sh
```

## Configuration

In `update.sh`:

```bash
K8S=$HOME/Projects/kubernetes # K8s repo dir
MINIKUBE_HOME=$HOME/.minikube # Minikube home
MINIKUBE_PROFILE="minikube" # Minikube profile name
```
