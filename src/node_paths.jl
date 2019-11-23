function _nodepath(p::T, q::T, target::T, path::Vector{T}, keep::Bool) where T <: AbstractNode
    for link in q.links
        link.to == p && continue
        if link.to == target
            keep = true
            push!(path, link.to)
            break
        end
        istip(link.to) && continue
        keep, path = _nodepath(q, link.to, target, path, keep)
        keep && break
    end
    keep && push!(path, q)

    return keep, path
end

"""
    nodepath(p, q)

Find the shortest path from node `p` to node `q`.
"""
function nodepath(p::T, q::T) where T <: AbstractNode
	keep, path = _nodepath(q, q, p, Vector{T}(), false)
	keep = keep ? true : p == q
	keep || throw(InvalidTopology("no path was found between the two nodes."))

	return path
end



function _nodedist(p::AbstractNode, q::AbstractNode, target::AbstractNode, d::Int, keep::Bool)
	for link in q.links
		link.to == p && continue
		if link.to == target
			keep = true
			d += 1
			break
		end
		istip(link.to) && continue
		keep, d = _nodedist(q, link.to, target, d, keep)
		keep && break
	end
	d += keep ? 1 : 0
	
	return keep, d
end

"""
    nodedist(p, q)

Count the nodes along the shortest path between node `p` and node `q`.
"""
function nodedist(p::AbstractNode, q::AbstractNode)
	keep, d = _nodedist(q, q, p, 0, false)
	keep = keep ? true : p == q
	keep || throw(InvalidTopology("no path was found between the two nodes."))

	return d > 0 ? d - 2 : 0
end


function _brdist(p::AbstractNode, q::AbstractNode, target::AbstractNode, d::Float64, keep::Bool)
	for link in q.links
		link.to == p && continue
		if link.to == target
			keep = true
			d += link.branch.length
			break
		end
		istip(link.to) && continue
		keep, d = _brdist(q, link.to, target, d, keep)
		keep && break
	end
	d += keep ? brlength(p, q) : 0.0

	return keep, d
end



"""
	brdist(p, q)

Get the sum of the lengths of the branches along the shortest path between node `p` and node `q`.
"""
function brdist(p::AbstractNode, target::AbstractNode)
	d = 0.0
	keep = false
	for link in p.links
		if link.to == target
			return link.branch.length
		end
		istip(link.to) && continue
		keep, d = _brdist(p, link.to, target, d, keep)
		keep && break
	end

	keep = keep ? true : p == target
	keep || throw(InvalidTopology("no path was found between the two nodes."))

	return d
end
# brdist(p::AbstractNode, q::AbstractNode) =
# 	_brdist(q, q, p, 0.0, false)[2]