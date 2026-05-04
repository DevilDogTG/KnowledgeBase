---
title: "Setup Prometheus on Kubernetes"
author: DevilDogTG
date: 2025-06-06 08:00:00 +0700
categories: [Home Lab, Kubernetes]
tags: [kubernetes, home lab, prometheus, monitoring, nfs]
---

This guide walks through installing Prometheus on a Kubernetes cluster with NFS-backed persistent storage.

## Create Namespace

Separate infrastructure tools into a dedicated monitoring namespace:

```yml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
```

## Create PersistentVolume and PersistentVolumeClaim

Use an NFS-backed PV and PVC to persist Prometheus data.

**PersistentVolume:**

```yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: prometheus-pv
  namespace: monitoring
  labels:
    app: prometheus
    type: nfs
    storage: nfs
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteMany
  nfs:
    path: /path/of/server/export
    server: 192.168.99.99
  mountOptions:
    - nfsvers=4
  persistentVolumeReclaimPolicy: Retain
```

> **Note:** `namespace` is not required for PersistentVolumes — they are cluster-scoped resources.

**PersistentVolumeClaim:**

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-pvc
  namespace: monitoring
  labels:
    app: prometheus
    type: nfs
    storage: nfs
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 50Gi
```

## Deploy Prometheus

Create a ConfigMap, Deployment, and Service for Prometheus.

**1. ConfigMap** — stores the Prometheus configuration:

```yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
  labels:
    app: prometheus
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    scrape_configs:
    - job_name: 'prometheus'
      static_configs:
      - targets: ['localhost:9090']
```

**2. Deployment** — defines the Prometheus pod, mounts config and data volumes:

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus:latest
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
            - "--storage.tsdb.path=/prometheus"
            - "--storage.tsdb.retention.time=15d"
            - "--web.enable-lifecycle"
            - "--web.external-url=http://prometheus.dmnsn.k8s/"
            - "--web.route-prefix=/"
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: config-volume
              mountPath: /etc/prometheus/
            - name: data
              mountPath: /prometheus
      volumes:
        - name: config-volume
          configMap:
            name: prometheus-config
        - name: data
          persistentVolumeClaim:
            claimName: prometheus-pvc
```

**3. Service** — exposes Prometheus within the cluster:

```yml
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: monitoring
  labels:
    app: prometheus
spec:
  selector:
    app: prometheus
  type: ClusterIP
  ports:
    - protocol: TCP
      port: 9090
      targetPort: 9090
```

## Ingress Rule

To access Prometheus from outside the cluster, configure an ingress rule. This guide uses [MetalLB](/posts/kubernetes-setup-metallb/) as the load balancer and `nginx` as the ingress controller:

```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prometheus-ingress
  namespace: monitoring
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  ingressClassName: nginx
  rules:
    - host: prometheus.dmnsn.k8s
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: prometheus
                port:
                  number: 9090
```

Access Prometheus at <http://prometheus.dmnsn.k8s:9090>.

> **Tip:** You can combine all YAML manifests into a single file by separating each document with `---`.
