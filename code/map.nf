Channel
    .from( [1,'A_B'], [2,'B_C'], [3,'C_D'])
    .map { it -> [ it[0], it[0] * it[0], it[1].split("_")[0], it[1].split("_")[1] ] }
    .view()
