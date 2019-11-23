"""
    getbranch(p, q)

Get the branch that connects node `p` to node `q`.
"""
function getbranch(p::AbstractNode, q::AbstractNode)::Branch
    for link ∈ p.links
        if link.to ≡ q
            return link.branch
        end
    end

    p ≡ q && throw(InvalidTopology("`p` and `q` are the same node"))
    throw(InvalidTopology("`p` is not linked to `q`"))
end # function getbranch

"""
    neighbours(p)

Get all the nodes connected to node `p`.
"""
neighbours(p::AbstractNode) = map(x -> x.to, p.links)

"""
    n_neighbour(p)

Get the number of neighbours of node `p`.
"""
n_neighbour(p::AbstractNode) = length(p.links)

"""
    istip(p::AbstractNode)

Return true if node `p` is a tip, i.e. it has exactly one neighbour.
"""
istip(p::AbstractNode) = length(p.links) == 1

"""
    areneighbours(p, q)

Return true if node `p` is a neighbour of node `q`.
"""
function areneighbours(p::AbstractNode, q::AbstractNode)
    p2q, q2p = false, false
    for link ∈ p.links
        if link.to ≡ q
            p2q = true
            break
        end
    end
    for link ∈ q.links
        if link.to ≡ p
            q2p = true
            break
        end
    end
    if p2q ⊻ q2p
        p2q && throw(InvalidTopology("the link from `q` to `p` is missing."))
        q2p && throw(InvalidTopology("the link from `p` to `q` is missing."))
    end

    return p2q
end # function areneighbours