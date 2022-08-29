source = Channel.from( ['obs1', 'obs1.dat'], ['obs2', 'obs2.dat'] )
target = Channel.from( ['obs1', 'obs1_cand1.dat'], ['obs1', 'obs1_cand2.dat'], ['obs1', 'obs1_cand3.dat'], ['obs2', 'obs2_cand1.dat'] , ['obs2', 'obs2_cand2.dat'] )

source.cross(target).view()