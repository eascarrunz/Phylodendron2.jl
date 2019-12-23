const TRAVERSAL_VECTOR_PRESIZE = 1000

#####################
#
# Preorder vector
#
#####################

function _prevec!(v::Vector{T}, p::T, q::T) where T <: AbstractNode
    push!(v, q)
    for link in q.links
        link.to == p && continue
        _prevec!(v, q, link.to)
    end

    return v
end

"""
    preorder_vector(tree)
    preorder_vector(p [, q])

Get a vector with the nodes of `tree` in preorder.

The traversal is initiated either from the default origin node of the tree, or from an arbitrary node `p`. Subtrees can be traversed by giving the nodes `p` and `q` to define the stem.

See also: [`postorder`](@ref), [`postorder_vector`](@ref), [`preorder`](@ref)
"""
function preorder_vector(p::AbstractNode, q::AbstractNode)
    p == q ||
        areneighbours(p, q) ||
        throw(InvalidTopology("the nodes must be neighbours."))
    v = Vector{typeof(p)}()
    sizehint!(v, TRAVERSAL_VECTOR_PRESIZE)
    return _prevec!(v, p, q)
end
preorder_vector(p::AbstractNode) = preorder_vector(p, p)
preorder_vector(t::AbstractTree) = preorder_vector(t.origin)

#####################
#
# Preorder iterator
#
#####################

function _gather_preorder(list::Vector{Tuple{T,T}}, p::T, q::T) where T <: AbstractNode
    push!(list, (p, q))
    for link in q.links
        link.to == p && continue
        _gather_preorder(list, q, link.to)
    end

    return list
end

"""
    preorder(tree)
    preorder(p [, q])

Get a vector of parent-child tuples with the nodes of `tree` in preorder.

The traversal is initiated either from the default origin node of the tree, or from an arbitrary node `p`. Subtrees can be traversed by giving the nodes `p` and `q` to define the stem.

See also: [`postorder`](@ref), [`postorder_vector`](@ref), [`preorder_vector`](@ref)
"""
function preorder(p::T, q::T) where T <: AbstractNode
    p == q ||
        areneighbours(p, q) ||
        throw(InvalidTopology("the nodes must be neighbours."))
    
    return _gather_preorder(Vector{Tuple{T,T}}(), p, q)
end
preorder(p::AbstractNode) = preorder(p, p)
preorder(t::AbstractTree) = preorder(t.origin, t.origin)

#####################
#
# Postorder vector
#
#####################

function _postvec!(v::Vector{T}, p::T, q::T) where T <: AbstractNode
    for link in Iterators.reverse(q.links)
        link.to == p && continue
        _postvec!(v, q, link.to)
    end
    push!(v, q)

    return v
end

"""
    postorder_vector(tree)
    postorder_vector(p [, q])

Get a vector with the nodes of `tree` in postorder.

The traversal is initiated either from the default origin node of the tree, or from an arbitrary node `p`. Subtrees can be traversed by giving the nodes `p` and `q` to define the stem.

See also: [`postorder`](@ref), [`preorder`](@ref), [`preorder_vector`](@ref)
"""
function postorder_vector(p::AbstractNode, q::AbstractNode)
    p == q ||
        areneighbours(p, q) ||
        throw(InvalidTopology("the nodes must be neighbours."))
    v = Vector{typeof(p)}()
    sizehint!(v, TRAVERSAL_VECTOR_PRESIZE)
    return _postvec!(v, p, q)
end
postorder_vector(p::AbstractNode) = postorder_vector(p, p)
postorder_vector(t::AbstractTree) = postorder_vector(t.origin)

#####################
#
# Postorder iterator
#
#####################

function _gather_postorder(list::Vector{Tuple{T,T}}, p::T, q::T) where T <: AbstractNode
    for link in Iterators.reverse(q.links)
        link.to == p && continue
        _gather_postorder(list, q, link.to)
    end
    push!(list, (p, q))

    return list
end

"""
    postorder(tree)
    postorder(p [, q])

Get a vector of parent-child tuples with the nodes of `tree` in postorder.

The traversal is initiated either from the default origin node of the tree, or from an arbitrary node `p`. Subtrees can be traversed by giving the nodes `p` and `q` to define the stem.

See also: [`postorder_vector`](@ref), [`preorder`](@ref), [`preorder_vector`](@ref)
"""
function postorder(p::T, q::T) where T <: AbstractNode
    p == q ||
        areneighbours(p, q) ||
        throw(InvalidTopology("the nodes must be neighbours."))
    
    return _gather_postorder(Vector{Tuple{T,T}}(), p, q)
end
postorder(p::AbstractNode) = postorder(p, p)
postorder(t::AbstractTree) = postorder(t.origin, t.origin)

