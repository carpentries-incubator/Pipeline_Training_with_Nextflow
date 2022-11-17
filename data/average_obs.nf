params.data_dir = 'observations'



obs = Channel.fromPath('${params.data_dir}/*.dat')

process get_meta {
    // Convert an input file into a stream with meta data
    // output will be [frequency, point, file]
    input:
    file(obs)

    output:
    tuple (env(FREQ), env(POINT), file(obs))

    script:
    """
    FREQ=\$(grep -e "#freq:"  ${obs} | awk '{print \$2}')
    POINT=\$(grep -e "#point:"  ${obs} | awk '{print \$2}')
    """
}

process combine_pointings {
    input:
    

    script


}

process ML_thing {
    input:
    file candidates

    script:
    """
    for \${f} in ${candidates}; do
        ml_one_core \${f} &
    done
    """
}

workflow {
    // create metadata
    get_meta(obs)
    // collect all the files for a single freq
    by_freq = get_meta.out.groupTuple(by:0).view()
    // 
}