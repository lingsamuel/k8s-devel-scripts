# FROM k8s.gcr.io/kube-scheduler:v1.20.0
FROM 3138b6e3d471
COPY ./kube-scheduler /usr/local/bin
