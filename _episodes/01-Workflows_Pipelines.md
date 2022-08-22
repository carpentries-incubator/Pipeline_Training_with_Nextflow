---
title: "Nextflow Basics"
teaching: 10
exercises: 5
questions:
-
keypoints:
-
---

<!-- Talk about how much of the work that we do for research can be thought of in terms of a workflow or pipeline, how this can be visualised as a flowchart, and how we break things into blocks of work to be done, information/data that is passed between the blocks, and some optional flow control. -->

<!-- Get people thinking about how data move through this workflow (a data driven workflow). -->

<!-- Do a small exercise where people take some of their own work and map out a basic workflow, defining the tasks and what data flows between them -->
# What is a pipeline?
A pipeline is a sequence of jobs that are executed to process data.
Pipelines are often first planned out using flow charts to determine what order the tasks need to be performed, the dependencies, and the inputs and outputs.

![pipeline_initial](../fig/pipeline_initial.png){: .width="400"}

If a user manually executes each job, this is still a pipeline, but we should aim to automate as many of our pipelines as possible to save time.
As pipelines grow, they often become complicated. It can be challenging to do the following:
- Keep the pipeline clear, readable and maintainable
- Track errors and rerun failed jobs
- Benchmark jobs to find bottlenecks
- Handle dependencies such as containers
- Stop a pipeline, then resume where it left off

To help with the above, it is best your use a pipeline language, such as Nextflow, to develop your pipelines.
