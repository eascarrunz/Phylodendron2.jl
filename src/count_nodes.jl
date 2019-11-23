function _n_node!(num::Int, p::AbstractNode, q::AbstractNode)
	for link in q.links
		link.to == p && continue
		num = _n_node!(num, q, link.to)
	end

	return num + 1
end

"""
	n_node(tree)
	n_node(p [, q])

Count the nodes in a tree or subtree.
"""
n_node(p::AbstractNode, q::AbstractNode) = _n_node!(0, p, q)
n_node(p::AbstractNode) = _n_node!(0, p, p)
n_node(tree::AbstractTree) = n_node(tree.start, tree.start)

function _n_tip!(num::Int, p::AbstractNode, q::AbstractNode)
	for link in q.links
		link.to == p && continue
		num = _n_tip!(num, q, link.to)
	end

	return ifelse(istip(q), num + 1, num)
end

"""
	n_tip(tree)
	n_tip(p [, q])

Count the tip nodes in a tree or subtree.
"""
n_tip(p::AbstractNode, q::AbstractNode) = _n_tip!(0, p, q)
n_tip(p::AbstractNode) = _n_tip!(0, p, p)
n_tip(tree::AbstractTree) = n_tip(tree.start, tree.start)

"""
	n_branch(tree)
	n_branch(p [, q])

Count the branches in a tree or subtree.
"""
n_branch(p::AbstractNode, q::AbstractNode) = n_node(p, q) - 1
n_branch(p::AbstractNode) = n_branch(p, p)
n_branch(tree::AbstractTree) = n_branch(tree.start, tree.start)