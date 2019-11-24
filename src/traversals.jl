const TRAVERSAL_VECTOR_PRESIZE = 1000

# TODO: Replace the lazy loop-based methods of the iterator interface with recursion-based methods. This is significantly faster and uses less memory.

#####################
#
# Preorder iterator
#
#####################
struct PreorderIterator{T <: AbstractNode}
    start::Tuple{T, T}

    function PreorderIterator(p::T, q::T) where T <: AbstractNode
        p == q || 
        areneighbours(p, q) ||
        throw(InvalidTopology("the nodes must be neighbours."))

        return new{T}((p, q))
    end
end

preorder(p::AbstractNode, q::AbstractNode) = PreorderIterator(p, q)
preorder(p::AbstractNode) = PreorderIterator(p, p)
preorder(t::AbstractTree) = PreorderIterator(t.start, t.start)

struct PreorderIteratorState{T <: AbstractNode}
    stack::Deque{Tuple{T,T}}

    function PreorderIteratorState{T}(p::T, q::T) where T <: AbstractNode
        obj = new(Deque{Tuple{T,T}}())
        push!(obj.stack, (p, q))

        return obj
    end
end

@inline function _iterate(state::PreorderIteratorState)
    isempty(state.stack) && return nothing
    p, q = pop!(state.stack)
    for link ∈ Iterators.reverse(q.links)
        link.to === p && continue
        push!(state.stack, (q, link.to))
    end

    return ((p, q), state)
end # function _iterate

## Hooks to the Base iterator interface ####

Base.IteratorSize(iter::PreorderIterator) = Base.SizeUnknown()
Base.IteratorEltype(iter::PreorderIterator) = Base.HasEltype()
Base.eltype(iter::PreorderIterator{T}) where T = Tuple{T,T}

Base.iterate(iter::PreorderIterator{T}) where T =
    _iterate(PreorderIteratorState{T}(iter.start...))

Base.iterate(iter::PreorderIterator, state::PreorderIteratorState) =
    _iterate(state)

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

The traversal is initiated either from the default start node of the tree, or from an arbitrary node `p`. Subtrees can be traversed by giving the nodes `p` and `q` to define the stem.
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
preorder_vector(t::AbstractTree) = preorder_vector(t.start)


#####################
#
# Postorder iterator
#
#####################

struct PostorderIterator{T <: AbstractNode}
    start::Tuple{T,T}

    function PostorderIterator(p::T, q::T) where T <: AbstractNode
        p == q || 
        areneighbours(p, q) ||
        throw(InvalidTopology("the nodes must be neighbours."))

        return new{T}((p, q))
    end
end

postorder(p::AbstractNode, q::AbstractNode) = PostorderIterator(p, q)
postorder(p::AbstractNode) = PostorderIterator(p, p)
postorder(tree::AbstractTree) = PostorderIterator(tree.start, tree.start)

struct PostorderIteratorState{T <: AbstractNode}
    stack::Deque{Tuple{T,T,Bool}}

    function PostorderIteratorState{T}(p::T, q::T) where T <: AbstractNode
        obj = new(Deque{Tuple{T,T,Bool}}())
        push!(obj.stack, (p, q, false))

        return obj
    end
end # struct PostorderIteratorState

@inline function _iterate(state::PostorderIteratorState)
    isempty(state.stack) && return nothing
    p, q, marked = pop!(state.stack)
    while ! marked
        push!(state.stack, (p, q, true))
        for link ∈ q.links
            link.to == p && continue
            push!(state.stack, (q, link.to, false))
        end
        p, q, marked = pop!(state.stack)
    end

    return ((p, q), state)
end # function iterate

## Hooks to the Base iterator interface ####

Base.IteratorSize(iter::PostorderIterator) = Base.SizeUnknown()
Base.IteratorEltype(iter::PostorderIterator) = Base.HasEltype()
Base.eltype(iter::PostorderIterator{T}) where T = Tuple{T,T}

Base.iterate(iter::PostorderIterator{T}) where T = 
    _iterate(PostorderIteratorState{T}(iter.start...))

Base.iterate(iter::PostorderIterator, state::PostorderIteratorState) =
    _iterate(state)

#####################
#
# Postorder iterator
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

The traversal is initiated either from the default start node of the tree, or from an arbitrary node `p`. Subtrees can be traversed by giving the nodes `p` and `q` to define the stem.
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
postorder_vector(t::AbstractTree) = postorder_vector(t.start)