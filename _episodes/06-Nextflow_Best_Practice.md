---
title: "Nextflow Best Practices"
teaching: 10
exercises: 5
questions:
-
keypoints:
-
---
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
The example help aslo includes the `-w` which is a Nextflow param, not a user declared param, explaining some of these can be useful for users that aren't familiar with some of Nextflows arguments.

## Explaining your operators

TODO

## Making modular workflows
As you create several large pipelines, parts of your pipelines may be used in several places.
To prevent having duplicate code which is harder to maintain, you can make your workflows modular.
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
Retrying something without changing anything and expecting different results will lead you to insanity.
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

In the above example we have used a closure (curly brackets) to give more memory to the process for each attempt.
So the process will ask for 10 GB, then 20 GB and finally 30 GB and if the job still fails with 30 GB then it stops the pipeline and outputs the error.

