"""
    link!(p, q [, length])
    link!(p, q, branch)

Connect node `p` to node `q` with a new branch. The new branch will have no length if `length` is not given. Alternatively, an existing `Branch` object can be passed instead of creating a new one.

Returns the branch.
"""
function link!(p::AbstractNode, q::AbstractNode, br::AbstractBranch)
    p ≡ q && throw(InvalidTopology("`p` and `q` are the same node"))
    link_p2q = NodeLink(q, br)
    link_q2p = NodeLink(p, br)

    push!(p.links, link_p2q)
    push!(q.links, link_q2p)

    return br
end # function link!

link!(p::AbstractNode, q::AbstractNode) = link!(p, q, Branch())

link!(p::AbstractNode, q::AbstractNode, length::Float64) =
    link!(p, q, Branch(length))

"""
    unlink!(p, q)

Dissociate the nodes `p` and `q` and return the branch that was connecting them.
"""
function unlink!(p::AbstractNode, q::AbstractNode)
    for (i, link) in enumerate(p.links)
        if link.to ≡ q
            for (j, link) in enumerate(q.links)
                if link.to ≡ p
                    @inbounds br = p.links[i].branch
                    deleteat!(p.links, i)
                    deleteat!(q.links, j)

                    return br
                end
            end
        end
    end

    throw(InvalidTopology("the two nodes are not linked."))
end # function unlink!


"""
    graft!(p, q, r; prop_brlength=0.5)
    graft!(p, q, r, branch_pq, branch_qr)

Insert node `p` between the nodes `q` and `r`, where `q` and `r` are neighbours.

The length of the branch between `q` and `r` is redistributed between the new branches (between `p` and `q` and between `q` and `r`) according to the `prop_brlength` parameter, which gives the proportion of the length of the branch between `q` and `r` that is to be assigned to the branch between `p` and `q`. The branch between `q` and `r` is assigned the remainder of the original branch length.

Alternatively, branch objects can be passed to be used as the new branches.
"""
function graft!(
    p::AbstractNode, 
    q::AbstractNode, 
    r::AbstractNode, 
    br_qp::AbstractBranch, 
    br_pr::AbstractBranch
    )

    unlink!(q, r)
    link!(q, p, br_qp)
    link!(p, r, br_pr)
    
    return nothing
end # function graft!

function graft!(
    p::AbstractNode,
    q::AbstractNode,
    r::AbstractNode,
    prop_qp::Float64 = 0.5;
    f::Union{Function, DataType} = Branch
    )
    
    @assert 0.0 ≤ prop_qp ≤ 1.0
    br0 = unlink!(q, r)
    if br0.length ≠ nothing
        link!(q, p, f(br0.length * prop_qp))
        link!(p, r, f(br0.length * (1.0 - prop_qp)))
    else
        link!(q, p, f())
        link!(p, r, f())
    end
    
    return nothing
end # function graft!


"""
    pluck!(p, q, r [, constructor])

Disconnect node `p` from its neighbours `q` and `r`, and connect `q` and `r` to each other. An 
"""
function pluck!(
    p::AbstractNode,
    q::AbstractNode,
    r::AbstractNode,
    f::Union{Function, DataType} = Branch
    )
    br_pq = unlink!(p, q)
    br_pr = unlink!(p, r)

    if isnothing(br_pq.length) || isnothing(br_pr.length)
        br_qr = link!(q, r)
    else
        br_qr = link!(q, r, f(br_pq.length + br_pr.length))
    end

    sizehint!(br_qr.datablocks, length(br_pq.datablocks))

    return nothing
end # function pluck!
