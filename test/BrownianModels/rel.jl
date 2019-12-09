using DelimitedFiles: readdlm
llhlist = readdlm("../data/BrownianModels/llh_phylip.txt", header=true)[1];

@testset "Reference likelihoods" begin
	for i in 1:size(llhlist, 1)
		ft, fdm, ref_llh_fixedv, ref_llh_optimv = llhlist[i, :];

		dm = read_species_data("../data/BrownianModels/" * fdm, Float64);
		tree = read_newick("../data/BrownianModels/" * ft)[1]
		tree.dir = dm.dir;
		setspecies!(tree)

		init_model!(tree, dm, true)
		llh_fixedv = calc_llh!(tree, 1)
		@test ≈(ref_llh_fixedv, phylip_llh(tree, 1), atol = 0.01)
		delete_datablock!(tree, 1)
		pluck_nonsplitting!(tree)
		init_model!(tree, dm, true)
		calc_llh!(tree, 1)
		@test ≈(llh_fixedv, calc_llh!(tree, 1))

		init_model!(tree, dm, false)
		optimise_v!(tree, 2, niter = 5)
		llh_optimv = calc_llh!(tree, 2)
		@test llh_optimv ≥ llh_fixedv
		if ! isnan(ref_llh_optimv)
			@test ≈(phylip_llh(tree, 2), ref_llh_optimv, rtol=1)
		end
	end
end

