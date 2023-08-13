# DeepScaler: Holistic Autoscaling for Microservices Based on Spatiotemporal GNN with Adaptive Graph Learning

![Static Badge](https://img.shields.io/badge/python-3.6-blue) ![Static Badge](https://img.shields.io/badge/PyTorch-red) 

## Overview
This repository contains a prototyped version of DeepScaler described in our ASE '23 paper "DeepScaler: Holistic Autoscaling for Microservices Based on Spatiotemporal GNN with Adaptive Graph Learning".


## Requirements
+   Python 3.6
+   matplotlib == 3.5.2
+   numpy == 1.21.5
+   pandas == 1.4.4
+   torch == 1.13.1


Dependencies can be installed using the following command:

```
pip install -r requirements.txt
```


## Configuration

The information that needs to be configured before model training is stored in config/train_config.yaml, and the processed data sets and various model configuration information are stored in config/train_datasets_speed.yaml. You can modify the tuning parameters yourself.

## Data

Arranged in chronological order, the raw data encompasses a variety of key metrics for each microservice, including CPU utilization, response time, and Pod replica count. These crucial raw datasets are stored in the data/raw folder. However, before commencing model training, a series of preprocessing steps need to be applied to these raw datasets to transform them into time-slice data suitable for training the model.

This preprocessing procedure encompasses several stages, one of which involves executing the xxx.py script. This script converts the raw data into a more workable format, facilitating the effective execution of subsequent model training. The preprocessed data resulting from this procedure will be directed to the data/processed folder, serving as input for the forthcoming model training process.

Step 1: Simulate the load generator

Raw data needs to send flow to simulate real user data

``` 
sh sendFlow/sendLoop.sh
```

Step 2: Collect the original dataset

```
python metrics_fetch.py
```

Step 3: Process the dataset

```
python prepareData.py
```

## Train and Test

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





