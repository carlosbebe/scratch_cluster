# Slurm Docker Project Technical Interview

This project presents a slurm cluster using docker containers.

* **Docker compose:** allows to create an environment from docker images previously built. Docker Composer will create containers as well an internal network to communicate the components.

* **SLURM:** It is a open-source cluster management and batch scheduler for linux hpc clusters.


## Project Content

### Overview

This implementation has been tested in mac OS 12.7.4 running the following component versions:

* **Docker:**           25.0.3
* **Docker Compose:**   2.24.6
* **SLURM:**            21.08.6.1
* **OS:**               Rocky Linux release 8.9 (Green Obsidian)

## Cluster Architecture

This graph depicts the slurm cluster architecture presented.

![Architecture](Architecture.png)

* **mysql:** Slurm database.
* **slurmdbd:** Slurm DataBase Daemon is in charge of recording accounting clusters information in a single database.
* **slurmctld:** Centralized manager that monitors resources and work.
* **slurmd:** Compute node daemon that waits for jobs, executes them and return the status. 
* **scratch_cluster_default:** Internal virtual network created by docker.

### Files

* **Dockerfile**

Contains the necessary commands to assemble a base image (slurm-cluster:rocky8). Essential packages installed via yum, 
slurm configuration and installation, user creation and basic system configuration.
* **docker-compose.yml**

In this YAML file the cluster architecture is define to be later deployed in containers. Five services are deployed: a mysql database, a slurmdb daemon, a slurmctld daemon and two slurmd services known as compute nodes. A **data** volume is create and shared throughout the loggin and compute nodes 
in order to execute jobs. Other volumes such as etc_munge and var_lib_mysql are also created.
* **slurm.conf** 

Predefined ASCII file that escribes general slurm configuration information: nodes, partitions etc.
* **slurmdbd.conf**

Predefined file containing SLurm Database Daemon configuration information. This file is to be located in the same directory as slurm.conf file.
* **start_services.sh** 

Once the containers are launched, this script will initiate relevant services within each container: sshd, munge, slurm services.

## Get Started 

* Clone the repository
```
git clone https://github.com/carlosbebe/scratch_cluster
```
* Create a sshk key pair
```
ssh-keygen -b 2048 -t rsa -f /Users/Carlos/scratch_cluster/id_rsa -q -N ""
```
* Build base rocky image
```
docker build -t slurm-cluster:rocky8 .
```
* Initiate docker composer
```
docker compose up -d
```
* Accessing the loggin node
```
docker exec -it slurmctld bash
docker exec -u carlos -it slurmctld bash
```

* Testing slurm
```
sinfo
srun hostname
```

* Other useful commands

```
docker-compose logs -f
docker ps
docker images
docker rmi -f 27a7f9a9ac17
docker system prune
docker exec slurmctld bash -c "`linux command"
docker compose stop
docker compose start
docker compose restart
```
## Additional Components that can be implemented

* High Availability
* slurmrestd 
* Monitoring system
* ldap authentication
* Security hardening: linux firewall, ssh, etc. 

