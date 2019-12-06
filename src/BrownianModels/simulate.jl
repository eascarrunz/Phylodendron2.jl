simulate_bm(t::Tree, k::Int; σ²::Float64=1.0, x₀::Float64=0.0) =
    simulate_bm(t; σ²=fill(σ², k), x₀=fill(x₀, k))

"""
    simulate_bm(t::Tree, k::Int, σ::Vector{Float64} = ones(k), x₀::Vector{Float64} = zeros(k))

Simulate the evolution of continuous traits under univariate Brownian motion on a phylogenetic tree.

Creates a `SpeciesDataMatrix` with `k` independent traits, with `σ²` as the vector of diffusion coeffients of the traits (all 1.0 by default), and `x₀` as the vector of trait values at the root (all 0.0 by default).
"""
function simulate_bm(
    t::Tree;
    σ²::Union{Float64, Vector{Float64}} = 1.0,
    x₀::Union{Float64, Vector{Float64}} = 0.0
    )
    ! t.rooted && @warn "The tree is unrooted. The simulation was done using the origin node as the root."

    if σ² isa Float64 && x₀ isa Float64
        σ² = [σ²]
        x₀ = [x₀]
    elseif σ² isa Float64 && x₀ isa Vector{Float64}
        σ² = fill(σ², length(x₀))
    elseif σ² isa Vector{Float64} && x₀ isa Float64
        x₀ = fill(x₀, length(σ²))
    elseif length(σ²) ≠ length(x₀)
        msg = "the vectors `σ²` and `x₀` must both have `k` number of elements."
        throw(ArgumentError(msg))
    end

    k = length(x₀)
    σ = .√(σ²)

    return _simulate_bm_species(t, k, σ, x₀)
end


function _simulate_bm_species(t::Tree, k::Int, σ::Vector{Float64}, x₀::Vector{Float64})::SpeciesDataMatrix{Float64}
    x = SpeciesDataMatrix{Float64}(t.dir, k)
    for p ∈ neighbours(t.origin)
        _simulate_bm!(x, p, t.origin, k, σ, x₀)
    end

    return x
end

function _simulate_bm!(
    x::SpeciesDataMatrix{Float64},
    p::Node,
    q::Node,
    k::Int,
    σ::Vector{Float64},
    x₀::Vector{Float64}
    )
    xₚ = x₀ .+ σ .* √(brlength(q, p)) .* randn(k)
    if p.species > 0 && p.species ∈ x.dir
        x[p.species,:] = xₚ
    end
    for r in neighbours(p)
        r == q && continue
        _simulate_bm!(x, r, p, k, σ, xₚ)
    end
end