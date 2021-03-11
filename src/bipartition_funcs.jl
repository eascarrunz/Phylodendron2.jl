Base.print(io::IO, bp::Bipartition) = print(io, mapreduce(x -> x ? "●" : "○", *, bp.v))

function Base.:(==)(a::Bipartition, b::Bipartition)
	cv1, cv2 = .! a.v, .! b.v

	return (a.v == b.v) || (a.v == cv2) || (cv1 == b.v) || (cv1 == cv2)
end

Base.show(io::IO, bp::Bipartition) = print(io, string(bp))

function Base.show(io::IO, ::MIME"text/plain", bp::Bipartition)
	summary(io, bp)
	print(io, "  ", string(bp))

	return nothing
end

function update_bipartition!(p::Node, q::Node, n::Int)
	br = getbranch(p, q)
	v = falses(n)
	if q.species > 0
		v[q.species] = true
	end
	for link in q.links
		link.to == q && continue
		v .|= link.branch.bipart.v
	end
	br.bipart = Bipartition(v)

	return nothing
end


function compute_bipartitions!(tree::AbstractTree, dir::SpeciesDirectory)
	n = length(dir)
	for (p, q) in preorder(tree)
		p == q && continue
		br = getbranch(p, q)
		v = falses(n)
		v[filter(x -> x > 0, getspecies(p, q))] .= true
		v = v[1] ? .!(v) : v
		br.bipart = Bipartition(v)
	end

	return nothing
end

function compute_biparittions!(tree::AbstractTree)
	isnothing(tree.dir) && @error "the tree must have a species directory"

	compute_bipartitions!(tree, tree.dir)

	return nothing
end

function _clear_bipartitions!(p::AbstractNode, q::AbstractNode, nullbp::Bipartition)
	for link in q.links
		link.to == p && continue
		link.branch.bipart = nullbp
		_clear_bipartitions!(q, link.to, nullbp)
	end

	return nothing
end


function clear_bipartitions!(tree)
	nullbp = Bipartition([false])
	for link in tree.origin.links
		_clear_bipartitions!(tree.origin, link.to, nullbp)
	end

	return nothing
end

"""
	istrivial(`bipartition`) -> Bool

A `bipartition` is trivial if it separates just one species from the rest.
"""
function istrivial(bp::Bipartition)::Bool
	i = length(bp.v)
	s = sum(bp.v)
	return (s == i - 1 || s == 1)
end

"""
	isinformative(bipartition) -> Bool

A `bipartition` is informative if it separates at least one species from the rest.

Uninformative bipartitions are not even bipartitions proper, as they don't define disjoint sets of species.
"""
isinformative(bp::Bipartition)::Bool = sum(bp.v) > 0

"""
	are_compatible(bipartition1, bipartition2) -> Bool

Return true if two bipartitions can be present in the same tree.
"""
function are_compatible(bp1::Bipartition, bp2::Bipartition)
	cv1 = .! bp1.v
	cv2 = .! bp2.v

	(bp1.v == bp1.v .| bp2.v) && return true
	(bp1.v == bp1.v .| cv2) && return true
	(cv1 == cv1 .| bp2.v) && return true
	(cv1 == cv1 .| cv2) && return true

	return false
end

"""
	are_conflicting(bipartition1, bipartition2) -> Bool

Return true two bipartitions cannot be present in the same tree.
"""
are_conflicting(bp1::Bipartition, bp2::Bipartition) = ! are_compatible(bp1, bp2)
