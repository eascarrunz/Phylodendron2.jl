
function _ladderise!(p::AbstractNode, q::AbstractNode, rev::Bool)
	istip(q) && return 1
	stsizes = zeros(Int, length(q.links))
	@inbounds for (i, link) in enumerate(q.links)
		link.to == p && continue
		stsizes[i] = _ladderise!(q, link.to, rev)
	end
	permute!(q.links, sortperm(stsizes; rev=rev))

	return sum(stsizes) + 1
end

"""
	ladderise!(tree [, sense = :right])

Rearrange the links in each node of `tree` so that bigger subtrees are always to the right (`sense = :right`) or the left (`sense = :left`).

Left and right orientations are relative to the origin node of the tree.
"""
function ladderise!(tree::AbstractTree; sense=:right)
	if sense == :right
		_ladderise!(tree.origin, tree.origin, false)
	elseif sense == :left
		_ladderise!(tree.origin, tree.origin, true)
	else
		throw(
			ErrorException("invalid ladderisation sense " * ":" * string(sense))
			)
	end

	return nothing
end