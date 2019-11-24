"""
label(node)

Get the label a node.
"""
label(p::AbstractNode) = p.label

"""
label!(node, v)

Set the string `v` as label of `node`.
"""
function label!(p::AbstractNode, v::String)
	p.label = v

	return nothing
end

"""
	getspecies(node)

Get the number of the species assigned to `node`.
"""
getspecies(p) = p.species

"""
	setspecies!(node, i)

Assign the species number `i` to `node`.
"""
function setspecies!(p::AbstractNode, i::Int)
	p.species = i

	return nothing
end

"""
	annotation(node, k)

Get the value of the annotation with key `k` in `node`.
"""
annotation(p::AbstractNode, k::AbstractString) = p.annotations[k]

"""
	annotate!(node, key, value)

Set the `value` for an annotation `key` in `node`.

Annotation keys can only be `AbstractString`s.
"""
function annotate!(p::AbstractNode, k::AbstractString, v::Any)
	p.annotations[k] = v

	return nothing
end

"""
	deannotate!(node, key)

Remove an annotation `key` from a `node`.
"""
function deannotate!(p::AbstractNode, k::AbstractString)
	delete!(p.annotations, k)

	return nothing
end