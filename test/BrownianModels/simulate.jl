snouter_tree = read_newick("../data/snouters.nwk")[1]
root!(snouter_tree)

dir = SpeciesDirectory(tiplabels(snouter_tree))
snouter_tree.dir = dir
setspecies!(snouter_tree)

@testset "Simulate Brownian Motion" begin
    x₀ = [1.0, 12.0, 3.4, 2.0, 12.0]
    σ² = [1.0, 2.0, 10.0, 100.0, 0.0]

    dm = simulate_bm(snouter_tree)
    @test dm isa SpeciesDataMatrix{Float64}
    @test size(dm) == (n_species(snouter_tree), 1)

    dm = simulate_bm(snouter_tree, 12)
    @test dm isa SpeciesDataMatrix{Float64}
    @test size(dm) == (n_species(snouter_tree), 12)

    dm = simulate_bm(snouter_tree, σ²=3.0)
    @test dm isa SpeciesDataMatrix{Float64}
    @test size(dm) == (n_species(snouter_tree), 1)

    dm = simulate_bm(snouter_tree, σ²=3.0, x₀=x₀)
    @test dm isa SpeciesDataMatrix{Float64}
    @test size(dm) == (n_species(snouter_tree), 5)

    dm = simulate_bm(snouter_tree, σ²=σ²)
    @test dm isa SpeciesDataMatrix{Float64}
    @test size(dm) == (n_species(snouter_tree), 5)
    @test dm[:,5] == zeros(10)
    
    dm = simulate_bm(snouter_tree, x₀=x₀)
    @test dm isa SpeciesDataMatrix{Float64}
    @test size(dm) == (n_species(snouter_tree), 5)

    dm = simulate_bm(snouter_tree, x₀=x₀, σ²=σ²)
    @test dm isa SpeciesDataMatrix{Float64}
    @test size(dm) == (n_species(snouter_tree), 5)
end
