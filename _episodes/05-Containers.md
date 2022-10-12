---
title: "Containers"
teaching: 10
exercises: 5
questions:
- "What are containers?"
- "What is the difference between Docker and Singularity?"
- "How can I build containers?"
- "How can I share containers?"
keypoints:
-
---
<!--
Understand containers:
- What containers are and how they can be used on a PC or HPC
- The difference between Docker and Singularity
Work with containers:
- Build docker containers on a local machine
- Use docker hub to store containers
- Convert Docker -> Singularity on a local machine or via docker hub
- -->

## Goal
There are two main goals that we hope to achieve by using containers:
- Reproducibility, and
- Portability.

That is: given the same inputs, we want our workflow to produce the same outputs, on any computer, now and forever.
Anyone who has tried to run their workflow on multiple computers, upgrade their OS, or help a colleague to use your workflow, will no doubt understand just how hard this is.

![DogbertTechSupport](https://assets.amuniversal.com/3f3021d06d5c01301d80001dd8b71c47)


## Containers
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


## Using containers
There are a large range of pre-built containers available on [docker-hub](https://hub.docker.com/search?q=&image_filter=official).
These range from base operating systems like Ubuntu, Alpine, or Debian to application containers like redis, postgres or mysql, to language containers like python, java, or golang.
There is even a docker container for docker itself!

![DockerHub]({{page.root}}{% link fig/DockerHubExample.png %})

We will begin our journey by working with the "Hello World" docker container.

> ## Say hello world with docker
> ~~~
> $ docker run hello-world
> ~~~
> {: .language-bash}
> > ## Solution
> > ~~~
> > Unable to find image 'hello-world:latest' locally
> > latest: Pulling from library/hello-world
> > 2db29710123e: Pull complete 
> > Digest: sha256:62af9efd515a25f84961b70f973a798d2eca956b1b2b026d0a4a63a3b0b6a3f2
> > Status: Downloaded newer image for hello-world:latest
> > 
> > Hello from Docker!
> > This message shows that your installation appears to be working correctly.
> > 
> > To generate this message, Docker took the following steps:
> >  1. The Docker client contacted the Docker daemon.
> >  2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
> >     (amd64)
> >  3. The Docker daemon created a new container from that image which runs the
> >     executable that produces the output you are currently reading.
> >  4. The Docker daemon streamed that output to the Docker client, which sent it
> >     to your terminal.
> > 
> > To try something more ambitious, you can run an Ubuntu container with:
> >  $ docker run -it ubuntu bash
> > 
> > Share images, automate workflows, and more with a free Docker ID:
> >  https://hub.docker.com/
> > 
> > For more examples and ideas, visit:
> >  https://docs.docker.com/get-started/
> > ~~~
> > {: .output}
> {: .solution}
{: .challenge}

The `hello-world` container is very minimal and does only one thing.

We can be more adventurous and do interactive things with containers.
Let's start with the `ubuntu` container, which contains a naked install of Ubuntu.

> ## bash the container
> ~~~
> $ docker run -it ubuntu bash
> ~~~
> {: .language-bash}
> Explore the container system, look at what software/libraries are available.
> > ## Solution
> > ~~~
> > Unable to find image 'ubuntu:latest' locally
> > latest: Pulling from library/ubuntu
> > cf92e523b49e: Pull complete 
> > Digest: sha256:35fb073f9e56eb84041b0745cb714eff0f7b225ea9e024f703cab56aaa5c7720
> > Status: Downloaded newer image for ubuntu:latest
> > root@f13326d08c8a:/# 
> > ~~~
> > {: .output}
> {: .solution}
{: .challenge}

When we called `docker run` above we specified the `-it` options which are short for `--interactive` and `--tty` which means that we'll get an interactive container and a tty (shell-like) interface.
By calling the container name `ubuntu` followed by the command `bash` we will run the `bash` command within the container.
You'll see that your command line changes to something like `root@1234abc:/#`.
If you run a command like `apt list` or `ls /usr/bin` you'll see software/libraries that are available to you.
This ubuntu install is quite minimal and doesn't include any desktop features (it's not a VM!).

When we are working within a container we should be mindful that the contents of the container are ephemeral.
If we change any of the container contents while it's running, these changes will be lost when the container shuts down.
So whilst you could run the `ubuntu` container, install some software you wanted, and then run that software, you would need to reinstall it every time you ran the container.
We'll see how to build containers with the software that we require in the next section.

Containers are setup to be isolated from the host operating system, so that whilst you are within a container (eg you are running `docker -it ubuntu bash`) you cannot see your host operating system.
Any accidental/nefarious things you do within the container are "safe".
However, if you have a script that you want to run, let's call it `do_things.py`, and you want it to run with the version of Python inside a docker container you need to find some way to get that script from your local machine into the container.

There are two ways to go about this:
1. You can copy a file from your local machine into a (running) docker container using `docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH`
2. You can mount part of your local file system to a location within the container using `docker run --mount [OPTIONS] CONTAINER`

The first option can also be used to copy files *from* the container to your local machine.

The second option is often best when you are developing code that needs to run within the container because you can use your favorite IDE on your local machine to work on the files, and then run them within the container without having to constantly copy things back and forth.

> ## Mount a local directory into your container
>  `touch` a new file called `do_things.py` and add the following:
> ~~~
> #! /usr/bin/env python
> import socket
> print(f"Hello from {socket.gethostname()}")
> ~~~
> {: .language-python}
>
> Now run:
> ~~~
> docker run -it --mount type=bind,source="$(pwd)",target=/app python:3.8.5 bash
> ~~~
> {: .language-bash}
> Navigate to the `/app` directory and run `python do_stuff.py`
{: .challenge}

In the above exercise you should see that the host name is some random string of letters and numbers, which is (hopefully) different from your local machines name.
Note that when we are working inside the container we are working as `root`, which means we have *all the privelages*.
If you bind a local path to one inside the container, then you'll have `root` access to that path.
So it's a good idea not to mount `/` inside the container!
Being `root` user inside the container also means that any files which you create in the mounted directory will be owned by root on your local machine.
Having root privileges within the container is a big reason why you wont see docker being provided on an HPC.

###TODO
challenge to mount a directory within the container then run a given program without using `-it`
figure out the mount/bind terminology of the above and be consistent.


## Building (docker) containers
As well as using pre-made containers, you can build your own.
Whilst it's possible to build a container from scratch, it's recommended that you start with a base layer and then add in what you need.

Just like installing software on a linux distro
No interactive prompts (use install -y)
Containers are built in layers
Starting points can be found on hub.docker.com

~~~
FROM python:3.9

LABEL maintainer="Paul Hancock <paul.hancock@curtin.edu.au>"

# non-python dependencies
RUN apt update && \
    apt install -y openjdk-11-jdk swarp && \
    apt-get autoremove -y && \
    apt-get clean

# download a java library and make a wrapper script for it
RUN cd /usr/local/lib && wget http://www.star.bris.ac.uk/~mbt/stilts/stilts.jar && \
    cd /usr/local/bin && echo 'java -jar /usr/local/lib/stilts.jar "$@"' > /usr/local/bin/stilts && chmod ugo+x /usr/local/bin/stilts

# work in this directory
WORKDIR /tmp/build

# add files from the current directory in to the build directory (requirements.txt)
ADD . /tmp/build

# install python dependencies, with specific versions specified for longevity, and Robbie scripts
# using pip install . will break the shebang lines of some scripts so stick with python setup.py install
RUN pip install -r requirements.txt && \
    python setup.py install && \
    rm -rf /tmp/build

#  set the home directory to be /tmp
ENV HOME=/tmp
~~~
{: .language-docker}

Each RUN creates a new layer
Fewer layers are better
Changing one item means rebuilding the layer
Group layers



~~~
$ touch Dockerfile requirements.txt
$ docker build -t robbie:new .
...
~~~
{: .language-bash}
