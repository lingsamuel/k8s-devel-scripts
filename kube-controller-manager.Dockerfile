# FROM k8s.gcr.io/kube-controller-manager:v1.20.0 
FROM b9fa1895dcaa
COPY ./kube-controller-manager /usr/local/bin
