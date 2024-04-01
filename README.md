# Slurm Docker Project

This project presents a slurm cluster using docker containers.

* Docker compose: It allows to create an environment from docker images previously built. Docker Composer will create containers as well an internal network to communicate the components.

* SLURM: It stands for Simple Linux Utility for Resource Management. It is a open-source cluster management and batch scheduler for linux hpc clusters.


## Project Content
Docker Version: 25.0.3
Docker Compose Version: 2.24.6
SLURM Version: slurm-21-08-6-1
OS Version

* Dockerfile
* docker-compose.yml
+ slurm.conf 
+ slurmdbd.conf
+ start_services.sh 

## Cluster Architecture

The compose file will run the following containers:

* mysql:
  Slurm database.
* slurmdbd:
  Slurm DataBase Daemon is in change of recording accounting clusters information in a single database.
* slurmctld:
  It a centralized manager that monitors resources and work.
* slurmd:
  It is a compute that waits for jobs, executes them and return the status. 
* scratch_cluster_default: Internal Network

![Architecture](Architecture.png)

## Get Started 


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
