# K8s Devel Scripts

How to setup a modified kvm2 minikube cluster and run e2e tests locally.

```bash
minikube start --driver=kvm2
./update.sh # Update the cluster
```

## Prerequisites

- `docker`, `minikube`, `make`
- `ssh`, `scp`, `readlink`, `ln`, `bash`
- `jq`

## Update Cluster

In `update.sh`, config:

```bash
K8S=$HOME/Projects/kubernetes # K8s repo dir
MINIKUBE_HOME=$HOME/.minikube # Minikube home
MINIKUBE_PROFILE="minikube" # Minikube profile name

NEED_MAKE=${NEED_MAKE:-1} # Set to non-1 to skip `make` (use built binaries)

# Set to non-1 to skip specific component
UPDATE_KUBECTL=${UPDATE_KUBECTL:-1}
UPDATE_KUBELET=${UPDATE_KUBELET:-1}
UPDATE_CONTROLLER_MANAGER=${UPDATE_CONTROLLER_MANAGER:-1}
UPDATE_APISERVER=${UPDATE_APISERVER:-1}
```

## Run e2e Test

```bash
kubetest --up --provider=local
make WHAT=test/e2e/e2e.test
./_output/bin/e2e.test --provider=local --kubeconfig="$HOME/.kube/config" -ginkgo.focus="XXX"
```
