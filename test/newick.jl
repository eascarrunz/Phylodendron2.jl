using Phylodendron2, Test

@testset "All nodes unlabelled , no branch lengths." begin
    nwk = "(,,(,));"
    tree_origin = parse_newick(nwk)

    @testset "Tree structure" begin
        @test n_neighbour(tree_origin) == 3

        global a, b, c = neighbours(tree_origin)

        @test neighbours(a) == [tree_origin]
        @test neighbours(b) == [tree_origin]
        @test n_neighbour(c) == 3
        @test neighbours(c)[1] == tree_origin

        global d, e = neighbours(c)[2:3]
        @test neighbours(d) == [c]
        @test neighbours(e) == [c]
    end
    @testset "Node and branch properties" begin
        @test label(tree_origin) == ""
        @test label(c) == ""
        @test isnothing(brlength(tree_origin, a))
        @test isnothing(brlength(c, d))
        @test brlabel(tree_origin, a) == ""
        @test brlabel(c, d) == ""
    end
    @testset "Writing Newick" begin
        @test newick_string(tree_origin) == nwk
    end
end

# Clear variables
tree_origin, a, b, c, d, e = nothing, nothing, nothing, nothing, nothing, nothing

@testset "Labelled tips, no branch lengths" begin
    nwk = "(A,B,(C,D));"
    tree_origin = parse_newick(nwk)
    @testset "Tree structure" begin
        @test n_neighbour(tree_origin) == 3

        global a, b, e = neighbours(tree_origin)

        @test neighbours(a) == [tree_origin]
        @test neighbours(b) == [tree_origin]
        @test n_neighbour(e) == 3
        @test neighbours(e)[1] == tree_origin
        global c, d = neighbours(e)[2:3]
        @test neighbours(c) == [e]
        @test neighbours(d) == [e]
    end
    @testset "Node and branch properties" begin
        @test label(tree_origin) == ""
        @test label(a) == "A"
        @test label(b) == "B"
        @test label(c) == "C"
        @test label(d) == "D"
        @test label(e) == ""
        @test isnothing(brlength(tree_origin, a))
        @test isnothing(brlength(c, e))
        @test brlabel(tree_origin, a) == ""
        @test brlabel(c, e) == ""
    end
    @testset "Writing Newick" begin
        @test newick_string(tree_origin) == nwk
    end
end

# Clear variables
tree_origin, a, b, c, d, e = nothing, nothing, nothing, nothing, nothing, nothing

@testset "All nodes labelled, no branch lengths" begin
    nwk = "(A,B,(C,D)E)F;"
    f = parse_newick(nwk)
    @testset "Tree structure" begin
        @test n_neighbour(f) == 3

        global a, b, e = neighbours(f)

        @test neighbours(a) == [f]
        @test neighbours(b) == [f]
        @test n_neighbour(e) == 3
        @test neighbours(e)[1] == f
        global c, d = neighbours(e)[2:3]
        @test neighbours(c) == [e]
        @test neighbours(d) == [e]
    end
    @testset "Node and branch properties" begin
        @test label(a) == "A"
        @test label(b) == "B"
        @test label(c) == "C"
        @test label(d) == "D"
        @test label(e) == "E"
        @test label(f) == "F"
        @test isnothing(brlength(f, a))
        @test isnothing(brlength(e, d))
        @test brlabel(f, a) == ""
        @test brlabel(e, d) == ""
    end
    @testset "Writing Newick" begin
        @test newick_string(f) == nwk
    end
end

# Clear variables
tree_origin, a, b, c, d, e = nothing, nothing, nothing, nothing, nothing, nothing

@testset "All nodes unlabelled, with branch lengths." begin
    nwk = "(:0.1,:0.2,(:0.3,:0.4):0.5);"
    tree_origin = parse_newick(nwk)

    @testset "Tree structure" begin
        @test n_neighbour(tree_origin) == 3

        global a, b, c = neighbours(tree_origin)

        @test neighbours(a) == [tree_origin]
        @test neighbours(b) == [tree_origin]
        @test n_neighbour(c) == 3
        @test neighbours(c)[1] == tree_origin

        global d, e = neighbours(c)[2:3]
        @test neighbours(d) == [c]
        @test neighbours(e) == [c]
    end
    @testset "Node and branch properties" begin
        @test label(tree_origin) == ""
        @test label(c) == ""
        @test brlength(tree_origin, a) == 0.1
        @test brlength(tree_origin, b) == 0.2
        @test brlength(tree_origin, c) == 0.5
        @test brlength(c, d) == 0.3
        @test brlength(c, e) == 0.4
        @test brlabel(tree_origin, a) == ""
        @test brlabel(c, d) == ""
    end
    @testset "Writing Newick" begin
        @test newick_string(tree_origin) == nwk
    end
end

# Clear variables
tree_origin, a, b, c, d, e = nothing, nothing, nothing, nothing, nothing, nothing

@testset "Labelled tips, with branch lengths" begin
    nwk = "(A:0.1,B:0.2,(C:0.3,D:0.4):0.5);"
    tree_origin = parse_newick(nwk)
    @testset "Tree structure" begin
        @test n_neighbour(tree_origin) == 3

        global a, b, e = neighbours(tree_origin)

        @test neighbours(a) == [tree_origin]
        @test neighbours(b) == [tree_origin]
        @test n_neighbour(e) == 3
        @test neighbours(e)[1] == tree_origin
        global c, d = neighbours(e)[2:3]
        @test neighbours(c) == [e]
        @test neighbours(d) == [e]
    end
    @testset "Node and branch properties" begin
        @test label(tree_origin) == ""
        @test label(a) == "A"
        @test label(b) == "B"
        @test label(c) == "C"
        @test label(d) == "D"
        @test label(e) == ""
        @test brlength(tree_origin, a) == 0.1
        @test brlength(tree_origin, b) == 0.2
        @test brlength(tree_origin, e) == 0.5
        @test brlength(e, c) == 0.3
        @test brlength(e, d) == 0.4
        @test brlabel(tree_origin, a) == ""
        @test brlabel(c, e) == ""
    end
    @testset "Writing Newick" begin
        @test newick_string(tree_origin) == nwk
    end
end

# Clear variables
tree_origin, a, b, c, d, e = nothing, nothing, nothing, nothing, nothing, nothing

@testset "All nodes labelled, with branch lengths" begin
    nwk = "(A:0.1,B:0.2,(C:0.3,D:0.4)E:0.5)F;"
    f = parse_newick(nwk)
    @testset "Tree structure" begin
        @test n_neighbour(f) == 3

        global a, b, e = neighbours(f)

        @test neighbours(a) == [f]
        @test neighbours(b) == [f]
        @test n_neighbour(e) == 3
        @test neighbours(e)[1] == f
        global c, d = neighbours(e)[2:3]
        @test neighbours(c) == [e]
        @test neighbours(d) == [e]
    end
    @testset "Node and branch properties" begin
        @test label(a) == "A"
        @test label(b) == "B"
        @test label(c) == "C"
        @test label(d) == "D"
        @test label(e) == "E"
        @test label(f) == "F"
        @test brlength(f, a) == 0.1
        @test brlength(f, b) == 0.2
        @test brlength(f, e) == 0.5
        @test brlength(e, c) == 0.3
        @test brlength(e, d) == 0.4
        @test brlabel(f, a) == ""
        @test brlabel(e, d) == ""
    end
    @testset "Making Newick strings" begin
        @test newick_string(f) == nwk
    end
end

@testset "Reading from file" begin
    @testset "Default settings" begin
        trees = read_newick("../data/snouters.nwk")
        @test typeof(trees) <: TreeVector
        @test length(trees) == 1
        @test n_tip(trees[1]) == 10
        trees = read_newick("../data/wikipedia.nwk")
        @test typeof(trees) <: TreeVector
        @test length(trees) == 14
        @test n_tip(trees[1]) == 4
    end
    @testset "n hint too low" begin
        trees = read_newick("../data/wikipedia.nwk"; nhint=1)
        @test typeof(trees) <: TreeVector
        @test length(trees) == 14
        @test n_tip(trees[1]) == 4
    end
end

@testset "Reading trees from string" begin
    text = [randtree(12) for _ in 1:20] .|> newick_string |> join
    trees = read_newick(text=text)

    @test length(trees) == 20
    @test text == newick_string.(trees) |> join
end

@testset "Newick trees with emoji" begin
    text_tree = "((((🐇,🐳),(🐍:12.0,🐢)),🐠),🐌);"
    tree = parse_newick(text_tree)

    @test text_tree == newick_string(tree)
end

# tree = read_newick("../../data/snouters.nwk")
# trees = read_newick("trees/wikipedia.nwk")

# @testset "Writing to file" begin
#     write_newick("trees/test1.tmp", tree[1])
#     test1 = read_newick("trees/test1.tmp")
#     @test typeof(test1) == TreeVector
#     @test length(test1) == 1

#     write_newick("trees/test2.tmp", tree)
#     test2 = read_newick("trees/test2.tmp")
#     @test typeof(test2) == TreeVector
#     @test length(test2) == 1

#     write_newick("trees/test3.tmp", trees)
#     test3 = read_newick("trees/test3.tmp")
#     @test typeof(test3) == TreeVector
#     @test length(test3) == 14
# end

# rm("trees/test1.tmp")
# rm("trees/test2.tmp")
# rm("trees/test3.tmp")