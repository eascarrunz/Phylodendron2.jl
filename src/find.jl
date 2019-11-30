const NULLNODE = Node()

function _findfirst(f::Function, p::AbstractNode, q::AbstractNode, r::AbstractNode)
	f(q) && return q
	for link in q.links
		link.to == p && continue
		r = _findfirst(f, q, link.to, r)
		r ≠ NULLNODE && return r
	end

	return NULLNODE
end

"""
	findfirst(f::Function, tree)
	findfirst(f::Function, p [, q])

Return the first node of a tree or subtree for which `f(node)` returns `true`. Return `nothing` if there is no such node.
"""
function Base.findfirst(f::Function, p::AbstractNode, q::AbstractNode)
	r = _findfirst(f, p, q, NULLNODE)
	return r == NULLNODE ? nothing : r
end
Base.findfirst(f::Function, p::AbstractNode) = findfirst(f, p, p)
Base.findfirst(f::Function, tree::AbstractTree) = findfirst(f, tree.origin)

function _findall(
	f::Function, 
	list::Vector{T}, 
	p::T, 
	q::T
	) where T <: AbstractNode
	
	f(q) && push!(list, q)
	for link in q.links
		link.to == p && continue
		_findall(f, list, q, link.to)
	end

	return list
end

"""
	findall(f::Function, tree)
	findall(f::Function, p [, q])

Return a vector of the nodes from a tree or subtree where `f(node)` returns `true`. If no such node is found, return an empty node vector.
"""
Base.findall(f::Function, p::AbstractNode, q::AbstractNode) = 
	_findall(f, Vector{typeof(p)}(), p, q)
Base.findall(f::Function, p::AbstractNode) = _findall(f, Vector{typeof(p)}(), p, p)
Base.findall(f::Function, tree::AbstractTree) = _findall(f, Vector{typeof(tree.origin)}(), tree.origin, tree.origin)

