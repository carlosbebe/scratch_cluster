### Slurm Docker Project

This project presents a slurm cluster using docker containers.

Docker compose allows us to create an environment from docker images previously built. Docker Composer will create containers as well an internal network to communicate the components.

## Slurm

SLURM stands for Simple Linux Utility for Resource Management. It is a open-source cluster management and batch scheduler for linux hpc clusters.

## Cluster Arquitecture


The compose file will run the following containers:

* mysql
* slurmdbd   
* slurmctld  
* (slurmd)node1 - Compute node.
* (slurmd)node2 - Compute node. 


## Building the Image

Build the image locally:

```console
docker build -t slurm-cluster:rocky8 .
docker compose up -d
docker exec -it slurmctld bash

docker-compose logs -f
docker ps
docker images
docker rmi -f 27a7f9a9ac17
docker system prune
docker build -t  .
```



```console
docker-compose stop
docker-compose start
```

```console
docker-compose restart
