process python_location {
    output:
        stdout
    """
    #!/usr/bin/env python
    import os
    import sys

    print(os.path.realpath(sys.executable))
    """
}

workflow {
    python_location()
    python_location.out.view()
}