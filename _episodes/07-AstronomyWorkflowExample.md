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