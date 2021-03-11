# Define labelled nodes from A to T
a = Node("A")
b = Node("B")
c = Node("C")
d = Node("D")
e = Node("E")
f = Node("F")
g = Node("G")
h = Node("H")
i = Node("I")
j = Node("J")
k = Node("K")
l = Node("L")
m = Node("M")
n = Node("N")
o = Node("O")
p = Node("P")
q = Node("Q")
r = Node("R")
s = Node("S")
t = Node("T")

# Link them
link!(a, b, 4.465957012470789)
link!(b, c, 32.620624765198855)
link!(c, d, 3.3650512429729265)
link!(d, e, 7.263546792740656)
link!(e, f, 10.193537222701895)
link!(f, g, 28.38523219145209)
link!(f, h, 4.956537575274135)
link!(e, i, 11.855818691462021)
link!(i, j, 1.9066195090479867)
link!(j, k, 10.627409065542043)
link!(i, l, 16.331078235033235)
link!(i, m, 14.711619982982215)
link!(c, n, 28.28461325395832)
link!(n, o, 7.41317192325869)
link!(o, p, 11.35796124012394)
link!(o, q, 0.6669348982306939)
link!(n, r, 7.594073912870435)
link!(r, s, 22.386191336343458)
link!(r, t, 0.6063155522048979)

#= The resulting tree should have the following Newick string from A:
    "((((((G,H)F,((K)J,L,M)I)E)D,((P,Q)O,(S,T)R)N)C)B)A;"
=#

tree = Tree(a)
show(a)
show(tree)

@testset "Node properties" begin
    @test label(a) == "A"
    label!(a, "Foo")
    @test label(a) == "Foo"
    label!(a, "A")
    @test getspecies(a) == getspecies(b) == 0
    setspecies!(a, 1)
    @test getspecies(a) == 1
    annotate!(a, "Bootstrap", 0.95)
    @test annotation(a, "Bootstrap") == 0.95
    deannotate!(a, "Bootstrap")
    @test_throws KeyError annotation(a, "Bootstrap")
end

@testset "Branch properties" begin
    show(getbranch(a, b))
    @test brlabel(a, b) == ""
    brlabel!(a, b, "Branchiphoo")
    @test brlabel(a, b) == "Branchiphoo"
    brannotate!(a, b, "Bootstrap", 0.95)
    @test brannotation(a, b, "Bootstrap") == 0.95
    brdeannotate!(a, b, "Bootstrap")
    @test_throws KeyError brannotation(a, b, "Bootstrap")
    @test brlength(a, b) == 4.465957012470789
    brlength!(a, b, nothing)
    @test isnothing(brlength(a, b))
    brlength!(a, b, 4.465957012470789)
    @test_throws Phylodendron2.InvalidTopology brlength(a, e)
end

@testset "Subtree functions" begin
    @test n_node(tree) == 20
    @test n_node(c, n) == 7
    @test n_node(c, b) == 2
    @test n_node(h, f) == 19
    @test n_tip(tree) == 10
    @test n_tip(c, n) == 4
    @test n_tip(c, b) == 1
    @test n_tip(h, f) == 9
    @test n_branch(tree) == 19
    @test n_branch(c, n) == 6
    @test n_branch(c, b) == 1
    @test n_branch(h, f) == 18
    @test nodelabels(tree) == string.('A':'T')
    @test nodelabels(n, o) == ["O", "P", "Q"]
    @test tiplabels(tree) == ["A", "G", "H", "K", "L", "M", "P", "Q", "S", "T"]
    @test find_nonsplitting(tree) == [b, d, j]
    @test tips(tree) == [a, g, h, k, l, m, p, q, s, t]
    dir = SpeciesDirectory(tiplabels(tree))
    tree.dir = dir
    setspecies!(tree)
    @test n_species(tree) == 10
    @test n_species(c, n) == 4
    @test n_species(c, b) == 1
end

@testset "Species directories" begin
    dir = SpeciesDirectory(tiplabels(tree))
    @test dir.list == tiplabels(tree)
    @test length(dir.dict) == length(dir.list)
    tree.dir = dir
    setspecies!(tree)
end

@testset "Tree properties" begin
    @test label(tree) == ""
    label!(tree, "Tree")
    @test label(tree) == "Tree"
    @test origin(tree) == a
    root!(tree, c)
    @test isrooted(tree)
    @test origin(tree) == c
    unroot!(tree)
    @test ! isrooted(tree)
    @test origin(tree) == c
    origin!(tree, a)
    @test origin(tree) == a
    annotate!(a, "Posterior probability", 0.95)
    @test annotation(a, "Posterior probability") == 0.95
    deannotate!(a, "Posterior probability")
    @test_throws KeyError annotation(a, "Posterior probability")
end

@testset "Tree cloning" begin
    tree2 = clone(tree)
	@test tree ≢ tree2
	@test newick_string(tree) == newick_string(tree2)
	@test tree.origin ≢ tree2.origin
	@test tree.rooted == tree2.rooted
end

@testset "Peek topology" begin
    @test n_neighbour(Node()) == 0
    @test neighbours(Node()) == Node[]
    @test n_neighbour(a) == 1
    @test neighbours(a) == [b]
    @test istip(a)
    @test areneighbours(a, b)
    @test n_neighbour(b) == 2
    @test neighbours(b) == [a, c]
    @test ! istip(b)
    @test areneighbours(b, a)
    @test areneighbours(b, c)
    @test ! areneighbours(b, d)
    @test n_neighbour(n) == 3
    @test neighbours(n) == [c, o, r]
    @test n_neighbour(i) == 4
    @test neighbours(i) == [e, j, l, m]
end

@testset "Traversals" begin
    @testset "Preorder" begin
        @test preorder_vector(tree) ==
            [a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t]
        @test preorder(tree) ==
            [
                (a, a),(a, b),(b, c),(c, d),(d, e),(e, f),(f, g),(f, h),(e, i),(i, j),(j, k),(i, l),(i, m),(c, n),(n, o),(o, p),(o, q),(n, r),(r, s),(r, t)
            ]
        @test preorder_vector(e, d) == [d, c, b, a, n, o, p , q, r, s, t]
        @test preorder_vector(d, e) == [e, f, g, h, i, j, k, l, m]
        @test preorder_vector(f) ==
            [f, e, d, c, b, a, n, o, p, q, r, s, t, i, j, k, l, m, g, h]
        @test_throws Phylodendron2.InvalidTopology preorder(a, f)
    end
    @testset "Postorder" begin
        @test postorder_vector(tree) ==
            [t, s, r, q, p, o, n, m, l, k, j, i, h, g, f, e, d, c, b, a]
        @test postorder(tree) ==
            [
                (r, t), (r, s), (n, r), (o, q), (o, p), (n, o), (c, n), (i, m), (i, l), (j, k), (i, j), (e, i), (f, h), (f, g), (e, f), (d, e), (c, d), (b, c), (a, b), (a, a)
            ]
        @test postorder_vector(e, d) == [t, s, r, q, p, o, n, a, b, c, d]
        @test postorder_vector(d, e) == [m, l, k, j, i, h, g, f, e]
        @test_throws Phylodendron2.InvalidTopology postorder(a, f)
    end
end

@testset "Find nodes" begin
    origin!(tree, a)
    @test findfirst(x -> label(x) == "F", tree) == f
    @test findfirst(x -> label(x) == "F", tree.origin) == f
    @test isnothing(findfirst(x -> label(x) == "W", tree))
    @test findfirst(istip, d, e) == g
    @test findall(x -> label(x) == "F", tree) == [f]
    @test findall(x -> label(x) == "F", tree.origin) == [f]
    @test isempty(findall(x -> label(x) == "W", tree))
    @test findall(istip, d, e) == [g, h, k, l, m]
end

@testset "Grafting and plucking" begin
    x = Node()
    brlen0 = brlength(a, b)
    graft!(x, a, b, 0.4)
    @test neighbours(x) == [a, b]
    @test neighbours(a) == [x]
    @test neighbours(b) == [c, x]
    @test brlength(a, x) == 0.4 * brlen0
    @test brlength(x, b) == 0.6 * brlen0
    pluck!(x, a, b)
    @test neighbours(x) == Node[]
    @test neighbours(a) == [b]
    @test neighbours(b) == [c, a]
    @test brlength(a, b) == brlen0
    brax = Branch(nothing)
    brxb = Branch(0.1)
    graft!(x, a, b, brax, brxb)
    @test neighbours(x) == [a, b]
    @test neighbours(a) == [x]
    @test neighbours(b) == [c, x]
    @test isnothing(brlength(a, x))
    @test brlength(x, b) == 0.1
    pluck!(x, a, b)
    @test isnothing(brlength(a, b))
    brlength!(a, b, brlen0)
end

@testset "More topological manipulation" begin
    tree2 = deepcopy(tree)
    origin2 = origin(tree2)
    pluck_nonsplitting!(tree2)
    @test find_nonsplitting(tree2) == []
    @test origin(tree2) == origin2
    tree2 = deepcopy(tree)
    origin2 = origin(tree2)
    neworigin = find_nonsplitting(tree2)[1]
    lastorigin = neighbours(neworigin)[1]
    origin!(tree2, neworigin)
    pluck_nonsplitting!(tree2)
    @test find_nonsplitting(tree2) == []
    @test origin(tree2) == lastorigin
end

@testset "Node paths and distances" begin
    @test nodepath(s, f) == [s, r, n, c, d, e, f]
    @test nodepath(f, s) == [f, e, d, c, n, r, s]
    @test nodepath(f, f) == Node[]
    @test nodepath(f, e) == [f, e]
    @test nodepath(l, k) == [l, i, j, k]
    @test_throws Phylodendron2.InvalidTopology nodepath(a, Node())
    @test nodedist(s, f) == 5
    @test nodedist(f, s) == 5
    @test nodedist(f, f) == 0
    @test nodedist(f, e) == 0
    @test nodedist(l, k) == 2
    @test_throws Phylodendron2.InvalidTopology nodedist(a, Node())
    @test brdist(s, f) ==
        brlength(s, r) + brlength(r, n) + brlength(n, c) + brlength(c, d) + brlength(d, e) + brlength(e, f)
    @test brdist(s, f) == brdist(f, s)
    @test brdist(f, f) == 0.0
    @test brdist(f, e) == brlength(f, e)
    @test brdist(l, k) == brlength(l, i) + brlength(i, j) + brlength(j, k)
    @test_throws Phylodendron2.InvalidTopology brdist(a, Node())
end

@testset "Bipartitions" begin
    origin!(tree, a)
    @test ! isinformative(Bipartition(BitArray([0, 0, 0, 0])))
    @test isinformative(Bipartition(BitArray([0, 0, 0, 1])))
    @test istrivial(Bipartition(BitArray([0, 1, 1, 1])))
    @test istrivial(Bipartition(BitArray([0, 0, 0, 1])))
    @test ! istrivial(Bipartition(BitArray([0, 0, 0, 0])))
    @test are_compatible(
        Bipartition(BitArray([0, 1, 1, 1])), 
        Bipartition(BitArray([0, 1, 1, 0]))
        )
    @test are_conflicting(
        Bipartition(BitArray([0, 1, 1, 0])), 
        Bipartition(BitArray([0, 0, 1, 1]))
        )
    dir = SpeciesDirectory(nodelabels(tree))
    tree.dir = dir
    setspecies!(tree)
    compute_bipartitions!(tree)
    v = falses(20)
    v[14:20] .= true
    @test getbranch(c, n).bipart.v == v
    v = falses(20)
    v[5:13] .= true
    @test getbranch(d, e).bipart.v == v
    set1 = Set(bipartitions(tree))
    for p in preorder_vector(tree)[2:end]
        origin!(tree, p)
        compute_bipartitions!(tree, dir)
        set2 = Set(bipartitions(tree))
        @test all([x in set2 for x in set2])
        set1 = set2
    end
end