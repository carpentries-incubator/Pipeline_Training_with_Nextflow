---
title: "Nextflow Workflows"
teaching: 10
exercises: 5
questions:
-
keypoints:
-
---
# How to run a Nextflow pipeline

Nextflow pipelines are launched from the command line like so:

```
nextflow run hello_world.nf
```
{: .language-bash}

You can also put your Nextflow pipelines on your PATH and treat them as you would other executables as long as they have the following shebang:
```
#!/usr/bin/env nextflow

```
{: .language-javascript}

With that running your pipeline becomes as easy as
es are launched from the command line like so:

```
hello_world.nf
```
{: .language-bash}

Which will have the output:
```
N E X T F L O W  ~  version 22.03.1-edge
Launching `/home/nick/code/Nextflow_Training_2022B/code/hello_world.nf` [jolly_descartes] DSL2 - revision: 582ccc5833
executor >  local (2)
[94/4b9b86] process > make_file [100%] 1 of 1 ✔
[88/adf190] process > echo_file [100%] 1 of 1 ✔
HELLO WORLD
```
{: .output}
You can see from the output that the location of the script is shown next to `Launching`.

## Using terminal multiplexers

Nextflow pipelines do not run in the background by default, so it is best to use a terminal multiplexer if running a long pipeline.
Terminal multiplexers allow you to have multiple windows within a single terminal window.
The benefit of these for running Nextflow pipelines is that you can detach from these terminal windows and reattach them later (even through an ssh connection) to check on the pipeline's progress.

The two most common terminal multiplexers are `screen` and `tmux`. We advise using `tmux` when possible as it is just as easy to use and has some [excellent features](https://www.howtogeek.com/671422/how-to-use-tmux-on-linux-and-why-its-better-than-screen/) but will also explain how to use `screen`.

### Tmux

Installing `tmux` on Ubuntu is as easy as running:

```
sudo apt-get install tmux
```
{: .language-bash}

You can start a tmux session by simply running:

```
tmux
```
{: .language-bash}

![tmux_0](../fig/tmux_0.png){: .width="400"}

We are now in a `tmux` session which has been named 0. By default, `tmux` will number your sessions from 0.
You can access the `tmux` commands by pressing `Ctrl+b`.
To kill the session, you can use `Ctrl+d` or `Ctrl+b` then `x`.
To detach from the screen, use `Ctrl+b` then `d`.

To reattach to the screen using the command:

```
tmux attach-session -t <session_name>
```
{: .language-bash}

So for our session:

```
tmux attach-session -t 0
```
{: .language-bash}

Using the default numbered names will quickly get confusing, so we should give our sessions meaningful names instead.
For example, if you want to launch a download job, you could make a named session with:

```
tmux new -s download
```
{: .language-bash}

![tmux_download](../fig/tmux_download.png){: .width="400"}

You can see at the bottom of the screen that we are now on a session called download.
We can detach (with `Ctrl+b` then `d`) and reattach (with `tmux attach-session -t download`), and you will still see the same display as when you detached.

You can now make several sessions with different names and switch back and forth between them to check the progress of your pipelines.

### Screen
`screen` is similar to `tmux`, so we will quickly go over the equivalent commands.

To make a named session use:

```
screen -S <screen_name>
```
{: .language-bash}

There isn't a bar at the bottom of your new session like in `tmux`, so you will have to remember if you're within a session or not.
To perform screen commands, you first press `Ctrl+a` then to detach and click `d`.

Then you can reattach it with
```
screen -r <screen_name>
```
{: .language-bash}


## Where are each of these jobs running?
Nextflow jobs are all run within a work directory.
By default, the work directory is `./work` but it can be altered by setting
```
workDir = "/data/dir/for/work"

```
{: .language-javascript}

in the `nextflow.config` file or on the command line with `-w /data/dir/for/work`.

For each job that nextflow runs, it will create a subdirectory and run the job there.
Let's use one of the outputs of our simple `hello_world.nf` script as an example:

```
N E X T F L O W  ~  version 22.03.1-edge
Launching `/home/nick/code/Nextflow_Training_2022B/code/hello_world.nf` [nostalgic_kare] DSL2 - revision: 582ccc5833
executor >  local (2)
[23/9bf45d] process > make_file [100%] 1 of 1 ✔
[9d/9c5ecd] process > echo_file [100%] 1 of 1 ✔
HELLO WORLD
```
{: .output}
The characters on the left between the square brackets describe the most recent launched job for that process.
So if we want to investigate the `make_file` job, we can move into its subdirectory like so:

```
cd work/23/9bf45d111e14368b2438367f6813c2/
```
{: .language-bash}

Where I have copied `23/9bf45d` and then used the tab to complete the 30-character hex that Nextflow uses to create the subdirectory.
Let's see what is within the subdirectory:

```
ls
```
{: .language-bash}

```
message.txt
```
{: .output}
We can see the `message.txt` file we created in our process.
If we want to investigate the files that Nextflow creates, we must look at the hidden files:
```
ls -a
```
{: .language-bash}

```
.
..
.command.begin
.command.err
.command.log
.command.out
.command.run
.command.sh
.exitcode
message.txt
```
{: .output}

Let us go through what each of these files does:

.command.begin: This file is created once the job has begun (no longer in a queue)

.exitcode: Once the job has complete, this file will be created with the exit code (0 means finished successfully and other numbers are errors)

.command.out: The standard output (stdout) of the job

.command.err: The standard error (stderr) of the job

.command.log: Both the standard output and error of the job.
This file is very useful for debugging as it will contain all outputs of the code.
You can use `tail -f .command.log` to see what the job is outputting in real-time.

.command.sh: This is the code that your job is going to run.
It will look like the code from your process with all the values of your attributes.

.command.run: "Here there be monsters".
This file contains all the magic that Nextflow uses to run your job.
You do not have to understand what it is doing, but when using Nextflow on a supercomputing cluster, there are a few useful things in this file including:
the SLURM SBATCH commands in the header,
the modules you load,
and the container command (singularity or docker).



## How to debug a Nextflow Job

To explain how to debug Nextflow, let us make a simple Nextflow pipeline with an intentional error:

```
process python_job {
    output:
        stdout

    """
    #!/usr/bin/env python
    for i in range(3):
        print i
    """
}

workflow {
   python_job()
}
```
{: .language-javascript}

When I run this pipeline, Nextflow will output a verbose error message:

```
N E X T F L O W  ~  version 22.03.1-edge
Launching `error_check.nf` [loving_wescoff] DSL2 - revision: 44ac86534d
executor >  local (1)
executor >  local (1)
[28/ddb3ee] process > python_job [100%] 1 of 1, failed: 1 ✘
Error executing process > 'python_job'

Caused by:
  Process `python_job` terminated with an error exit status (1)

Command executed:

  #!/usr/bin/env python
  for i in range(3):
      print i

Command exit status:
  1

Command output:
  (empty)

Command error:
    File ".command.sh", line 3
      print i
            ^
  SyntaxError: Missing parentheses in call to 'print'. Did you mean print(i)?

Work dir:
  /home/nick/code/Nextflow_Training_2022B/code/work/28/ddb3ee0334146697ecdb5c0d6df039
Tip: you can replicate the issue by changing to the process work dir and entering the command `bash .command.run`
```
{: .output}

This gives you lots of useful information about the error, including which process caused the error, the command executed, the stderr and the work directory where the job was run.
Just looking at this error, you can likely see that the error was using the Python 2 print formatting instead of Python 3.
For such a simple example, you can likely make the fix and rerun the pipeline.
If this was a more involved pipeline that takes hours to run, it is best to confirm you have fixed the problem for this job before rerunning the whole pipeline.

To debug the job, we first move into the work directory, which for me is:
```
cd /home/nick/code/Nextflow_Training_2022B/code/work/28/ddb3ee0334146697ecdb5c0d6df039
```
{: .language-bash}

From here, we can edit the `.command.sh` file to fix the print bug like so:

```
#!/usr/bin/env python
for i in range(3):
    print(i)
```
{: .language-python}

You can then test that your fix works by running the job the same way that Nextflow does using the `.command.run` (not `.command.sh`) file like so:

```
bash .command.run
```
{: .language-bash}

Or, if you are on a supercomputer and using a resource manager, you will have to launch `.command.run` using their executor, which for SLURM is:

```
sbatch .command.run
```
{: .language-bash}

If you have fixed your job you should see the output:

```
0
1
2
```
{: .output}

Now that we are confident that we know how to fix the job, we can apply the same changes to the Nextflow pipeline and rerun the pipeline.


## Resuming pipelines

One of the benefits of Nextflow is that you can resume pipelines that were manually stopped or stopped due to an error.
We do this with the `-resume` argument.
Note that the `-resume` argument has only a single dash because it is a Nextflow argument, not a variable assigned in the pipeline.

Nextflow keeps track of all the processes executed in your pipeline.
If you modify some parts of your script, only the changed processes will be re-executed.
Executing the processes that are not changed will be skipped and the cached result used instead.

To cache a process, the pipeline must be resumed from the same directory.
This is because the `.nextflow/` directory is created where you run the pipeline and is used to record what processes have already been executed.

To make sure your pipeline is resumable, make sure you don't create any non-deterministic behaviour in your pipeline.
For this reason, you should avoid the `merge` and `mix` channel operators.

If we resume our previous example now that we have fixed the error:

```
nextflow run error_check.nf -resume
```
{: .language-bash}

```
N E X T F L O W  ~  version 22.03.1-edge
Launching `error_check.nf` [astonishing_kalam] DSL2 - revision: 1d0498de14
executor >  local (1)
[02/bb7b9f] process > python_job [100%] 1 of 1 ✔
```
{: .output}

You can see that it runs the process again because Nextflow knows it failed previously.
If we rerun it again:

```
N E X T F L O W  ~  version 22.03.1-edge
Launching `error_check.nf` [trusting_wing] DSL2 - revision: 1d0498de14
[02/bb7b9f] process > python_job [100%] 1 of 1, cached: 1 ✔
```
{: .output}

You can now see that instead of rerunning job, it cached the one job.