using Phylodendron2
using Test

@testset "Linking and unlinking" begin
	a = Node("A")
	b = Node("B")
	c = Node("C")
	d = Node("D")
	e = Node("E")

	br_ab = Branch()

	link!(a, b, br_ab)
	link!(a, c)
	link!(c, d)
	link!(c, e)

	@test length(a.links) == 2
	@test a.links[1].to == b
	@test a.links[2].to == c
	@test length(b.links) == 1
	@test b.links[1].to == a
	@test length(c.links) == 3
	@test c.links[1].to == a
	@test c.links[2].to == d
	@test c.links[3].to == e
	@test length(d.links) == 1
	@test d.links[1].to == c
	@test length(e.links) == 1
	@test e.links[1].to == c

	@test unlink!(a, b) == br_ab
	@test isempty(b.links)
	@test length(a.links) == 1
	@test a.links[1].to == c
end # testset "Linking and unlinking"