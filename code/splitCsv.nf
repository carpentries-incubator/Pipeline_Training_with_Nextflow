Channel
    .from( 'alpha,beta,gamma\n10,20,30\n70,80,90' )
    .splitCsv()
    .view()

Channel
    .fromPath( 'test.csv' )
    .splitCsv()
    .view()
