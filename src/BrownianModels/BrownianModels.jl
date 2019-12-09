module BrownianModels

using Phylodendron2

include("simulate.jl")
export
	simulate_bm

include("rel.jl")
export
	calc_llh!,
	init_model!,
	optimise_v!,
	phylip_llh

end