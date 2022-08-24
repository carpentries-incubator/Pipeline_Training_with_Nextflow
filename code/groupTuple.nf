Channel
    .fromPath("file_*_s_*.txt")
    // Create a prefix key and file pair
    .map{ it -> [it.baseName.split("_s_")[0], it ] }.view{"step 1  : $it"}
    // Group the files by this prefix
    .groupTuple().view{"step  2 : $it"}
    // Remove the key so it can be easily input into a process
    .map{ it -> it[1] }.view{"step   3: $it"}