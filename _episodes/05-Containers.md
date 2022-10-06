---
title: "Containers"
teaching: 10
exercises: 5
questions:
-
keypoints:
-
---

## Goals
There are two main goals that we hope to achieve by using containers:
- Reproducibility, and
- Portability.

That is: given the same inputs, we want our workflow to produce the same outputs, on any computer, now and forever.
Anyone who has tried to run their workflow on multiple computers, upgrade their OS, or help a colleague to use your workflow, will no doubt understand just how hard this is.

![DogbertTechSupport](https://assets.amuniversal.com/3f3021d06d5c01301d80001dd8b71c47)


### Containers
Containerization is a way to bundle your software in such a way that you no longer have to deal with complex dependency chains, supporting multiple OSs, or software version conflicts.
Containers provide a way to package software in an isolated environment which may even have a different operating system from the host.

Containers are different from virtual machines (VMs) in a few key ways.
Using a virtual machine is like running your operating system on virtualized (think "simulated") hardware.
A VM will then run a guest operating system on this hardware, and thus needs all of the resources that an OS would need.
A VM will additionally contain all the software that you want to run within the guest operating system.
A container works by virtualizing the operating system instead of the hardware.
Thus a container doesn't need an entire operating system worth of data/config, but only the software that you want to run within that operating system.
A virtual machine will typically persist state/data between runs (for better or worse), whilst a container will not.
Each time you run a container you get that new car smell.

The two most popular containerization systems are [Singularity/Apptainer](https://apptainer.org/) and [Docker](https://www.docker.com/).
Docker is primarily used on computers where you have root access such as your laptop/desktop or a compute node in the cloud.
HPC facilities will not use Docker as it provides root access to the host system, and instead will use Singularity which does not.

The two systems are largely interoperable - you can build a Docker container on your desktop, test it out in your workflow, and then convert it to a Singularity image for use on your HPC facility of choice.
You can think of a container as a self container operating system which you can build with all the software that you need, which you can then deploy on any computer that you like.
In fact you don’t even need to know how to build the containers to use them as there are many available pre-built containers that you can use.
Both systems provide an online repository for storing built containers: Docker has [DockerHub](https://hub.docker.com/), while Singularity uses [Singularity Container Services (SCS)](https://cloud.sylabs.io/).

![DockerLogo]({{page.root}}{% link fig/Docker_logo.png%}){: width='100' align='left'} 
Docker is easy to build, and van use on any computer where you have root access.
Docker has clients for Linux, Windows, and MacOS, so it meets our portability requirement with ease.
There are a large number of ready made containers that you can use as a starting point for your own container, available on docker hub.
Often you don't even need to make your own container, you can just use an existing one right out of the box.
Docker requires that you have a docker service running to manage all the images.


![SingularityLogo]({{page.root}}{% link fig/Singularity.png%}){: width='100' align='left'}
Singularity easy to use and doesn’t require root access, but it's only available for Linux based machines.
Singularity images are stored as files which you can easily move from one system/location to another, and you don't need a service to be running in order to use the images.


Our recommendation is to use both of these solutions in conjunction: Docker to build/test/run containers on your local machine, and then Singularity to run containers on an HPC.
A really convenient feature of the two systems is that Docker containers can be converted into Singularity containers with minimal effort.
In fact, some smart cookie created [a docker container](https://quay.io/repository/singularity/docker2singularity?tab=tags&tag=latest), with singularity installed within, that will automatically convert your docker containers into singularity containers.
Therefore you don't even need to install Singularity on your local machine in order to produce singularity images.
