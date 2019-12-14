const LOG2π = log(2π)
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
		tree.datablocks[i] = m
	end

	return ii
end

function llh_brownian_2c(
    x₁::Vector{Float64}, x₂::Vector{Float64}, # Pruned character values
    v₁::Float64, v₂::Float64, # Pruned branch lengths
    k::Int                    # Number of characters
	)::Vector{Float64}
	
    # Following Felsenstein (1981), Eqn. 9:
    return @. -0.5 * ((log(v₁ + v₂) + LOG2π) + ((x₁ - x₂)^2) / (v₁ + v₂))
end

"""
Compute the restricted log-likelihood from the parameters of a pruned node with three children.
"""
function llh_brownian_3c(
	# Pruned character values:
	x₁::Vector{Float64}, 
	x₂::Vector{Float64}, 
	x₃::Vector{Float64},
	# Pruned branch lengths:
	v₁::Float64, 
	v₂::Float64, 
	v₃::Float64, 
	# Number of characters:
    k::Int,
	)::Vector{Float64}
	
    # Following Felsenstein (1981, Eqn. A1-1):
    Σv₁₂ = v₁ + v₂
    llh = fill(log(Σv₁₂), k)
    @. llh += ((x₁ - x₂)^2) / Σv₁₂
    @. llh += log(v₃ + v₁ * v₂ / Σv₁₂)
    part1 = @. (x₃ - (v₂ * x₁ + v₁ * x₂) / Σv₁₂)
    part2 = @. v₃ + v₁ * v₂ / Σv₁₂
    @. llh += (part1.^2) / part2
    @. llh *= -0.5
    @. llh -= LOG2π

    return llh
end 

function brownian_prune!(
	p::AbstractNode, 
	q::AbstractNode, 
	i::Int, 
	calc_llh::Bool=false;
	recursive::Bool=false
	)
	k = q.datablocks[i].treeblock.n_chars
	accllh = calc_llh ? zeros(k) : fill(NaN, k)
	if istip(q)
		br = q.links[1].branch
		br.datablocks[i].vprune = br.datablocks[i].v

		return accllh
	end

	for link in q.links
		link.to == p && continue
		accllhthis =
			brownian_prune!(q, link.to, i, calc_llh; recursive=recursive)
		istip(link.to) && continue
		accllh .+= calc_llh ? accllhthis : NaN
	end

	child₁, child₂ = filter(x -> x ≠ p, neighbours(q))
	br₀ = getbranch(p, q)
	br₁, br₂ = getbranch(q, child₁), getbranch(q, child₂)

	x₁ = child₁.datablocks[i].xprune
	x₂ = child₂.datablocks[i].xprune
	v₁ = br₁.datablocks[i].vprune
	v₂ = br₂.datablocks[i].vprune
	Σv = v₁ + v₂

	# Following Felsenstein (1981), Eqn. 12:
	q.datablocks[i].xprune .= @. (x₁ * v₂ + x₂ * v₁) / Σv

	# Following Felsenstein (1981), Eqn. 13:
    br₀.datablocks[i].δv = v₁ * v₂ / Σv
	@inbounds br₀.datablocks[i].vprune =
		br₀.datablocks[i].v + br₀.datablocks[i].δv
	
	if calc_llh
		q.datablocks[i].llh .= llh_brownian_2c(x₁, x₂, v₁, v₂, k)
	end

	return accllh .+ q.datablocks[i].llh
end

function brownian_prune!(p::AbstractNode, i::Int, calc_llh::Bool=false)
	if calc_llh
		k = p.datablocks[i].treeblock.n_chars
		llh = zeros(k)
		for link in p.links
			llhthis = brownian_prune!(p, link.to, i, true, recursive=true)
			istip(link.to) && continue
			llh .+= llhthis
		end

		children = neighbours(p)

		if length(children) == 3
			child₁, child₂, child₃ = children

			br₁ = getbranch(p, child₁)
            br₂ = getbranch(p, child₂)
            br₃ = getbranch(p, child₃)
            
            x₁= child₁.datablocks[i].xprune
            x₂= child₂.datablocks[i].xprune
            x₃= child₃.datablocks[i].xprune
            v₁ = br₁.datablocks[i].vprune
            v₂ = br₂.datablocks[i].vprune
			v₃ = br₃.datablocks[i].vprune 
			
			p.datablocks[i].llh .=
				llh_brownian_3c(x₁, x₂, x₃, v₁, v₂, v₃, k)
			p.datablocks[i].treeblock.llh .= llh .+ p.datablocks[i].llh

		elseif length(children) == 2
			child₁, child₂ = children

			br₁ = getbranch(p, child₁)
            br₂ = getbranch(p, child₂)
            
            x₁= child₁.datablocks[i].xprune
            x₂= child₂.datablocks[i].xprune
            v₁ = br₁.datablocks[i].vprune
            v₂ = br₂.datablocks[i].vprune
			
			p.datablocks[i].llh .= llh_brownian_2c(x₁, x₂, v₁, v₂, k)
			p.datablocks[i].treeblock.llh .= llh .+ p.datablocks[i].llh
		else
			@error "the root or origin of the tree must be of degree 2 or 3"
		end
	else
		for link in p.links
			brownian_prune!(p, link.to, i, false, recursive=true)
		end
	end

	return nothing
	
end

function optimise_brownian_v_3c!(p::AbstractNode, i::Int)
	child₁, child₂, child₃ = neighbours(p)

    br₁ = getbranch(p, child₁)
    br₂ = getbranch(p, child₂)
	br₃ = getbranch(p, child₃)
	
	x₁= child₁.datablocks[i].xprune
    x₂= child₂.datablocks[i].xprune
    x₃= child₃.datablocks[i].xprune

    k = p.datablocks[i].treeblock.n_chars

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

    br₁.datablocks[i].vprune = kv̂₁ / k
    br₂.datablocks[i].vprune = kv̂₂ / k
	br₃.datablocks[i].vprune = kv̂₃ / k
	
	# @inbounds from here on, as the relevant bounds have been checked.

	@inbounds br₁.datablocks[i].vprune = 
		br₁.datablocks[i].vprune > br₁.datablocks[i].δv ? 
		br₁.datablocks[i].vprune : br₁.datablocks[i].δv
	@inbounds br₂.datablocks[i].vprune = 
		br₂.datablocks[i].vprune > br₂.datablocks[i].δv ? 
		br₂.datablocks[i].vprune : br₂.datablocks[i].δv
	@inbounds br₃.datablocks[i].vprune = 
		br₃.datablocks[i].vprune > br₃.datablocks[i].δv ? 
		br₃.datablocks[i].vprune : br₃.datablocks[i].δv

	@inbounds br₁.datablocks[i].v = 
		br₁.datablocks[i].vprune - br₁.datablocks[i].δv
	@inbounds br₂.datablocks[i].v = 
		br₂.datablocks[i].vprune - br₂.datablocks[i].δv
	@inbounds br₃.datablocks[i].v = 
		br₃.datablocks[i].vprune - br₃.datablocks[i].δv
    
    return nothing
end

"""
Optimise v in a tree
"""
function optimise_v!(tree::AbstractTree, i::Int; niter::Int=5)
	@assert tree.datablocks[i] isa RELBrownianTree

	visit_list = preorder_vector(tree)
	j = 1
	while istip(visit_list[j])
		j += 1
	end
	for _ in 1:niter
		p = visit_list[j]
		brownian_prune!(p, i, false)
		optimise_brownian_v_3c!(p, i)
		for q in visit_list[(j + 1):end]
			istip(q) && continue
			#=
            The following loop works as a shortcut. Instead of prunning the entire tree anew, it only prunes the neighbours of the nodes along the path between the current node (`q`) and the node from the previous iteration (`p`) (Felsenstein 1981, p. 1238).

            Finding the path between the two nodes is itself relatively costly, so this is likely only an improvement in big trees.
			=#
			for r in nodepath(p, q)[2:end]
				child₁, child₂, child₃ = neighbours(r)
				brownian_prune!(r, child₁, i, true)
                brownian_prune!(r, child₂, i, true)
                brownian_prune!(r, child₃, i, true)
			end
			optimise_brownian_v_3c!(q, i)
			p = q
		end
	end

	return nothing
end

"""
    calc_llh!(t::Tree, i::Int)

Calculate the log-likelihood of tree `t` under model `i`.
"""
function calc_llh!(tree::AbstractTree, i::Int)::Float64
    @assert tree.datablocks[i] isa RELBrownianTree
	brownian_prune!(tree.origin, i, true)
	
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

"""
	brlength!(tree::AbstractTree, m::RELBrownianTree)

Set the branch lengths of a tree from the branch length parameters of a Brownian model.
"""
function Phylodendron2.brlength!(tree::AbstractTree, m::RELBrownianTree)
	i = m.ind
	for (p, q) in preorder(tree)[2:end]
		v = getbranch(p, q).datablocks[i].v
		brlength!(p, q, v)
	end

	return nothing
end