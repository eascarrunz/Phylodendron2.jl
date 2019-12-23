module BrownianModels

using Phylodendron2

include("simulate.jl")
export
	simulate_bm

include("rel.jl")
export
	v2brlength!,
	calc_llh!,
	init_model!,
	optimv!,
	phylip_llh

end