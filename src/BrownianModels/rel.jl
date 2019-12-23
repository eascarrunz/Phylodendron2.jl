const LOG2π = log(2.0π)
const INIT_V = 1.0

struct RELBrownianTree <: AbstractTreeDataBlock
	ind::Int
	n_chars::Int
	llh::Vector{Float64}
end

struct RELBrownianNode <: AbstractNodeDataBlock
	treeblock::RELBrownianTree
	xprune::Vector{Float64}
	llh::Vector{Float64}
end

mutable struct RELBrownianBranch <: AbstractBranchDataBlock
	treeblock::RELBrownianTree
	v::Float64
	vprune::Float64
	δv::Float64
end

#=

	Model initialisators

=#

function init_model!(
	m::RELBrownianTree,
	br::AbstractBranch,
	copylength::Bool=true;
	i::Int=0
	)
	init_v = copylength ? br.length : INIT_V
	mm = RELBrownianBranch(m, init_v, init_v, 0.0)

	if i == 0
		push!(br.datablocks, mm)
	else
		br.datablocks[i] = mm
	end
	
	return nothing
end

function init_model!(
	m::RELBrownianTree,
	p::AbstractNode,
	x::SpeciesDataMatrix{Float64};
	i::Int=0
	)
	if p.species > 0 && p.species ∈ x.dir
		xprune = x[p.species, :]
	else
		xprune = fill(NaN, m.n_chars)
	end

	mm = RELBrownianNode(m, xprune, fill(NaN, m.n_chars))
	
	if i == 0
		push!(p.datablocks, mm)
	else
		p.datablocks[i] = mm
	end

	return nothing
end

function _init_model!(
	m::RELBrownianTree,
	p::AbstractNode, 
	q::AbstractNode,
	x::SpeciesDataMatrix{Float64},
	copylength::Bool=true;
	i::Int=0
	)
	
	for link in q.links
		link.to == p && continue
		_init_model!(m, q, link.to, x, copylength, i=i)
		init_model!(m, link.branch, copylength, i=i)
	end

	init_model!(m, q, x)

	return nothing
end

function init_model!(
	tree::AbstractTree, 
	x::SpeciesDataMatrix{Float64}, 
	copylength::Bool=true;
	i::Int=0
	)

	ii = i == 0 ? lastindex(tree.datablocks) + 1 : i
	k = size(x, 2)
	m = RELBrownianTree(ii, k, fill(NaN, k))

	for link in tree.origin.links
		_init_model!(m, tree.origin, link.to, x, copylength, i=i)
		init_model!(m, link.branch, copylength, i=i)
	end
	init_model!(m, tree.origin, x)

	if i == 0
		push!(tree.datablocks, m)
	else
		@inbounds tree.datablocks[i] = m
	end

	return ii
end

#=

	Compute likelihood

=#

"""
Compute the log-likelihood of a node based on its two children
"""
@inline function _calc_llh_2c(
	p::AbstractNode,
	q::AbstractNode,
	i::Int
	)
	childlinks = filter(x -> x.to ≠ p, q.links)

	x₁ = childlinks[1].to.datablocks[i].xprune
	v₁ = childlinks[1].branch.datablocks[i].vprune
	x₂ = childlinks[2].to.datablocks[i].xprune
	v₂ = childlinks[2].branch.datablocks[i].vprune

	# Following Felsenstein (1981), Eqn. 9:
	return @. -0.5 * ((log(v₁ + v₂) + LOG2π) + ((x₁ - x₂)^2) / (v₁ + v₂))
end

"""
Compute the log-likelihood of a node based on its three children
"""
@inline function _calc_llh_3c(p::AbstractNode, i::Int)
	x₁ = p.links[1].to.datablocks[i].xprune
	v₁ = p.links[1].branch.datablocks[i].vprune
	x₂ = p.links[2].to.datablocks[i].xprune
	v₂ = p.links[2].branch.datablocks[i].vprune
	x₃ = p.links[3].to.datablocks[i].xprune
	v₃ = p.links[3].branch.datablocks[i].vprune
	Σv₁₂ = v₁ + v₂

	# Following Felsenstein (1981), Eqn. A1-1:
	llh = @. log(Σv₁₂) + ((x₁ - x₂)^2) / Σv₁₂
	@. llh += log(v₃ + v₁ * v₂ / Σv₁₂)
	@. llh += ((x₃ - (v₂ * x₁ + v₁ * x₂) / Σv₁₂)^2) / (v₃ + v₁ * v₂ / Σv₁₂)
	@. llh *= -0.5
	@. llh -= LOG2π

	return llh
end

function _calc_llh!(
	p::AbstractNode, 
	q::AbstractNode, 
	i::Int, 
	accllh::Vector{Float64};
	prune::Bool=true
	)
	for link in q.links
		link.to == p && continue
		istip(link.to) && continue
		accllh .= _calc_llh!(q, link.to, i, accllh)
	end
	prune && nodeprune!(p, q, i)
	@inbounds q.datablocks[i].llh .= _calc_llh_2c(p, q, i)
	@inbounds accllh .+= q.datablocks[i].llh

	return accllh
end

function calc_llh!(tree::AbstractTree, i::Int; prune::Bool=true)
	k = tree.datablocks[i].n_chars
	accllh = zeros(k)
	for link in tree.origin.links
		istip(link.to) && continue
		accllh .= _calc_llh!(tree.origin, link.to, i, accllh, prune=prune)
	end

	(2 ≤ n_neighbour(tree.origin) ≤ 3) || 
		throw(Phylodendron2.InvalidTopology("the origin of the tree must be of degree 2 or 3"))
	
	if n_neighbour(tree.origin) > 2
		@inbounds tree.origin.datablocks[i].llh .= 
			_calc_llh_3c(tree.origin, i)
	else
		@inbounds tree.origin.datablocks[i].llh .= 
			_calc_llh_2c(tree.origin, tree.origin, i)
	end
	@inbounds tree.datablocks[i].llh .= accllh .+ tree.origin.datablocks[i].llh

	return sum(tree.datablocks[i].llh)
end

"""
    phylip_llh(m::RELBrownianTree)

Return the log-likelihood of the model `m` as computed by Phylip.

Phylip computes log-likelihoods of trees differently because it ommits a constant term from the likelihoods of every node. The term is (n - 1)/2 * k * ln(2π), where k is the number of characters and n the number of tips.
"""
function phylip_llh(tree::AbstractTree, i::Int)::Float64
	m = tree.datablocks[i]::RELBrownianTree

	return sum(m.llh) + (n_tip(tree) - 1) / 2 * m.n_chars * LOG2π
end

#=

	Prune

=#

function nodeprune!(
	p::AbstractNode,
	q::AbstractNode, 
	i::Int,
	calc_llh::Bool=false
	)
	if istip(q)
		br = getbranch(p, q)
		br.datablocks[i].vprune = br.datablocks[i].v

		return nothing
	end
	child₁, child₂ = filter(x -> x ≠ p, neighbours(q))
	br₀ = getbranch(p, q)
	br₁ = getbranch(q, child₁)
	br₂ = getbranch(q, child₂)

	x₁ = child₁.datablocks[i].xprune
	x₂ = child₂.datablocks[i].xprune
	v₁ = br₁.datablocks[i].vprune
	v₂ = br₂.datablocks[i].vprune
	Σv = v₁ + v₂

	# Following Felsenstein (1981), Eqn. 12:
	@inbounds @. q.datablocks[i].xprune = (x₁ * v₂ + x₂ * v₁) / Σv

	# Following Felsenstein (1981), Eqn. 13:
    @inbounds br₀.datablocks[i].δv = v₁ * v₂ / Σv
	@inbounds br₀.datablocks[i].vprune =
		br₀.datablocks[i].v + br₀.datablocks[i].δv
	
	return nothing
end

function subtreeprune!(
	p::AbstractNode, 
	q::AbstractNode, 
	i::Int;
	calc_llh::Bool=false
	)
	for link in q.links
		link.to == p && continue
		subtreeprune!(q, link.to, i)
	end

	nodeprune!(p, q, i)

	return nothing
end

function treeprune!(tree::AbstractTree, i::Int)
	for link in tree.origin.links
		subtreeprune!(tree.origin, link.to, i)
	end

	return nothing
end


#=

	Optimise branch lengths

=#

function optimv_3c!(p::AbstractNode, i::Int)
	child₁, child₂, child₃ = neighbours(p)

	br₁ = getbranch(p, child₁)
	br₂ = getbranch(p, child₂)
	br₃ = getbranch(p, child₃)

	x₁ = child₁.datablocks[i].xprune
	x₂ = child₂.datablocks[i].xprune
	x₃ = child₃.datablocks[i].xprune

	k = length(x₁)

	kv̂₁ = sum((x₁ .- x₂) .* (x₁ .- x₃))
    kv̂₂ = sum((x₂ .- x₁) .* (x₂ .- x₃))
    kv̂₃ = sum((x₃ .- x₁) .* (x₃ .- x₂))

	if kv̂₁ < 0.0
        kv̂₁ = 0.0
        kv̂₂ = sum((x₁ .- x₂).^2)
        kv̂₃ = sum((x₁ .- x₃).^2)
    elseif kv̂₂ < 0.0
        kv̂₁ = sum((x₂ .- x₁).^2)
        kv̂₂ = 0.0
        kv̂₃ = sum((x₂ .- x₃).^2)
    elseif kv̂₃ < 0.0
        kv̂₁ = sum((x₃ .- x₁).^2)
        kv̂₂ = sum((x₃ .- x₂).^2)
        kv̂₃ = 0.0
    end

    @inbounds br₁.datablocks[i].vprune = kv̂₁ / k
    @inbounds br₂.datablocks[i].vprune = kv̂₂ / k
    @inbounds br₃.datablocks[i].vprune = kv̂₃ / k

	@inbounds br₁.datablocks[i].vprune = 
		max(br₁.datablocks[i].vprune, br₁.datablocks[i].δv)
	@inbounds br₂.datablocks[i].vprune = 
        max(br₂.datablocks[i].vprune, br₂.datablocks[i].δv)
	@inbounds br₃.datablocks[i].vprune = 
        max(br₃.datablocks[i].vprune, br₃.datablocks[i].δv)

	@inbounds br₁.datablocks[i].v = 
		br₁.datablocks[i].vprune - br₁.datablocks[i].δv
	@inbounds br₂.datablocks[i].v = 
		br₂.datablocks[i].vprune - br₂.datablocks[i].δv
	@inbounds br₃.datablocks[i].v = 
		br₃.datablocks[i].vprune - br₃.datablocks[i].δv

	return nothing
end

function optimv!(tree::AbstractTree, i::Int; niter = 5)
	for _ in 1:niter
		@assert n_neighbour(tree.origin) == 3 "the origin node must have three neighbours."
		treeprune!(tree, i)
		optimv_3c!(tree.origin, i)
		p = tree.origin
		for q in preorder_vector(tree.origin)[2:end]
			istip(q) && continue
			#=
            The following loop works as a shortcut. Instead of prunning the entire tree anew, it only prunes the neighbours of the nodes along the path between the current node (`q`) and the node from the previous iteration (`p`) (Felsenstein 1981, p. 1238).

            Finding the path between the two nodes is itself relatively costly, so this is likely only an improvement in big trees.
			=#
			for r in nodepath(p, q)[2:end]
				for link in r.links
					nodeprune!(r, link.to, i)
				end
			end
			optimv_3c!(q, i)
			p = q
		end
	end

	return nothing
end

"""
	v2brlength!(tree::AbstractTree, m::RELBrownianTree)

Set the branch lengths of a tree from the branch length parameters (v) of a Brownian model.
"""
function v2brlength!(tree::AbstractTree, i::Int)
	@assert tree.datablocks[i] isa RELBrownianTree "datablock " * string(i) * " does not contain a Brownian model"
	for (p, q) in preorder(tree)[2:end]
		v = getbranch(p, q).datablocks[i].v
		brlength!(p, q, v)
	end

	return nothing
end
