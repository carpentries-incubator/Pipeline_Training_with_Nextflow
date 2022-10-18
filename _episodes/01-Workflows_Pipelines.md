---
title: "Workflows and Pipelines"
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
## What is a workflow?
A workflow is a sequence of tasks that are executed to reach a desired goal.
Workflows exist for humans to follow (eg, recipes for making pancakes) and for machines to follow (eg, scripts for turning tables into plots).
The key features of a workflow are:
- inputs
- activity
- outputs or results

As humans that cook you are probably familiar with the following sort of workflow (a.k.a [recipe](https://vivashop.org.uk/products/winter-wonderland-recipe-guide)):
![RecipeWorkflow]({{page.root}}{% link fig/Recipe.png %})

And as an astronomer you can appreciate the following [flow-chart](https://ui.adsabs.harvard.edu/abs/2019PASA...36...46H/abstract), or decision tree, which takes input from an alert service, performs some checks and calculations to determine if action is needed, and results in either action or inaction:

![AstronomerWorkflow]({{page.root}}{% link fig/VOeventWF.png %})

In research we live with a combination of the two types of workflows.
We have a high level understanding of the research workflow, for example:
- Exploring what is known
- Formulation of an hypothesis
- Collecting data
- Analyzing data
- Testing hypothesis
- Publishing results

Sadly this high level workflow isn't automated and each of the steps are rather vague so we need to adapt and refine it for each project.
At a low level, there are many tasks that you do in your research that are (very nearly) the same every time you do them, and these are the tasks that you can automate.
The end goal of this workshop is to show you how to turn join all of your small automated tasks into larger and larger workflows.
However, to begin with we need to start thinking with a **workflow mindset**.

## Developing a workflow mindset
Let's start with a very generic workflow such as the one below, which takes two data sources as input, does a bunch of (pre)processing of these data, and then generates some science (as indicated by the conical flask).
![pipeline_initial]({{page.root}}{% link fig/pipeline_initial.png %}){: width="700"}

Working with a workflow mindset means we need to identify the following:
1. What is the desired output, outcome, or result?
2. What information is required to generate this output/outcome/result?
3. What actions need to be performed to map (2) to (1)?

Initially we start with a high level workflow with not much detail, but as we start to refine our goals, we refine our inputs.
This in turn means that we need to have a better idea of how we map our inputs to outputs, which in turn may require that we rethink our goals or add additional input requirements.

> ## Describe a workflow
> Think about some research work that you have done, are doing, or plan to do and:
> - Describe the desired outcome/output/result
> - Describe the information/data/resources that you think you might need
> 
> Draw a three stage diagram which has a single box as your "task".
> 
> Now think about how you can break this box into smaller linked pieces such that you have a more detailed map of how to get from inputs to outputs.
> > ## Example
> > Initial plan - make a map of my path home with weather info so I know if I should take a coat/umbrella.
> > ![FlowV1]({{page.root}}{% link fig/FlowV1.png %}){: witdth='600'}
> > Thinking a bit more about the data that I need and what is readily available I refine my inputs, and make some more detailed tasks about fetching existing data.
> > Similarly, I refine my outputs because I realize that an animated rain map would be more useful than a static one.
> > My plan is now:
> > ![FlowV2]({{page.root}}{% link fig/FlowV2.png %}){: witdth='600'}
> {: .solution}
> Take some time to make make a workflow for yourself, and then share with people near you.
> Use a fancy drawing program if you like but `PaperPencilV1.0` will also work just fine.
> 
{: .challenge}

> ## Follow the arrows
> In the figures that we have been viewing, there are arrows that link inputs to tasks, tasks to other tasks, and tasks to outputs.
> What do these arrows represent to you?
> 
> Are they:
> 1. an indication of precedent / order / dependency
> 2. the flow of information / data / files
>
> If you said (1) then could can you determine what information needs to be passed between the different stages and in what format?
> 
> Do the diagrams produced by people answering (1) differ from those produced by people answering (2)?
> 
{: .discussion}

## An automated workflow
If a user manually executes each job, this is still a pipeline, but we should aim to automate as many of our pipelines as possible to save time.
As pipelines grow, they often become complicated. It can be challenging to do the following:
- Keep the pipeline clear, readable and maintainable
- Track errors and rerun failed jobs
- Benchmark jobs to find bottlenecks
- Handle dependencies such as containers
- Stop a pipeline, then resume where it left off

To help with the above, it is best your use a pipeline language, such as Nextflow, to develop your pipelines.
