using Phylodendron2
using Test

@testset "Phylodendron2.jl" begin
    include("species_directory.jl")
    include("species_data.jl")
    include("test_tree.jl")
    include("newick.jl")
    include("randtree.jl")
end

@testset "BrownianModels" begin
    using Phylodendron2.BrownianModels

    include("BrownianModels/simulate.jl")
end