function _n_node!(num::Int, p::AbstractNode, q::AbstractNode)
	for link in q.links
		link.to == p && continue
		num = _n_node!(num, q, link.to)
	end

	return num + 1
end

"""
	n_node(tree)
	n_node(p [, q])

Count the nodes in a tree or subtree denoted by the nodes `p` and `q`.
"""
n_node(p::AbstractNode, q::AbstractNode) = _n_node!(0, p, q)
n_node(p::AbstractNode) = n_node(p, p)
n_node(tree::AbstractTree) = n_node(tree.origin)

function _n_tip!(num::Int, p::AbstractNode, q::AbstractNode)
	for link in q.links
		link.to == p && continue
		num = _n_tip!(num, q, link.to)
	end

	return ifelse(istip(q), num + 1, num)
end

"""
	n_tip(tree)
	n_tip(p [, q])

Count the tip nodes in a tree or subtree denoted by the nodes `p` and `q`.
"""
n_tip(p::AbstractNode, q::AbstractNode) = _n_tip!(0, p, q)
n_tip(p::AbstractNode) = n_tip(p, p)
n_tip(tree::AbstractTree) = n_tip(tree.origin)

"""
	n_branch(tree)
	n_branch(p [, q])

Count the branches in a `tree` or subtree denoted by the nodes `p` and `q`.
"""
n_branch(p::AbstractNode, q::AbstractNode) = n_node(p, q) - 1
n_branch(p::AbstractNode) = n_branch(p, p)
n_branch(tree::AbstractTree) = n_branch(tree.origin)

function _n_species!(num::Int, p::AbstractNode, q::AbstractNode)
	for link in q.links
		link.to == p && continue
		num = _n_species!(num, q, link.to)
	end

	return ifelse(q.species > 0, num + 1, num)
end

"""
	n_species(tree)
	n_species(p [, q])

Count the species in a `tree` or subtree denoted by the nodes `p` and `q`.
"""
n_species(p::AbstractNode, q::AbstractNode) = _n_species!(0, p, q)
n_species(p::AbstractNode) = n_species(p, p)
n_species(tree::AbstractTree) = n_species(tree.origin)


function _nodelabels!(labs::Vector{String}, p::AbstractNode, q::AbstractNode)
	push!(labs, label(q))
	for link in q.links
		link.to == p && continue
		_nodelabels!(labs, q, link.to)
	end
	return labs
end

"""
	nodelabels(tree)
	nodelabels(p [, q])

Get the labels all the nodes (in preorder) in a `tree` or subtree denoted by the nodes `p` and `q`.
"""
nodelabels(p::AbstractNode, q::AbstractNode) = _nodelabels!(String[], p, q)
nodelabels(p::AbstractNode) = nodelabels(p, p)
nodelabels(tree::AbstractTree) = nodelabels(tree.origin)

function _tiplabels!(labs::Vector{String}, p::AbstractNode, q::AbstractNode)
	istip(q) && push!(labs, label(q))
	for link in q.links
		link.to == p && continue
		_tiplabels!(labs, q, link.to)
	end

	return labs
end

"""
	tiplabels(tree)
	tiplabels(p [, q])

Get the labels all the tip nodes (in preorder) in a `tree` or subtree denoted by the nodes `p` and `q`.
"""
tiplabels(p::AbstractNode, q::AbstractNode) = _tiplabels!(String[], p, q)
tiplabels(p::AbstractNode) = tiplabels(p, p)
tiplabels(tree::AbstractTree) = tiplabels(tree.origin)

function _bipartitions(list::Vector{Bipartition}, p::AbstractNode, q::AbstractNode)
	for link in q.links
		link.to == p && continue
		push!(list, link.branch.bipart)
		_bipartitions(list, q, link.to)
	end

	return list
end


function _tips!(list::Vector{T}, p::T, q::T) where T <: AbstractNode
	istip(q) && push!(list, q)
	for link in q.links
		link.to == p && continue
		_tips!(list, q, link.to)
	end

	return list
end

"""
	tips(tree)
	tips(p [, q])

Get a list of all the tip nodes (in preorder) in a `tree` or subtree denoted by the nodes `p` and `q`.
"""
tips(p::T, q::T) where T <: AbstractNode = _tips!(T[], p, q)
tips(p::AbstractNode) = tips(p, p)
tips(tree::AbstractTree) = tips(tree.origin)


"""
	bipartitions(tree)
	bipartitions(p [, q])

Get all the bipartitions (in preorder) of a `tree` or subtree denoted by the nodes `p` and `q`.
"""
bipartitions(p::AbstractNode, q::AbstractNode) =
	_bipartitions(Bipartition[], p, q)
bipartitions(p::AbstractNode) = bipartitions(p, p)
bipartitions(tree::AbstractTree) = bipartitions(tree.origin)

function _getspecies!(list::Vector{Int}, p::AbstractNode, q::AbstractNode)
	push!(list, q.species)
	for link in q.links
		link.to == p && continue
		_getspecies!(list, q, link.to)
	end

	return list
end 

"""
	getspecies(tree)
	getspecies(p , q)

Get the species numbers of all the nodes (in preorder) of a `tree` or subtree denoted by the nodes `p` and `q`.
"""
getspecies(p::AbstractNode, q::AbstractNode) = _getspecies!(Int[], p, q)
getspecies(tree::AbstractTree) = getspecies(tree.origin, tree.origin)


function _find_nonsplitting!(list::NodeVector, p::AbstractNode, q::AbstractNode)
	n_neighbour(q) == 2 && push!(list, q)
	for link in q.links
		link.to == p && continue
		list = _find_nonsplitting!(list, q, link.to)
	end

	return list
end

"""
	find_nonsplitting(tree)
	find_nonsplitting(p [, q])

Get a list of non-splitting internal nodes in a `tree` or subtree denoted by the nodes `p` and `q`. Non-splitting internal nodes are nodes with only two neighbours.
"""
find_nonsplitting(p::AbstractNode, q::AbstractNode) = 
	_find_nonsplitting!(Vector{typeof(p)}(), p, q)
find_nonsplitting(p::AbstractNode) = find_nonsplitting(p, p)
find_nonsplitting(tree::AbstractTree) = find_nonsplitting(tree.origin)