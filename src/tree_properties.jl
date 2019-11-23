"""
	isrooted(tree)

Return `true` if the `tree` is rooted.
"""
isrooted(tree::AbstractTree) = tree.rooted

"""
	origin(tree)

Return the "origin" of a `tree`: The node that serves as the default point of entrance to the tree
"""
origin(tree::AbstractTree) = tree.start

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