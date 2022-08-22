---
title: "Nextflow Basics"
teaching: 10
exercises: 5
questions:
-
keypoints:
-
---

# What is Nextflow?
According to its website:
"[Nextflow](https://www.nextflow.io/) enables scalable and reproducible scientific workflows using software containers. It allows the adaptation of pipelines written in the most common scripting languages.

Its fluent DSL simplifies the implementation and the deployment of complex parallel and reactive workflows on clouds and clusters."


# Documentation
The documentation for Nextflow can be found [here](https://www.nextflow.io/docs/latest/index.html) and is an excellent resource. I have included links to the relevant sections of the documentation in the headers of this tutorial's sections. There is also a [basic patterns](https://nextflow-io.github.io/patterns/index.html#_basic_patterns) which has examples or basic pipeline problems which can be very useful for beginners. You can also ask for help on the [Nextflow slack channel](https://www.nextflow.io/slack-invite.html).

<!-- Talk about all of the above again but in the context of Nextflow. -->
# Nextflow components
Pipelines can be described using flowcharts.
Nextflow takes advantage of this by only requiring you to describe the parts of the flow chart, and Nextflow will put the pipeline together for you.

In the following sections, we shall describe the basic components of Nextflow to give you an understanding of the pipeline building blocks.
The following is a simple example of how the components work together to create a pipeline.

![pipeline_nextflow](../fig/pipeline_nextflow.png){: .width="400"}

## Simple script
Here is a simple example of a script called `hello_world.nf`

```
params.message = "hello world"

process make_file {
    output:
        file "message.txt"

    """
    echo "${params.message}" > message.txt
    """
}

process echo_file {
    input:
        file message_file
    output:
        stdout

    """
    cat ${message_file} | tr '[a-z]' '[A-Z]'
    """
}

workflow {
   make_file()
   echo_file(make_file.out).view()
}
```
{: .language-javascript}

This script has two simple processes.
The first writes a variable to a file, then hands that file to the second process, which capitalises it and outputs it to the terminal.
You can execute this script on the command line using:

```
nextflow run hello_world.nf
```
{: .language-bash}

Which will output:

```
N E X T F L O W  ~  version 22.03.1-edge
Launching `hello_world.nf` [romantic_linnaeus] DSL2 - revision: 1298655152
executor >  local (2)
[8a/8f3033] process > make_file [100%] 1 of 1 ✔
[72/4df67e] process > echo_file [100%] 1 of 1 ✔
HELLO WORLD
```
{: .output}

You can see that each process is run once and outputs the capitalised message to the terminal.


## [Process](https://www.nextflow.io/docs/latest/process.html)
Documentation: https://www.nextflow.io/docs/latest/process.html
A process is a job you would like to include in your pipeline.
It is written in bash by default and can have inputs and outputs.

Here is the syntax:

```
process < name > {

   [ directives ]

   input:
    < process inputs >

   output:
    < process outputs >

   when:
    < condition >

   [script|shell|exec]:
   < user script to be executed >

}
```
{: .language-javascript}

By default, the process will be executed as a bash script, but you can easily add the languages shebang to the first line of the script.
For example, you could write a python process like so:

```
process pythonStuff {
    """
    #!/usr/bin/python

    x = 'Hello'
    y = 'world!'
    print(f"{x} {y}")
    """
}
```
{: .language-javascript}


## [Channel](https://www.nextflow.io/docs/latest/channel.html)
Often files or variables are handed to and from processes. Think of them as the arrows in a flow diagram.

You can create channels of values using `of`:

```
ch = Channel.of( 1, 3, 5, 7 )
ch.view { "value: $it" }
```
{: .language-javascript}

which will output:

```
value: 1
value: 3
value: 5
value: 7
```
{: .output}

You can create channels of files using `fromPath`:

```
myFileChannel = Channel.fromPath( '/data/some/bigfile.txt' )
```
{: .language-javascript}

or with wildcards:

```
myFileChannel = Channel.fromPath( '/data/big/*.txt' )
```
{: .language-javascript}


## [Operators](https://www.nextflow.io/docs/latest/operator.html#)
Each row of a channel will spawn its own job for each process, and you can use
[Operators](https://www.nextflow.io/docs/latest/operator.html#) to manipulate channels to create your desired pipeline.


Channel manipulation is likely the most challenging part of Nextflow, so we will go through some of the most useful operators and use them for progressively more complicated examples.


### [flatten](https://www.nextflow.io/docs/latest/operator.html#flatten) and [collect](https://www.nextflow.io/docs/latest/operator.html#collect)
You can use `flatten` to turn a channel into a single column that will spawn one job each or `collect` to spawn a single job with all files.
Here is an example to show this:

```
process make_files {
   output:
   file "file*.txt"

   """for i in \$(seq 3); do touch file_\${i}.txt; done"""
}

process each_file {
   echo true

   input:
   file each_file

   """echo 'I have each file: ${each_file}'"""
}

process all_files {
   echo true

   input:
   file all_files

   """echo 'I have all files: ${all_files}'"""
}

workflow {
   make_files()
   each_file(make_files.out.flatten().view{"flatten: $it.baseName"})
   all_files(make_files.out.collect().view{"collect: $it.baseName"})
}
```
{: .language-javascript}

Which will output:
```
N E X T F L O W  ~  version 22.03.1-edge
Launching `channels.nf` [boring_magritte] DSL2 - revision: d6c334a8a0
executor >  local (5)
[2d/daa992] process > make_files    [100%] 1 of 1 ✔
[b8/de87b0] process > each_file (3) [100%] 3 of 3 ✔
[9d/c5d625] process > all_files     [100%] 1 of 1 ✔
flatten: file_1
collect: [file_1, file_2, file_3]
flatten: file_2
flatten: file_3
I have all files: file_1.txt file_2.txt file_3.txt

I have each file: file_1.txt

I have each file: file_2.txt

I have each file: file_3.txt
```
{: .output}

The `view` operator shows how the `flatten` and `collect` operators transformed the channels, and the output of the processes helps describe how many jobs are spawned.


### [map](https://www.nextflow.io/docs/latest/operator.html#map)
Map is a useful transforming operator that you can use to apply a function to each item in a channel.
Map functions are expressed using a closure which are curly brackets that allow us to pass code as arguments to a function.
For example, you could square all numbers in a channel like so:

```
Channel
    .from( 1, 2, 3, 4, 5 )
    .map { it * it }
    .view()
```
{: .language-javascript}
where `it` describes each item as `map` iterates over the channel. This will output:

```
1
4
9
16
25
```
{: .output}

### [groupTuple](https://www.nextflow.io/docs/latest/operator.html#grouptuple)
`groupTuple` is used to group channel items with the same key, which is the first item by default.

For example:
```
Channel
     .from( [1,'A'], [1,'B'], [2,'C'], [3, 'B'], [1,'C'], [2, 'A'], [3, 'D'] )
     .groupTuple()
     .view()
```
{: .language-javascript}
```
[1, [A, B, C]]
[2, [C, A]]
[3, [B, D]]
```
{: .output}

Here is a full example that shows how you can group files by their file name:
```
process make_files {
   output:
   file "file*.txt"

   """
   for i in \$(seq 3 ); do
       for j in \$(seq 3 ); do
           touch file_\${i}_s_\${j}.txt
       done
   done
   """
}

process grouped_files {
   echo true

   input:
   file grouped_files

   """echo 'I have grouped files: ${grouped_files}'"""
}

workflow {
   make_files()
   grouped_files(
       // Label the files with their prefix
       make_files.out.flatten().map{ it -> [it.baseName.split("_s_")[0], it ] }.view().\
       // Group the files by this prefix
       groupTuple().map { it -> it[1] })

}
```
{: .language-javascript}
```
N E X T F L O W  ~  version 19.07.0
Launching `channel_grouping.nf` [mad_payne] - revision: 57e54acb49
executor >  local (4)
[75/658db0] process > make_files        [100%] 1 of 1 ✔
[1f/acc9e2] process > grouped_files (3) [100%] 3 of 3 ✔
[file_1, /home/nick/code/nextflow_tutorial/work/75/658db0b849f97a10550148f917bb9c/file_1_s_1.txt]
[file_1, /home/nick/code/nextflow_tutorial/work/75/658db0b849f97a10550148f917bb9c/file_1_s_2.txt]
[file_1, /home/nick/code/nextflow_tutorial/work/75/658db0b849f97a10550148f917bb9c/file_1_s_3.txt]
[file_2, /home/nick/code/nextflow_tutorial/work/75/658db0b849f97a10550148f917bb9c/file_2_s_1.txt]
[file_2, /home/nick/code/nextflow_tutorial/work/75/658db0b849f97a10550148f917bb9c/file_2_s_2.txt]
[file_2, /home/nick/code/nextflow_tutorial/work/75/658db0b849f97a10550148f917bb9c/file_2_s_3.txt]
[file_3, /home/nick/code/nextflow_tutorial/work/75/658db0b849f97a10550148f917bb9c/file_3_s_1.txt]
[file_3, /home/nick/code/nextflow_tutorial/work/75/658db0b849f97a10550148f917bb9c/file_3_s_2.txt]
[file_3, /home/nick/code/nextflow_tutorial/work/75/658db0b849f97a10550148f917bb9c/file_3_s_3.txt]
I have grouped files: file_2_s_1.txt file_2_s_2.txt file_2_s_3.txt

I have grouped files: file_1_s_1.txt file_1_s_2.txt file_1_s_3.txt

I have grouped files: file_3_s_1.txt file_3_s_2.txt file_3_s_3.txt
```
{: .output}

You can see that this example makes nine files, then assigns a key based on their file name before `_s_` and launches a job for each key.

### [concat](https://www.nextflow.io/docs/latest/operator.html#concat)
The `concat` operator concatenates items from two or more channels to a new channel in the same order they were specified in.

For example:
```
a = Channel.from('a','b','c')
b = Channel.from(1,2,3)
c = Channel.from('p','q')

c.concat( b, a ).view()
```
{: .language-javascript}
```
p
q
1
2
3
a
b
c
```
{: .output}

Here is an example of combining the output of two processes and grouping them by their filename.

```
process make_files_one {
   output:
   file "file*.txt"

   """for i in \$(seq 3); do touch file_\${i}_s_one.txt; done"""
}

process make_files_two {
   output:
   file "file*.txt"

   """for i in \$(seq 3); do touch file_\${i}_s_two.txt; done"""
}


process grouped_files {
   echo true

   input:
   tuple file(first_file), file(second_file)
   """echo 'I have ${first_file} and ${second_file}'"""
}

workflow {
   make_files_one()
   make_files_two()
   grouped_files(
       // Label the files with their prefix
       make_files_one.out.flatten().map{ it -> [it.baseName.split("_s_")[0], it ] }.\
       // Concat them with the other process
       concat(make_files_two.out.flatten().map{ it -> [it.baseName.split("_s_")[0], it ] }).\
       // Group the files by this prefix
       groupTuple().map { it -> [ it[1][0], it[1][1] ] })
}
```
{: .language-javascript}

```
N E X T F L O W  ~  version 21.04.3
Launching `channel_tuples.nf` [stoic_liskov] - revision: 79877921ac
executor >  local (5)
[b2/7e78a1] process > make_files_one    [100%] 1 of 1 ✔
[bc/285fad] process > make_files_two    [100%] 1 of 1 ✔
[bc/da6cc3] process > grouped_files (1) [100%] 3 of 3 ✔
I have file_2_s_one.txt and file_2_s_two.txt

I have file_3_s_one.txt and file_3_s_two.txt

I have file_1_s_one.txt and file_1_s_two.txt
```
{: .output}


## Variable
Variables are easy to declare and similar to other languages.
You should treat variables as constants as soon as the pipeline begins.
If the variable is job-dependent, you should turn it into a channel.

You can use `params.<some_variable>` to define command line arguments.
This is very useful for specifying where input files are or other constants.
The equivalent command line argument uses two dashes like so `--<some_variable>`
(two dashes are for pipeline variables and single dashes are for Nextflow variables like `-resume`).

For example:
```
params.input_dir = "/home/default/data/directory/"

myFileChannel = Channel.fromPath( '${params.input_dir}/*csv' )
```
{: .language-javascript}

This will create a channel of all the CSV files in `/home/default/data/directory/` by default, but this can also be changed by using
```
nextflow run example.nf --input_dir /some/other/directory/
```
Will instead use the CSVs in `/some/other/directory/`

If something is constant throughout the pipeline, you can leave it as a variable.
One example could be some sort of observation identifier or date:


```
params.observation_id = 'default1234'

process make_files {
   output:
   file "*.txt"

   """for i in \$(seq 3); do touch ${observation_id}_\${i}_s_one.txt; done"""
}
```
{: .language-javascript}

You can see we're labelling the output files with the observation ID for all jobs.


## Workflow
A workflow is a collection of processes that can help make your pipelines very modular.
You are probably familiar with the unnamed workflow, which can be thought of as the main workflow for that script.
You can create additional workflows in the format:

```
workflow workflow_name {
    take:
        some_channel
        another_channel
    main:
        foo(some_channel)
        bar(another_channel)
    emit:
        foo.out
        bar.out
}
```
{: .language-javascript}
where `take` is the input channels, `main` are the workflow processes and `emit` is the output channels.

You can split your pipeline into several workflows to help them become more modular.
For example, you may have a module for processing raw data and another for searching for the processed data for a signal.
You can use these workflows in several scripts that only process the raw data, search for a signal, or do both.

Here is an example where we have a `process_module.nf` which contains a workflow called `process`, and we want to combine it with another workflow:

```
// import the workflow from the process_module.nf file
include { process } from './process_module'

workflow search {
    take: processed_data
    main:
        find_signal(processed_data)
        filter_cands(find_signal.out)
    emit:
        filter_cands.out
}

workflow {
    take: data
    main:
        process(data)
        search(process.out)
}
```
{: .language-javascript}

## Configuration
The configuration (normally held within the nextflow.config file) describes all the machine-dependent aspects of the pipeline.
Use it to set up how you want to run your pipeline on your machine.

Some things you can setup up:
- If you want to run it locally or on a job queue like SLURM
- Max number of jobs to run at once
- Where to put the output files
- How much resources do you want each job to use (CPUs and RAM)
- If you don't have a software dependency installed, you can tell Nextflow which container to use.

This can all be done within the `nextflow.config` file.

Here is an example for running on a local machine:

```
// What local resources Nextflow can use
executor {
    name = 'local'
    queueSize = 2
    CPUs = 6
    memory = 24G
}
// The container name to use for all processes
process.container = 'paulhancock/Robbie-next:latest'
docker {
    enabled = true
    temp = 'auto'
    runOptions = '--user "$(id -u):$(id -g)"'
}
// You can set how to run a program. If this wasn't on the path, you could give the command to the full path "python /home/code/stilts"
params.stilts = "stilts"
```
{: .language-javascript}

Here is an example for a supercomputer:
```
// set up how processes are run
process {
    withLabel: 'gpu|cpu|cpu_large_mem' {
        // all jobs with the able labels will be launched to the SLURM queue and request 1 CPU
        executor = 'slurm'
        CPUs = 1
    }
    withLabel: GPU {
        queue = 'gpuq'
        memory = "10 GB"
    }
    withLabel: CPU {
        queue = 'workq'
        memory = "10 GB"
    }
    withLabel: cpu_large_mem {
        queue = 'workq'
        memory = "100 GB"
    }
    cache = 'lenient' // helps with shared file systems
}

// Maximum number of jobs to put on the queue
executor.$slurm.queueSize = 1000

// Always load this module
process.module = 'singularity/3.7.4'
// Singularity set up
singularity {
    enabled = true
    runOptions = '--nv -B /nvmetmp'
    envWhitelist = 'SINGULARITY_BINDPATH, SINGULARITYENV_LD_LIBRARY_PATH'
}

// Where you put the singularity files
params.containerDir = '/pawsey/mwa/singularity'
// The version of software module on container to use
params.software_version = 'v1.2'
// Where to run the Nextflow jobs
workDir = "/Astro/mwavcs/${USER}/${params.obsid}_work"

// Some other defaults for this machine, in this example they are software benchmarks
params.bm_read  =  1.000
params.bm_cal   =  0.091
params.bm_beam  =  0.033
params.bm_write =  0.390
```
{: .language-javascript}
