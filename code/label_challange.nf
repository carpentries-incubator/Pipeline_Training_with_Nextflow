process ML_things {
    label 'tensorflow'

    output:
        stdout

    """
    #!/usr/bin/env python
    import tensorflow as tf
    print("TensorFlow version:", tf.__version__)
    """
}

process python_things {
    label 'python'

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
    ML_things().view()
    python_things().view()
}
