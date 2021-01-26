# K8s Devel Scripts

Setup a modified (single node) kvm2 minikube cluster.

```bash
minikube start --driver=kvm2
./update.sh
```

## Update Cluster

In `update.sh`, config:

```bash
K8S=$HOME/Projects/kubernetes # K8s repo dir
MINIKUBE_HOME=$HOME/.minikube # Minikube home
MINIKUBE_PROFILE="minikube" # Minikube profile name
```

## Run e2e Test

```bash
kubetest --up --provider=local
make WHAT=test/e2e/e2e.test
./_output/bin/e2e.test --provider=local --kubeconfig="$HOME/.kube/config" -ginkgo.focus="XXX"
```
