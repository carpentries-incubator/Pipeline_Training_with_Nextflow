---
title: "Nextflow Orchestration"
teaching: 40
exercises: 20
questions:
- How do I run pipelines on supercomputing clusters?
- How do I use containers in my pipeline?
objectives:
- Set up a config that will tell Nextflow how to run on a supercomputer
keypoints:
- All computer dependant settings should be put in the nextflow.config
- You can use labels to define process dependancies and resource requirements
- You can easily use containers in nextflow pipelines
---
# Working locally and on supercomputing clusters
The pipelines we have created so far are only ready to be run on a local desktop or laptop.
This is because by default the [executor](https://www.nextflow.io/docs/latest/executor.html) is "local" which basically means it is run in the same place the pipeline is launched.
You can see what executor you are using in the output of your pipleines:
```
executor >  local (2)
```
{: .output}

Nextflow gives you the flexibility that you can run your pipelines locally, using cloud computing ([AWS](https://www.nextflow.io/docs/latest/executor.html#aws-batch), [Azure](https://www.nextflow.io/docs/latest/executor.html#azure-batch), etc.) or on a supercomputer ([SLURM](https://www.nextflow.io/docs/latest/executor.html#slurm), [PBS](https://www.nextflow.io/docs/latest/executor.html#pbs-torque), etc.) without major changes to the pipeline. This is done by changing the [Nextflow configuration](https://www.nextflow.io/docs/latest/config.html) based on where you want to run the pipeline.

We will show you how to create these `nextflow.config` files but first it is best to understand labels.


## [Configuration](https://www.nextflow.io/docs/latest/config.html)
When a Nextflow script is launched, it will look for configuration files in multiple locations.
It does this because it uses the following ranked system to decided which configuration to use when they are declared multiple times:

1. Parameters specified on the command line (`--something value`)
2. Parameters provided using the `-params-file` option
3. Config file specified using the `-c my_config` option
4. The config file named `nextflow.`config` in the current directory
5. The config file named `nextflow.config` in the workflow project directory
6. The config file `$HOME/.nextflow/config`
7. Values defined within the pipeline script itself (e.g. `main.nf`)

So for example if you set `params.obsid = 10` in the `nextflow.config` file it will use this by default but you can overide it by using
`--obsid 20` on the command line to overide it because it is higher on the priority ranking.
Having these defaults in multiple files can be a bit confusing and hard to maintain so we recomend you put as much as possible in a well organised and commented `nextflow.config` file.


### nextflow.config syntax
Comments in the config file are the same as in Groovy or Java so you can use `//` for single lines and `/*`..`*/` for multiple line comments.

You can use declare values as you would in other scripts, but to use them outside of the config file you must use `params.`.
For example, if I made a `nextflow.config` file with the following:
```
//Something that can be used outside of the config and changed on the command line
params.test1 = 'nextflow.config'
// Something that can't
test2 = 'nextflow.config'
```
{: .language-groovy}

Then tried to run a script `test_config.nf` which contained:
```
println("test1: " + params.test1)
println("test2: " + test2)
```
{: .language-groovy}

Running it would output:
```
N E X T F L O W  ~  version 22.03.1-edge
Launching `test_config.nf` [scruffy_dijkstra] DSL2 - revision: 4e20ed9967
test1: nextflow.config
No such variable: test2

 -- Check script 'test_config.nf' at line: 2 or see '.nextflow.log' file for more details
```
{: .output}

As you can see it is able to find `params.test1` from the configuration file but not `test2`

The configuration is organised into different scopes which can be accesed using a dot prefix or grouping using curly brackets.
For example I can set the executor as local and only run up to two jobs at once (queueSize) either by:

```
executor.name = 'local'
executor.queueSize = 2
```
{: .language-groovy}
or
```
executor {
    name = 'local'
    queueSize = 2
}
```
{: .language-groovy}


## [Containers](https://www.nextflow.io/docs/latest/container.html#)
Nextflow supports a variatey of containers but we will focus on Docker and Singularitry (Apptainer) containters.

To test that these Nextflow is using a container, we will make a simple script that outputs the location of the python executable:

> ## `container.nf`
> ~~~
> process python_location {
>     output:
>         stdout
>     """
>     #!/usr/bin/env python
>     import os
>     import sys
>
>     print(os.path.realpath(sys.executable))
>     """
> }
>
> workflow {
>     python_location()
>     python_location.out.view()
> }
> ~~~
> {: .language-groovy}
{: .callout}

If you run this script before loadin containters you should see an output like this:
```
N E X T F L O W  ~  version 22.03.1-edge
Launching `container.nf` [mad_ardinghelli] DSL2 - revision: 661db7f1f7
executor >  local (1)
[4d/d0b2f0] process > python_location [100%] 1 of 1 ✔
/home/nick/installed_software/anaconda3/bin/python3.9
```
{: .output}

You can see that my python executable is located at `/home/nick/installed_software/anaconda3/bin/python3.9`


### [Docker](https://www.nextflow.io/docs/latest/container.html#docker)
For our docker test image we shall [python](https://hub.docker.com/_/python) and to make it clear that the image has a different python version we will use v3.3.5.
To do this add the following to your `nextflow.config`

> ## `nextflow.config`
> ~~~
> process.container = 'python:3.3.5'
> docker.enabled = true
> ~~~
> {: .language-groovy}
{: .callout}

If you have Docker installed and setup you should be able to rerun `container.nf` and Nextflow will download the image for you and use it:
```
N E X T F L O W  ~  version 22.03.1-edge
Launching `container.nf` [shrivelled_lorenz] DSL2 - revision: 661db7f1f7
executor >  local (1)
[d7/701e56] process > python_location [100%] 1 of 1 ✔
/usr/local/bin/python3.3
```
{: .output}

You can see the v3.3 python executable is being used.

### [Singularity](https://www.nextflow.io/docs/latest/container.html#singularity)
Singularity (recently renamed as Apptainer) is designed for HPC usage so it is not worth installing on your local machine.
You can load Singularity on Pawsey using:
```
module load singularity/3.7.4
```
{: .language-bash}

and on Ozstar using:
```
module load apptainer/latest
```
{: .language-bash}

Using a singularity image is similar to Docker but you must point to the Singularity container file:
> ## `nextflow.config`
> ~~~
> process.container = '/path/to/singularity.img'
> singularity.enabled = true
> ~~~
> {: .language-groovy}
{: .callout}

If you have many containers of your dependancies with multiple versions you may want to organise all versions of a dependancy into a single directory like so:
```
.
├── presto
│   ├── development.img
│   └── latest.img
└── python
    ├── 3.3.img
    └── 3.7.img
```


### [Label](https://www.nextflow.io/docs/latest/process.html#label)
You can label your process, which is a useful way to group your processes that need a similar configuration.
You can give multiple processes the same label and you can give a process multiple labels.

The two most common label uses are for to group process that have the same software dependancies and resource requirements.
For example, you could label all processes that require a particular container or need a lot of memory or a GPU like so:

```
process bigTask {
  label 'big_mem'
  label 'numpy'

  """
  <task script>
  """
}

process gpuTask {
  label 'gpu'
  label 'numpy'

  """
  <task script>
  """
}
```
{: .language-groovy}

In this example you can see the `bigTask` has the label 'big_mem' and `gpuTask` has the label 'gpu' which we will use in the cofiguration to give request a job with a lot of memory and a GPU respectively.
Both processes have the 'numpy' label which can be used to make sure a numpy software dependancy is loaded for that job, either natively or through a container.

## Setting up process configuration based on labels
Lets say your pipeline wants to run on a supercomputer that uses the SLURM scheduler and you have some jobs that are memory intensive and some that aren't.
Because you're a responsible supercomputer user, you want to set up your jobs so that they request the memory that you require so you've labeled your processes with either `small_mem` or `large_mem`.
You can set this up in the `nextflow.config` like so

```
// This is under the process scope
process {
    // The withLabel will apply the following to only the labeled processes
    // The | can be treated as an OR when you want to use multiple labels
    withLabel: 'small_mem|large_mem' {
        // Common setup for both labels
        executor = 'slurm'
        queue = 'workq'
        cpus = 1
    }
    withLabel: small_mem {
        // Small memory request
        memory = "2 GB"
    }
    withLabel: large_mem {
        // Large memory request
        memory = "32 GB"
    }
    // This advised for all pipelines running on a shared file system (most supercomputers)
    cache = 'lenient'
}
```
{: .language-groovy}


In a similar what you can set up how Nextflow loads dependancies, say for a Python singularity image and software called presto that can be loaded using `module`.

```
process {
    withLabel: python {
        container = '/path/to/containter/python/3.7.img'
    }
    withLabel: preto {
        beforeScript "module load presto"
    }
}
```
{: .language-groovy}

Where [beforeScript](https://www.nextflow.io/docs/latest/process.html#beforescript) runs before the process which makes it ideal for loading the required software.

> ## Challenge part 1
> Create a workflow in which the process `ML_things` is run using the container `tensorflow/tensorflow:latest`, and another process `python_things` is run using the container `python:3.8.5`.
> Give these two processes a label, and then use the `process` scope in a `nextflow.config` file to set the containers for each to use.
>
> > ## Solution
> > TODO
> {: .solution}
{: .challenge}

> ## Challenge part 1
> Modify your `nextflow.config` so that the processes that use the tensorflow containers run on an HPC queue called `gpuq` and those that use the python container run on a queue called `workq`.
>
> > ## Solution
> > TODO
> {: .solution}
{: .challenge}


## [Config profiles](https://www.nextflow.io/docs/latest/config.html#config-profiles)
You can create sets of configuration attributes called profiles.
These can be used declare a set up based on your current system:

```
profiles {

    local {
        process.executor = 'local'
        params.basedir = '~'
    }

    pawsey {
        process.executor = 'slurm'
        params.basedir = '/astro'
    }

    ozstar {
        process.executor = 'slurm'
        params.basedir = '/fred'
    }

}
```
{: .language-groovy}

And then declared on runtime like so:

```
nextflow run <your script> -profile pawsey
```
{: .language-bash}

They are also useful if you have some standard parameters that you don't want to have to type out every time.
```
profiles {
    big_job {
        params.ncals = 10000
        params.resolution = 0.1
        process.memory = "32 GB"
    }
    quick_job {
        params.ncals = 10
        params.resolution = 5
        process.memory = "2 GB"
    }
}
```
{: .language-groovy}

## An alternative to profiles
It can be annoying to always having to declare the profile you want to use on the command line.
Instead you can make a default based on the `$HOSTNAME` environment variable which is normally consistent and only differs due to which of the log in nodes you have sshed into.
For example Pawsey's Garrawarla cluster is either `garrawarla-1` or `garrawarla-2` and Ozstar is either `farnarkle1` or `farnarkle2`.
So we can set up or `nextflow.config` like so:

```
// Remove the dashes because they break things later on
host = "$HOSTNAME".replace("-", "")

if ( host.startsWith("garrawarla") ) {
    // Put all your garrawarla set up here

    process {
        withLabel: 'small_mem|large_mem' {
            executor = 'slurm'
            queue = 'workq'
            cpus = 1
        }
        withLabel: small_mem {
            memory = '2 GB'
        }
        withLabel: large_mem {
            memory = '32 GB'
        }
        cache = 'lenient'
    }
}
elif ( host.startsWith("ozstar") ) {
    // Put all your ozstar set up here
}
else {
    // No cluster hostname so assume you are running this locally
    process.executor = 'local'

}
```
{: .language-groovy}