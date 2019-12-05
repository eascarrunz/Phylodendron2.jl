"""
	clone(tree)

Create an independent duplicate of `tree`.

The new tree shares the same species directory as the original tree, but all the other properties of the original tree, nodes, and branches are copied rather than referenced.
"""
function clone(tree::Tree)
	tree2 = Tree(deepcopy(tree.origin))
	tree2.label = tree.label
	tree2.rooted = tree.rooted
	tree2.dir = tree.dir
	tree2.annotations = deepcopy(tree.annotations)
	tree2.datablocks = deepcopy(tree.datablocks)

	return tree2
end # function clone
