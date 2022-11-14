data = Channel.fromPath( ['obs1.dat', 'obs2.dat'] )
candiates = Channel.fromPath( ['obs1_cand1.dat', 'obs1_cand2.dat', 'obs1_cand3.dat', 'obs2_cand1.dat', 'obs2_cand2.dat'] )

// Use map to get an observation key
data = data.map { it -> [ it.baseName, it ] }
candiates = candiates.map { it -> [ it.baseName.split("_")[0], it ] }
// Cross the data
data.cross(candiates)
    // Reformat to desired output
    .map { it -> [ it[0][0], it[0][1], it[1][1] ] }.view()
