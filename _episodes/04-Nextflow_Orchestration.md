---
title: "Building a Pipeline"
teaching: 10
exercises: 5
questions:
-
keypoints:
-
---
##


# Channel manipulation

## Process details
### [Label](https://www.nextflow.io/docs/latest/process.html#label)
You can label your process, which is a useful way to group your processes that need a similar configuration.
For example, you could label all processes that require a particular container or need a lot of memory like so:

```
process bigTask {
  label 'big_mem'

  """
  <task script>
  """
}
```
{: .language-javascript}

We will explain how to take advantage of labels in the Nextflow Configuration lesson.

### [publishDir](https://www.nextflow.io/docs/latest/process.html#publishdir)
publishDir is used to output files to a directory outside the Nextflow work directory.
For example:

```
process for {
    publishDir '/home/data/'

    output:
    file 'science.data'

    '''
    echo "Some Science" > science.data
    '''
}
```
{: .language-javascript}

This will output the science.data file to /home/data