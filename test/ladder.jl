@testset "Ladderise" begin
	tree = Tree(parse_newick("(((A,B),C),(D,(E,F)));"))
	ladderise!(tree)
	@test newick_string(tree) == "((C,(A,B)),(D,(E,F)));"
	ladderise!(tree, :left)
	@test newick_string(tree) == "(((A,B),C),((E,F),D));"
end