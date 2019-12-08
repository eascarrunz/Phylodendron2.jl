using Phylodendron2, Phylodendron2.BrownianModels, Test
using DelimitedFiles
include("src/BrownianModels/reml.jl")

llhlist = readdlm("data/BrownianModels/llh_phylip.txt", header=true)[1]

i = 1

ft, fdm, ref_llh_fixedv, ref_llh_optimv = llhlist[i, :]

dm = read_species_data("data/BrownianModels/" * fdm, Float64);
k = size(dm, 2)
tree = read_newick("data/BrownianModels/" * ft)[1]
tree.dir = dm.dir
setspecies!(tree)
init_model!(tree, dm, true)
llh_fixedv = calc_llh!(tree, 1)
phylip_llh(tree, 1)


sum(filter(! isnan, map(x-> sum(x.datablocks[1].llh), preorder_vector(tree))))