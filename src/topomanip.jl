function _find_neworigin(p::AbstractNode, q::AbstractNode, oldorigin::AbstractNode, neworigin::AbstractNode)
	if n_neighbour(q) > 2
		neworigin = q
	else
		for link in q.links
			link.to == p && continue
			neworigin = _find_neworigin(q, link.to, oldorigin, neworigin)
			neworigin ≠ oldorigin && break
		end
	end

	return neworigin
end

"""
	pluck_nonsplitting!(tree)

Plucks out all the non-splitting nodes in a `tree`.

If the current origin of the tree is a non-splitting node, the next splitting node (in preorder) will be designated as the new origin of the tree.
"""
function pluck_nonsplitting!(tree::AbstractTree)
	targets = find_nonsplitting(tree)
	isempty(targets) && return nothing
	
	neworigin = tree.origin
	if targets[1] == tree.origin
		neworigin = _find_neworigin(tree.origin, tree.origin, tree.origin, tree.origin)
	end

	for p in targets
		q, r = neighbours(p)
		pluck!(p, q, r)
	end

	tree.origin = neworigin

	return nothing
end