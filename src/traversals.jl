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

struct PreorderIterator{T <: AbstractNode}
    list::Vector{Tuple{T,T}}
    n::Int

    function PreorderIterator(p::T, q::T) where T <: AbstractNode
        p == q ||
            areneighbours(p, q) ||
            throw(InvalidTopology("the nodes must be neighbours."))
        list = _gather_preorder(Vector{Tuple{T,T}}(), p, q)
        new{T}(list, length(list))
    end
end

preorder(p::AbstractNode, q::AbstractNode) = PreorderIterator(p, q)
preorder(p::AbstractNode) = PreorderIterator(p, p)
preorder(t::AbstractTree) = PreorderIterator(t.origin, t.origin)

## Hooks to the Base iterator interface ####

Base.IteratorSize(iter::PreorderIterator) = Base.HasLength()
Base.IteratorEltype(iter::PreorderIterator) = Base.HasEltype()
Base.eltype(iter::PreorderIterator{T}) where T = Tuple{T,T}

Base.length(iter::PreorderIterator) = length(iter.list)
Base.iterate(iter::PreorderIterator, state::Int = 1) =
    state > iter.n ? nothing : (iter.list[state], state + 1)

Base.firstindex(iter::PreorderIterator) = firstindex(iter.list)
Base.lastindex(iter::PreorderIterator) = lastindex(iter.list)
Base.getindex(iter::PreorderIterator, inds...) = getindex(iter.list, inds...)

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

struct PostorderIterator{T <: AbstractNode}
    list::Vector{Tuple{T,T}}
    n::Int

    function PostorderIterator(p::T, q::T) where T <: AbstractNode
        p == q ||
            areneighbours(p, q) ||
            throw(InvalidTopology("the nodes must be neighbours."))
        list = _gather_postorder(Vector{Tuple{T,T}}(), p, q)
        new{T}(list, length(list))
    end
end

postorder(p::AbstractNode, q::AbstractNode) = PostorderIterator(p, q)
postorder(p::AbstractNode) = PostorderIterator(p, p)
postorder(t::AbstractTree) = PostorderIterator(t.origin, t.origin)

## Hooks to the Base iterator interface ####

Base.IteratorSize(iter::PostorderIterator) = Base.HasLength()
Base.IteratorEltype(iter::PostorderIterator) = Base.HasEltype()
Base.eltype(iter::PostorderIterator{T}) where T = Tuple{T,T}

Base.length(iter::PostorderIterator) = length(iter.list)
Base.iterate(iter::PostorderIterator, state::Int = 1) =
    state > iter.n ? nothing : (iter.list[state], state + 1)

Base.firstindex(iter::PostorderIterator) = firstindex(iter.list)
Base.lastindex(iter::PostorderIterator) = lastindex(iter.list)
Base.getindex(iter::PostorderIterator, inds...) = getindex(iter.list, inds...)
