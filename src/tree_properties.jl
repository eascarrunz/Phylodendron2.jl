"""
	isrooted(tree)

Return `true` if the `tree` is rooted.
"""
isrooted(tree::AbstractTree) = tree.rooted

"""
	root!(tree)

Set a `tree` as rooted. The origin node of the tree is set as the root.
"""
function root!(tree::AbstractTree)
	tree.rooted = true

	return nothing
end

"""
	root!(tree, node)

Set `node` as the root of a `tree`.
"""
function root!(tree::AbstractTree, p::AbstractNode)
	tree.start = p
	root!(tree)

	return nothing
end

"""
	unroot!(tree)

Set a `tree` as unrooted.
"""
function unroot!(tree::AbstractTree)
	tree.rooted = false

	return nothing
end

"""
	origin(tree)

Return the "origin" of a `tree`: The node that serves as the default point of entry to the tree.
"""
origin(tree::AbstractTree) = tree.start

"""
	origin!(tree, node)

Set `node` as the "origin" of `tree`. The origin of the tree serves as a "pseudoroot": the default point of entry to the tree.
"""
function origin!(tree::AbstractTree, p::AbstractNode)
	tree.start = p
end

"""
	label(tree)

Get the label of a `tree`.
"""
label(tree::AbstractTree) = tree.label

"""
	label(tree, v)

Set the string `v` as the label of a `tree`.
"""
function label!(tree::AbstractTree, v::String)
	tree.label = v

	return nothing
end

"""
	annotation(tree, k)

Get the value of the annotation with key `k` in `tree`.
"""
annotation(tree::AbstractTree, k::AbstractString) = tree.annotations[k]

"""
	annotate!(tree, key, value)

Set the `value` for an annotation `key` in `tree`.

Annotation keys can only be `AbstractString`s.
"""
function annotate!(tree::AbstractTree, k::AbstractString, v::Any)
	tree.annotations[k] = v

	return nothing
end

"""
	deannotate!(tree, key)

Remove an annotation `key` from a `tree`.
"""
function deannotate!(tree::AbstractTree, k::AbstractString)
	delete!(tree.annotations, k)

	return nothing
end

function _setspecies!(p::AbstractNode, q::AbstractNode, dir::SpeciesDirectory)
	if label(q) ∈ dir
		q.species = dir[label(q)]
	end
	for link in q.links
		link.to == p && continue
		_setspecies!(q, link.to, dir)
	end
end

setspecies!(tree::AbstractTree, dir::SpeciesDirectory) =
	_setspecies!(tree.start, tree.start, dir)
