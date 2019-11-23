#=
`show` methods for phylogenetic trees
=#

function Base.show(io::IO, br::AbstractBranch)
    msg = br.label == "" ? "" : " \"" * br.label * "\" "
    if br.length === nothing
        msg *= "without length"
    else
        msg *= "of length " * string(br.length)
    end
    print(io::IO, "Branch ", msg)

    return nothing
end # function Base.show

function Base.show(io::IO, t::AbstractTree)
    if length(t.label) == 0
        print(io, "Tree")
    else
        print(io, "Tree \"", t.label, "\"")
    end

    return nothing
end # function Base.show

function Base.show(io::IO, ::MIME"text/plain", t::AbstractTree)
    if length(t.label) == 0
        print(io, "Tree")
    else
        print(io, "Tree \"", t.label, "\"")
    end
    print(":\n   ", t.rooted ? "Rooted" : "Unrooted")

    return nothing
end # function Base.show

function Base.show(io::IO, p::AbstractNode)
    if length(p.label) == 0
        print(io, "Node")
    else
        print(io, "Node \"", p.label, "\"")
    end

    return nothing
end # function Base.show

function Base.show(io::IO, ::MIME"text/plain", p::AbstractNode)
    if length(p.label) == 0
        print(io, "Tree")
    else
        print(io, "Node \"", p.label, "\"")
    end
    print(":\n   ", n_neighbour(p), " neighbour(s)")

    return nothing
end # function Base.show