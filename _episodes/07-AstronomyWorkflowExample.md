---
title: "Astronomy Workflow: Idea to Implementation"
teaching: 30
exercises: 30
questions:
- How do I develop a workflow from scratch?
objectives:
- Create a workflow from scratch and see ut run.
keypoints:
- 
---


## The idea
We wish to create a workflow which will process observing data from some telescope, find candidate pulsars, and then run a ML on these candidates to label them as confirmed or rejected.
Humans will then sort through the confirmed list to come up with a final decision on which are real and which are not.

The high level workflow therefore looks like this:

![Initial workflow]({{page.root}}{% link fig/AstroWFInitial.png%})

As we think more about how the processing will be done we come up with some intermediate steps for the tasks:

![Final workflow]({{page.root}}{% link fig/AstroWFFinal.png %})

In this final iteration we have indicated with arrows the dependencies of each task, but also where information needs to be passed.
For example the "fold data" task needs the multi-frequency data from the "compile" task, as well as the candidate pulsar details from the "find" task in order to do a more detailed measurement of the properties.

### Create a .config file
This will create a bunch of useful analysis for your pipeline run when it completes.
See [next lesson]({{page.root}}{% link _episodes/05-Nextflow_Orchestration.md %}) for more about configuration files.

> ## nextflow.config
> ~~~
> // turn on all the juicy logging
> trace.enabled = true
> timeline.enabled = true
> report.enabled = true
> dag {
>     enabled = true
>     file='dag.png'
> }
> ~~~
> {: .language-groovy}
{: .callout}