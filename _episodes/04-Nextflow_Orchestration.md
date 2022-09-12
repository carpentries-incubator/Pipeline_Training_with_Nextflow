---
title: "Nextflow Orchestration"
teaching: 10
exercises: 5
questions:
-
keypoints:
-
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
{: .language-javascript}

In this example you can see the `bigTask` has the label 'big_mem' and `gpuTask` has the label 'gpu' which we will use in the cofiguration to give request a job with a lot of memory and a GPU respectively.
Both processes have the 'numpy' label which can be used to make sure a numpy software dependancy is loaded for that job, either natively or through a container.


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
{: .language-javascript}

Then tried to run a script `test_config.nf` which contained:
```
println("test1: " + params.test1)
println("test2: " + test2)
```
{: .language-javascript}

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


