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


