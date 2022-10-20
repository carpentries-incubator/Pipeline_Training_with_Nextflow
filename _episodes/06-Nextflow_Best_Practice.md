---
title: "Nextflow Best Practices"
teaching: 10
exercises: 5
questions:
-
keypoints:
-
---

## Separting your worflow from your config
While we have touched on this in the [Nextflow Orchestration]({{ page.root }}{% link _episodes/04-Nextflow_Orchestration.md %}) episode,
it is important to remember to keep anything that is computer specific in the `nextflow.config`.
This will ensure that your pipeline can be run on any computer (laptop, supercomputers or cloudcomputing) without having to edit the workflow script.
It is much easier for a user to edit the `nextflow.config` file to run the pipeline how they see fit.
It should also be a long term goal to make a single config/profile for each computer that can be used by many pipelines.

## Making a --help
Unlike Python, Nextflow doesn't have a module designed to help you create a `--help` so we have to do this manually.
You should write a help for all of your Nextflow scripts to make them easier to use.
Without a help, a user would have to read your script and config to find all of your params and guess how they're used.

The help should be put after your params are defined (most of this should be in your nextflow.config) and before any of your processes and calculations.
Here is a short example of `--help`:

```
params.input_file = example.data
params.use_thing = false

if ( params.help ) {
    help = """your_script.nf: A description of your script and maybe some examples of how
             |                to run the script
             |Required argurments:
             |  --input_file  Location of the input file file.
             |                [default: ${params.input_file}]
             |
             |Optional arguments:
             |  --use_thing   Do some optional process.
             |                [default: ${params.use_thing}]
             |  -w            The Nextflow work directory. Delete the directory once the processs
             |                is finished [default: ${workDir}]""".stripMargin()
    // Print the help with the stripped margin and exit
    println(help)
    exit(0)
}
```
{: .language-javascript}

As the above example shows you will have to manually indent your help (unless someone wants to share a nice trick?).
It can be helpful to split your help into difference sections such as "Required arguments" to let users know the bare minimum they need to include to get the script running.

You may have noticed that the defaults are declared with `$` (`[default: ${params.input_file}]`).
This is a good habit to get into as your defaults may change based on the configuration you are using so the help can be used to help remind yourself of your current defaults.
The example help aslo includes the `-w` which is a Nextflow param, not a user declared param. Explaining some Nextflow parmas these can be useful for users that aren't familiar with some of Nextflows arguments.

## Making your workflow easy to read and understand

### Use whitespace to improve readability.
Nextflow is not sensitive to whitespace which allows you to use indentation,
vertical spacing, new-lines, and increased spacing to improve code readability.

~~~
#! /usr/bin/env nextflow

// Tip: Separate blocks of code into groups with common purpose
//      e.g., parameter blocks, include statements, workflow blocks, process blocks
// Tip: Align assignment operators vertically in a block
params.label      = ''
params.input_list = ''
params.my_db      = '/path/to/database'

workflow {

    // Tip: Indent process calls
    // Tip: Use spaces around process/function parameters
    foo ( Channel.fromPath( params.input_list, checkIfExists: true ) )
    bar ( foo.out )
    // Tip: Use vertical spacing and indentation for many parameters.
    baz (
        Channel.fromPath( params.input_list, checkIfExists: true ),
        foo.out,
        bar.out,
        path( params.my_db, checkIfExists: true )
    )

}
~~~
{: .language-groovy}

### Use comments

Comments are an important tool to improve readability and maintenance.
Use them to:
- Annotate data structures expected in a channel.
- Describe higher level functionality.
- Describe presence/absence of (un)expected code.
- Mandatory and optional process inputs.

~~~
workflow comment_example {

    take:
    reads        // queue channel; [ sample_id, [ file(read1), file(read2) ] ]
    reference    // file( "path/to/reference" )

    main:
    // Quality Check input reads
    read_qc ( reads )

    // Align reads to reference
    if( params.run_type == 'common' ){
        common (
            read_qc.out.reads,
            reference
        )
        reads_ch = comon.out.bam
    } else if ( params.run_type == 'other' ) {
        other (
            read_qc.out.reads,
            reference
        )
        reads_ch = other.out.bam
    }
    reads_ch.view()

    emit:
    bam = reads_ch   // queue channel: [ sample_id, file(bam_file) ]

}

process example {

    input:
    // Mandatory
    tuple val(sample), path(reads)  // [ 'sample_id', [ read1, read2 ] ]: Reads in which to count kmers
    // Optional
    path kmer_table                 // 'path/to/kmer_table': Table of k-mers to count

    ...
}
~~~
{: .language-groovy}

### Name output channels

Output channels from processes and workflows can be named
using the `emit:` keyword, which helps readability.

~~~
process make_bam {

    ...

    output:
    tuple val(sample), path("*.bam"), emit: bam
    tuple val(sample), path("*.log"), emit: summary
    path "versions.yml"             , emit: versions

    ...
}

workflow bam {

    ...

    emit:
    output = make_bam.out.bam

}
~~~
{: .language-groovy}
## Further documentation
// TODO Paul

## Version metadata
// TODO Paul

## Making modular workflows
As you create several large pipelines, parts of your pipelines may be used in several places.
To prevent having duplicate code, which is harder to maintain, you can make your workflows modular.
To understand how to do this lets first look into the full format of a [workflow](https://www.nextflow.io/docs/latest/dsl2.html#workflow).

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

You may have noticed that the module include command (`include { process } from './process_module'`) is a relative directory call.
The easiest way to handle this, is keep all of your files within the same directory and add this directory to your `PATH`.

## Error strategy
By default, if a single job fails then Nextflow will stop your pipeline and output the error so you can investigate it.
This is not always the behaviour we require so Nextflow has some useful options of how to handle errors.
These options are the process directives [`errorStrategy`](https://www.nextflow.io/docs/latest/process.html#errorstrategy) and [`maxRetries`](https://www.nextflow.io/docs/latest/process.html#maxretries).

A simple way to use `errorStratgey` is to instruct it to ignore errors for the process like so:
```
process ignoreAnyError {
  errorStrategy 'ignore'

  script:
  <your command string here>
}
```
{: .language-javascript}

This will record any failures but not stops the pipeline.

You can retry processes using 'retry':

```
process retryIfFail {
  errorStrategy 'retry'

  script:
  <your command string here>
}
```
{: .language-javascript}

Which will retry the process once by default.
Some say insanity is doing the same thing and expecting a different result.
We can instead increase the number of retries and progressively give the process more resources (RAM).
```
process retryIfFail {
  errorStrategy 'retry'
  maxRetries 2
  memory { task.attempt * 10.GB}

  script:
  <your command string here>
}
```
{: .language-javascript}

In the above example we have used a closure (curly brackets) to calculate how much memory to give to each attempt.
So the process will ask for 10 GB, then 20 GB and finally 30 GB and if the job still fails with 30 GB then it stops the pipeline and outputs the error.


## nf-core
You can think of [nf-core](https://nf-co.re/) as place to store Nextflow piplines and modules the same way that Conda and PyPi store python modules.
While it is out of the scope of this workshop to go into nf-core in detail, it is useful to know about nf-core.
An end goal for many of your pipelines should be that they are easy to use, install and collaborate on.
Nf-core is an excellent place for your pipelines and modules (individual processes) to end up as they enforce best practices
which will help future astronomers spend less time creating pipelines and more time doing science.

![nf_core](../fig/nf_core.png){: .width="400"}