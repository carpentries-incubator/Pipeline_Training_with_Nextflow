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

## Making modular workflows

## Error strategy
