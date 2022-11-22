params.data_dir = "observations"



all_obs = Channel.fromPath("${params.data_dir}/*.dat")

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


process combine_frequencies {
    // Combine the files so the output has a single pointing with all the frequency information
    input:
    tuple (val(freqs), val(point), file(obs))

    output:
    tuple (val(point), file("obs*dat"))

    script:
    """
    cat ${obs} > obs_${freqs.join("_")}.dat
    """
}


process find_candidates {
    // Use a periodicity search to find events with significance above 6sigma
    input:
    tuple (val(point), file(obs))

    output:
    tuple (val(point), path("cand*dat"), optional: true)

    shell:
    '''
    #./find_periodic_cands.sh !{obs}

    # Random number from 0-3
    ncand=$(( $RANDOM % 4 ))
    echo $ncand
    for i in $(seq ${ncand}); do
        touch cand_${i}.dat
    done
    '''
}


process fold_cands {
    // Fold the candidates on the given period and measure properties
    // for example: SNR, DM, p, pdot, intensity
    input:
    tuple (val(point), file(obs), file(cand))

    output:
    tuple (val(point), file("*dat"))

    script:
    """
    touch ${point}_${cand.baseName}.dat
    """
}

process ML_thing {
    // apply a machine learning algorithm to take the folded data and predict
    // real (positve) or fake (negative) candidates
    publishDir "cands/", mode: 'copy'

    input:
        file candidates

    output:
        path("positive/*"), optional: true
        path("negative/*"), optional: true

    shell:
    '''
    mkdir positive
    mkdir negative
    for f in !{candidates}; do
        if [ $(( $RANDOM % 2 )) == 0 ]; then
            mv $f positive/
        else
            mv $f negative/
        fi
    done
    '''
}

workflow {
    // create metadata
    get_meta( all_obs )
    // collect all the files that have the same pointing
    same_pointing = get_meta.out.groupTuple( by: 1 )
    // Combine the frequencies so you have a single file with all frequencies
    combine_frequencies( same_pointing )
    // Look for periodic signals with an fft
    find_candidates( combine_frequencies.out )
    // tranpose will "flatten" the cands so they have the format [ key, cand_file ]
    flattened_cands = find_candidates.out.transpose()
    // For each candidate file pair it with observaton file
    cand_obs_pairs = combine_frequencies.out.cross(flattened_cands)
        //reformat to remove redundant key
        .map{ [ it[0][0], it[0][1], it[1][1] ] }
        // [ pointing, obs_file, candodate_file ]
    // Process the candidate
    fold_cands( cand_obs_pairs ).view()
    // Put the candidates through ML
    ML_thing( fold_cands.out.map{it[1]} )
}
