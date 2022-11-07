params.message = "hello world"

process make_file {
    output:
        file "message.txt"

    """
    echo "${params.message}" > message.txt
    """
}

process echo_file {
    input:
        file message_file
    output:
        stdout

    """
    cat ${message_file} | tr '[A-Z]' '[a-z]'
    """
}

workflow {
   make_file()
   echo_file(make_file.out).view()
}