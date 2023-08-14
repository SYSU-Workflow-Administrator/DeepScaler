# DeepScaler: Holistic Autoscaling for Microservices Based on Spatiotemporal GNN with Adaptive Graph Learning

![Static Badge](https://img.shields.io/badge/python-3.6-blue) ![Static Badge](https://img.shields.io/badge/PyTorch-red) 

## Overview
This repository contains a prototyped version of DeepScaler described in our ASE '23 paper "DeepScaler: Holistic Autoscaling for Microservices Based on Spatiotemporal GNN with Adaptive Graph Learning".

## Instructions
### Machine Prerequisited
The experimental evaluation was conducted on a distributed cluster deployed in a public Elastic Compute
Service (ECS) platform. The cluster contains eight virtual machines (VMs) running Ubuntu 18.04 LTS operating system with kernel version 4.15.0. Half of the VMs each have a 12-core 2.2 GHz CPU, 24 GB memory, and 100GB disk. Each of the other VMs has a 24-core 2.2 GHz CPU, 32 GB memory, and 500 GB disk. All the VMs are in the same local area network to reduce the network jitters. We used the Kubernetes container orchestration system to manage the deployment of microservices on the cluster and Istio service mesh to take over network traffic and provide load balancing.
### Setup Kubernetes Cluster
A running Kubernetes cluster is required before deploying DeepScaler. The following instructions are tested with Kubernetes v1.23.4, Docker 20.10.12. For set-up instructions, refer to [this](setUp-k8s.md).

## Deploy DeepScaler
Clone the repository to the same location on every node.
### Requirements
+   Python 3.6
+   matplotlib == 3.5.2
+   numpy == 1.21.5
+   pandas == 1.4.4
+   torch == 1.13.1
Prerequisite: ```pip3 install -r requirements.txt```

### Setup Prometheus
Prometheus is an open-source monitoring and alerting toolkit used for collecting and storing metrics from various systems.
For detailed installation steps, please refer to [this](https://prometheus.io/docs/introduction/first_steps/).

### Setup Grafana
Grafana is a popular open-source platform for visualizing and analyzing metrics from various data sources. For detailed installation steps, please refer to [this](https://grafana.com/docs/grafana/latest/getting-started/build-first-dashboard/).
For the sake of convenience, after installing Grafana, you can directly import the [grafana.json](https://github.com/SYSU-Workflow-Administrator/DeepScaler/blob/main/grafana.json) file through the dashboard to monitor the system data source.

### Setup Istio
Istio is an open-source service mesh platform that enhances the management and security of microservices in a distributed application. After having a cluster running a supported version of Kubernetes, installing Istio is needed. Follow [these steps](https://istio.io/latest/docs/setup/getting-started/) to get started with Istio:

## Benchmarks
### Bookinfo
```
(1) kubectl create -f <(istioctl kube-inject -f /benchmarks/bookinfo/bookinfo.yaml)
(2) kubectl apply  -f /benchmarks/bookinfo/bookinfo-gateway.yaml)
```
### Online-boutique
```
(1) kubectl create -f <(istioctl kube-inject -f /benchmarks/boutique/boutique.yaml)
(2) kubectl apply  -f /benchmarks/boutique/boutique-gateway.yaml)
```
### Train-ticket
Deploy the Train-Ticket system on K8S with istio.
```
(1) kubectl create -f <(istioctl kube-inject -f /benchmarks/train-ticket/ts-deployment-part1.yml)
(2) kubectl create -f <(istioctl kube-inject -f /benchmarks/train-ticket/ts-deployment-part2.yml)
(3) kubectl create -f <(istioctl kube-inject -f /benchmarks/train-ticket/ts-deployment-part3.yml)
(4) kubectl apply  -f /benchmarks/train-ticket/trainticket-gateway.yaml
```

## To Run
Make sure all pods in all namespaces are running without error or being evicted.

## Workload Generation
We utilize the [Locust](https://locust.io/) load testing tool, an open-source tool that employs Python code to define user behaviors and simulate millions of users.
The generated workload intensity varied over time, emulating typical characteristics of microservice workloads, including slight increases, slight decreases, sharp increases, sharp decreases, and continuous fluctuations. The flow data simulation script is stored in the [file](https://github.com/SYSU-Workflow-Administrator/DeepScaler/blob/main/sendFlow/random-100max.req).


The script [load_generator.py](https://github.com/SYSU-Workflow-Administrator/DeepScaler/blob/main/sendFlow/load_generator.py) is for simulating user behavior for both "Bookinfo" and "Online-Boutique" and [load_generator_train.py](https://github.com/SYSU-Workflow-Administrator/DeepScaler/blob/main/sendFlow/load_generator_train.py) is for simulating user behavior for "Train-Ticket."

Simulate the workload generator:
``` 
sh sendFlow/sendLoop.sh
```

You can refer to this [webpage](https://blog.techbridge.cc/2019/05/29/how-to-use-python-locust-to-do-load-testing/) for customized usage.

## Model Configuration
The information that needs to be configured before model training is stored in [config/train_config.yaml](https://github.com/SYSU-Workflow-Administrator/DeepScaler/blob/main/config/train_config.yaml), and the processed data sets and various model configuration information are stored in [config/train_datasets_speed.yaml](https://github.com/SYSU-Workflow-Administrator/DeepScaler/blob/main/config/train_datasets_speed.yaml). You can modify the tuning parameters yourself.


## Train and Test
1. Collect the original dataset including cpu usage, mem usage, response time, requests/s and pods.
```
template = {
    "cpu":"sum(irate(container_cpu_usage_seconds_total{{container=~'{1}',namespace=~'{0}'}}[1m]))/sum(container_spec_cpu_quota{{container=~'{1}',namespace=~'{0}'}}/container_spec_cpu_period{{container=~'{1}',namespace=~'{0}'}})",
    "mem": "sum(container_memory_usage_bytes{{namespace='{0}',container='{1}'}}) / sum(container_spec_memory_limit_bytes{{namespace='{0}',container='{1}'}})",
    "res": "sum(rate(istio_request_duration_milliseconds_sum{{reporter='destination',destination_workload_namespace='{0}',destination_workload='{1}'}}[{2}]))/sum(rate(istio_request_duration_milliseconds_count{{reporter='destination',destination_workload_namespace='{0}',destination_workload='{1}'}}[{2}]))/1000",
    "req": "sum(rate(istio_requests_total{{destination_workload_namespace='{0}',destination_workload='{1}'}}[{2}]))",
    "pod": "count(container_spec_cpu_period{{namespace='{0}',container='{1}'}})"
}
```
Run this code, and the data will be stored in the folder location you have set.
```
python metrics_fetch.py
```
```
#Here's "Online-Boutique" example:
prefix_api = "http://localhost:30090/api/v1/query?query="
namespace = 'boutiquessj'
interval = 120
services = ["adservice", "cartservice", "checkoutservice","currencyservice","emailservice","frontend","paymentservice","productcatalogservice","recommendationservice","shippingservice"]
metrics = ['cpu','res','req','mem','pod']
```
2. Process the dataset: Transform the raw dataset into a time-sliced dataset for model training and learning. 

```
python data_process.py
```
You can modify the storage location and monitoring time periods to generate the train, valid, and test datasets with a distribution of 50% for training, 25% for validation, and 25% for testing.

3. Export the well-trained model

We provide a more detailed and complete command description for training and testing the model:

```
python -u main.py
--model_config_path <model_config_path>
--train_config_path <train_config_path>
--model_name <model_name>
--num_epoch <num_epoch>
--num_iter <num_iter>
--model_save_path <model_save_path>
--max_graph_num <max_graph_num>
```

| Parameter name    | Description of parameter       |
|-------------------|--------------------------------|
| model_config_path | Config path of models          |
| train_config_path | Config path of Trainer         |
| model_name        | Model name to train            |
| num_epoch         | Training times per epoch       |
| num_iter          | Maximum value for iteration    |
| model_save_path   | Model save path                |
| max_graph_num     | Volume of adjacency matrix set |

More parameter information please refer to main.py.


## Autoscaling

Utilizing well-trained and tested models to enable automatic scaling of various microservices.

```
python predict_scale.py
```

## Evaluation

Analyze the similarity between the original graph relationship and od, cc.

```
python similarity.py
 ```

Compute relevant metrics.

```
python calculate.py
```





