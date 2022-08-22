process python_job {
    output:
        stdout

    """
    #!/usr/bin/env python
    for i in range(3):
        print(i)
    """
}

workflow {
   python_job()
}