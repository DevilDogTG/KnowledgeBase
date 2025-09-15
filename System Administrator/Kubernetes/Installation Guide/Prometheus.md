---
layout: default
---
# :wrench: Setup Prometheus on Kubernetes

This guide will be example to install Prometheus on kubernetes cluster that place data on NFS

## Create `NameSpace`

We need to sperate infastructure tools as a monitoring namespace, than create new namespace:

```yml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
```

## Create Persistant Volume and Claims

To store Prometheus data persistently, we use an NFS-backed PersistentVolume (PV) and PersistentVolumeClaim (PVC).

Persistant Volumn:

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

> Note: The `namespace` field is not required for PersistentVolumes, as they are cluster-scoped resources.

Then create `pvc` to claim persistent volume for pod use:

Persistent Volume Claim:

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

> **Tip**: The selector ensures the PVC binds to the correct PV.

## Setup `Prometheus`

We will create a ConfigMap, Deployment, and Service for Prometheus.

1. **ConfigMap**

    Stores the Prometheus configuration file (`prometheus.yml`):

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

    > **Explanation**: This config sets the scrape interval and tells Prometheus to monitor itself.

This ConfigMap provides `prometheus.yml` for Prometheus. Deploy it by mounting the ConfigMap in the pod specification of the Deployment.

2. **Deployment**

    Defines the Prometheus pod, mounts the config and data volumes:

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

    > **Explanation**:
    >
    > `config-volume` mounts the Prometheus configuration.
    > `data` mounts the NFS-backed PVC for persistent storage.

    `deployment` will tell description of pod to configure and deployed it as configured. If we need to access service you need to expose it by using `service`

3. **Service**

    Exposes Prometheus within the cluster:

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

The `Service` object in Kubernetes exposes the Prometheus pods within the cluster and ensures communication between them. It also manages load balancing across multiple pod replicas created by the same deployment.

## Ingress rule to access from outside

To access an application running in Kubernetes, we need to set up an `ingress` rule to map the host, path, and ports to expose via the load balancer. This guide uses [MetalLB](../Setup MetalLB.md) as the load balancer and `nginx` as the ingress controller.

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

Now you can access `Prometheus` via [http://prometheus.dmnsn.k8s:9090](http://prometheus.dmnsn.k8s:9090), you can setup NGINX reverse proxy for SSL termination host to access your local service in cluster

## :bulb: Tips

- You can combine all YAML manifests into a single file by separating each document with `---`.
