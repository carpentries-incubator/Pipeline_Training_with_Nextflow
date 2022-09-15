---
title: "Introduction to Nextflow"
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


## Testing Nextflow commands
In the following sections we will go through several examples and we encourage you to copy and paste the code and have a play with it.
You can do this by either putting into a file and running that file using `nextflow run` or using `nextflow console`.
`nextflow console` is an interactive console which is great for testing out channel manipulations.
You can write on or more lines of code and press `Ctrl+r` to run it and see the output like so:

![nextflow_console](../fig/nextflow_console.png){: .width="400"}


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
myFileChannel.view()
```
{: .language-javascript}

which, as long as the file exists, will output:

```
/data/some/bigfile.txt
```
{: .output}

You can also use wildcards to collect files:

```
myFileChannel = Channel.fromPath( '/data/big/*.txt' ).view()
```
{: .language-javascript}

which could output someting like:

```
/data/some/example_1.txt
/data/some/example_2.txt
/data/some/example_3.txt
```
{: .output}


## Simple script

Let's dive right in and make a simple pipeline that will make a file then print the contents.
The flow chart for this pipeline will look like this:

![simple_script](../fig/simple_script.png){: .width="400"}

Here is how we would turn it into a pipeline as a script called `hello_world.nf`

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


## Why do we want to manipulate Channels?

Manipulating channels is the most difficult parts of Nextlflow but it allows us create any type of pipeline.
Each row of a channel will spawn its own job for each process, so the shape of the channel dictates how many jobs are launched and what inputs each job has.

So we have a channel of three files like so:
```
Channel.fromPath(['file_1.txt', 'file_2.txt', 'file_3.txt']).view()
```
{: .language-javascript}
```
/home/nick/code/Nextflow_Training_2022B/code/file_1.txt
/home/nick/code/Nextflow_Training_2022B/code/file_2.txt
/home/nick/code/Nextflow_Training_2022B/code/file_3.txt
```
{: .output}

We have three rows with one file each. So if we input this to a process it would create three jobs.
If we instead wanted to create a single job that has access to all three files we can use the [`collect`](https://www.nextflow.io/docs/latest/operator.html#collect) operator like so:
```
Channel.fromPath(['file_1.txt', 'file_2.txt', 'file_3.txt']).collect().view()
```
{: .language-javascript}
```
[/home/nick/code/Nextflow_Training_2022B/code/file_1.txt, /home/nick/code/Nextflow_Training_2022B/code/file_2.txt, /home/nick/code/Nextflow_Training_2022B/code/file_3.txt]
```
{: .output}
So now we have a single row of files. Just for fun, we can even use [`flatten`](https://www.nextflow.io/docs/latest/operator.html#flatten) to "flatten" them back to one file per row:

```
Channel.fromPath(['file_1.txt', 'file_2.txt', 'file_3.txt']).collect().flatten().view()
```
{: .language-javascript}
```
/home/nick/code/Nextflow_Training_2022B/code/file_1.txt
/home/nick/code/Nextflow_Training_2022B/code/file_2.txt
/home/nick/code/Nextflow_Training_2022B/code/file_3.txt
```
{: .output}

## Channel Manipulation Example

Let's see what this channel manipulation looks like in a full workflow:

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
   each_file(make_files.out.flatten())
   all_files(make_files.out.collect())
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
I have all files: file_1.txt file_2.txt file_3.txt

I have each file: file_1.txt

I have each file: file_2.txt

I have each file: file_3.txt
```
{: .output}

We can see from the process information that three instances of each_file was run:
```
[b8/de87b0] process > each_file (3) [100%] 3 of 3 ✔
```
{: .output}

Which had one file each:

```
I have each file: file_1.txt

I have each file: file_2.txt

I have each file: file_3.txt
```
{: .output}

And all_files ran once:

```
[9d/c5d625] process > all_files     [100%] 1 of 1 ✔
```
{: .output}

With access to all three files:

```
I have all files: file_1.txt file_2.txt file_3.txt
```
{: .output}





## [Operators](https://www.nextflow.io/docs/latest/operator.html#)
Now that we know how to make simple pipelines, lets delve into [Operators](https://www.nextflow.io/docs/latest/operator.html#) to manipulate channels to create your desired pipeline.


Channel manipulation is likely the most challenging part of Nextflow, so we will go through some of the most useful operators and use them for progressively more complicated examples.




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

You can use `map` to manipulate multi column rows in different ways:

```
Channel
    .from( [1,'A_B'], [2,'B_C'], [3,'C_D'])
    .map { it -> [ it[0], it[0] * it[0], it[1].split("_")[0], it[1].split("_")[1] ] }
    .view()
```
{: .language-javascript}
```
[1, 1, A, B]
[2, 4, B, C]
[3, 9, C, D]
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

This operator is often used to group files by their name.
So if we make some test files like so:

```
for i in \$(seq 3 ); do
    for j in \$(seq 3 ); do
        touch file_\${i}_s_\${j}.txt
    done
done
```
{: .language-bash}

We can use `map` to create a key based on the file name and then use `groupTuple` to group them together in any way you want.
For example we can group them by the name before "_s_":

```
Channel
    .fromPath("file_*_s_*.txt")
    // Create a prefix key and file pair
    .map{ it -> [it.baseName.split("_s_")[0], it ] }.view{"step 1: $it"}
    // Group the files by this prefix
    .groupTuple().view{"step 2: $it"}
    // Remove the key so it can be easily input into a process
    .map{ it -> it[1] }.view{"step 3: $it"}
```
{: .language-javascript}
```
step 1: [file_1, /home/nick/code/Nextflow_Training_2022B/code/file_1_s_1.txt]
step 1: [file_3, /home/nick/code/Nextflow_Training_2022B/code/file_3_s_3.txt]
step 1: [file_2, /home/nick/code/Nextflow_Training_2022B/code/file_2_s_2.txt]
step 1: [file_2, /home/nick/code/Nextflow_Training_2022B/code/file_2_s_3.txt]
step 1: [file_3, /home/nick/code/Nextflow_Training_2022B/code/file_3_s_1.txt]
step 1: [file_1, /home/nick/code/Nextflow_Training_2022B/code/file_1_s_3.txt]
step 1: [file_2, /home/nick/code/Nextflow_Training_2022B/code/file_2_s_1.txt]
step 1: [file_1, /home/nick/code/Nextflow_Training_2022B/code/file_1_s_2.txt]
step 1: [file_3, /home/nick/code/Nextflow_Training_2022B/code/file_3_s_2.txt]
step 2: [file_1, [/home/nick/code/Nextflow_Training_2022B/code/file_1_s_1.txt, /home/nick/code/Nextflow_Training_2022B/code/file_1_s_3.txt, /home/nick/code/Nextflow_Training_2022B/code/file_1_s_2.txt]]
step 2: [file_3, [/home/nick/code/Nextflow_Training_2022B/code/file_3_s_3.txt, /home/nick/code/Nextflow_Training_2022B/code/file_3_s_1.txt, /home/nick/code/Nextflow_Training_2022B/code/file_3_s_2.txt]]
step 2: [file_2, [/home/nick/code/Nextflow_Training_2022B/code/file_2_s_2.txt, /home/nick/code/Nextflow_Training_2022B/code/file_2_s_3.txt, /home/nick/code/Nextflow_Training_2022B/code/file_2_s_1.txt]]
step 3: [/home/nick/code/Nextflow_Training_2022B/code/file_1_s_1.txt, /home/nick/code/Nextflow_Training_2022B/code/file_1_s_3.txt, /home/nick/code/Nextflow_Training_2022B/code/file_1_s_2.txt]
step 3: [/home/nick/code/Nextflow_Training_2022B/code/file_3_s_3.txt, /home/nick/code/Nextflow_Training_2022B/code/file_3_s_1.txt, /home/nick/code/Nextflow_Training_2022B/code/file_3_s_2.txt]
step 3: [/home/nick/code/Nextflow_Training_2022B/code/file_2_s_2.txt, /home/nick/code/Nextflow_Training_2022B/code/file_2_s_3.txt, /home/nick/code/Nextflow_Training_2022B/code/file_2_s_1.txt]
```
{: .output}

You can see that in the final steps we have grouped our files and this channel is ready to be given to a process that will create three jobs with three files each.

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


## [splitCsv](https://www.nextflow.io/docs/latest/operator.html#splitcsv)
CSVs are excellent ways to input data to your pipeline or even to hand data between processes.
`splitCsv` can handle text and parse it to several rows:

```
Channel
    .from( 'alpha,beta,gamma\n10,20,30\n70,80,90' )
    .splitCsv()
    .view()
```
{: .language-javascript}
```
[alpha, beta, gamma]
[10, 20, 30]
[70, 80, 90]
```
{: .output}

You can also hand csv files directly to `splitCsv` which makes handling these files easy.
A test CSV can be created with:

```
echo alpha,beta,gamma > test.csv; echo 10,20,30 >> test.csv; echo 70,80,90 >> test.csv
```
{: .language-bash}

Then you can use the following operators to parse the CSV file:

```
Channel
    .fromPath( 'test.csv' )
    .splitCsv()
    .view()
```
{: .language-javascript}
```
[alpha, beta, gamma]
[10, 20, 30]
[70, 80, 90]
```
{: .output}


## [cross](https://www.nextflow.io/docs/latest/operator.html#cross)
The `cross` operator allows you to combine the items of two channels in such a way that the items of the source channel are emitted along with the items emitted by the target channel for which they have a matching key.
An example of when this is useful is when you need to launch a job for each pair of data files and candidates found in those data files.
For example if you had two channels, the first the data files for each observation and a second channel with all of the candidates, we can combined them by using the observation ID as a common key:

```
source = Channel.from( ['obs1', 'obs1.dat'], ['obs2', 'obs2.dat'] )
target = Channel.from( ['obs1', 'obs1_cand1.dat'], ['obs1', 'obs1_cand2.dat'], ['obs1', 'obs1_cand3.dat'], ['obs2', 'obs2_cand1.dat'] , ['obs2', 'obs2_cand2.dat'] )

source.cross(target).view()
```
{: .language-javascript}
```
[[obs1, obs1.dat], [obs1, obs1_cand1.dat]]
[[obs1, obs1.dat], [obs1, obs1_cand2.dat]]
[[obs1, obs1.dat], [obs1, obs1_cand3.dat]]
[[obs2, obs2.dat], [obs2, obs2_cand1.dat]]
[[obs2, obs2.dat], [obs2, obs2_cand2.dat]]
```
{: .output}

This can easily be maped to a process that will launch a job for each observation data file and candidate information.

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

