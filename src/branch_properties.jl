"""
	brlength(p, q)

Get the length of the branch between the nodes `p` and `q`.
"""
brlength(p::AbstractNode, q::AbstractNode) = getbranch(p, q).length

"""
    brlength!(p, q, length)

Set the `length` (`Float64` or `Nothing`) of the branch between the nodes `p` and `q`.
"""
function brlength!(p::AbstractNode, q::AbstractNode, v::Union{Nothing, Float64})
    getbranch(p, q).length = v
    
    return nothing
end

"""
brlabel(p, q)

Get the label of the branch between nodes `p` and `q`.
"""
brlabel(p::AbstractNode, q::AbstractNode) = getbranch(p, q).label

"""
brlabel!(p, q, v)

Set the string `v` as label of branch between the nodes `p` and `q`.
"""
function brlabel!(p::AbstractNode, q::AbstractNode, v::String)
	getbranch(p, q).label = v

	return nothing
end

"""
	brannotation(p, q, k)

Get the value of the annotation with key `k` in the branch between nodes `p` and `q`.
"""
brannotation(p::AbstractNode, q::AbstractNode, k::AbstractString) = 
	getbranch(p, q).annotations[k]

"""
	brannotate!(node, key, value)

Set the `value` for an annotation `key` in the branch between the nodes `p` and `q`.

Annotation keys can only be `AbstractString`s.
"""
function brannotate!(p::AbstractNode, q::AbstractNode, k::AbstractString, v::Any)
	getbranch(p, q).annotations[k] = v

	return nothing
end

"""
	brdeannotate!(p, q, key)

Remove an annotation `key` from the branch between the nodes `p` and `q`.
"""
function brdeannotate!(p::AbstractNode, q::AbstractNode, k::AbstractString)
	delete!(getbranch(p, q).annotations, k)

	return nothing
end