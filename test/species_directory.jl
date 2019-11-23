@testset "Species directories" begin
	namelist = ["A", "A", "B", "C", "D", "E"]
	@test_throws Phylodendron2.SpeciesNameCollision SpeciesDirectory(namelist)
	namelist = ["A", "B", "", "C", "", "D", "E"]
	dir = SpeciesDirectory(namelist)
	@test length(dir) == 7
	@test_throws Phylodendron2.SpeciesNameCollision addspecies!(dir, "B")
	@test dir["B"] == 2
	@test dir["B", "C", "A"] == [2, 4, 1]
	@test_throws KeyError dir[""]
	addspecies!(dir, "F")
	addspecies!(dir)
	@test dir["F"] == 8
	@test length(dir) == 9
	delete!(dir, "E")
	@test dir["F"] == 7
	@test length(dir) == 8
	rename!(dir, "F", "Foo")
	@test dir.list[7] == "Foo"
	@test ! ("X" ∈ dir)
	@test "A" ∈ dir
	@test 3 ∈ dir
	@test ! (9 ∈ dir)
	@test_throws BoundsError 0 ∈ dir
end