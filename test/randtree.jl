@testset "Random trees" begin
	tree = randtree(2, true)
	@test n_tip(tree) == 2
	@test n_node(tree) == 3
	@test isrooted(tree)
	tree = randtree(3)
	@test n_tip(tree) == 3
	@test n_node(tree) == 4
	@test ! isrooted(tree)
	tree = randtree(3, true)
	@test n_tip(tree) == 3
	@test n_node(tree) == 5
	@test isrooted(tree)
	for _ in 1:100
		tree = randtree(50)
		@test n_tip(tree) == 50
		@test n_node(tree) == 98
		@test ! isrooted(tree)
	end
	for _ in 1:100
		tree = randtree(50, true)
		@test n_tip(tree) == 50
		@test n_node(tree) == 99
		@test isrooted(tree)
	end
	tree = randtree(string.(1:34))
	@test n_tip(tree) == 34
	@test n_node(tree) == 66
	tree = randtree(SpeciesDirectory(string.(1:19)))
	@test n_tip(tree) == 19
	@test n_node(tree) == 36
end