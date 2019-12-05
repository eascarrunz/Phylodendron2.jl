#=
Types and basic constructors for phylogenetic trees
=#

abstract type AbstractTree end
abstract type AbstractNode end
abstract type AbstractBranch end

const NodeVector = Vector{AbstractNode}
const TreeVector = Vector{AbstractTree}

struct NodeLink
    to::AbstractNode
    branch::AbstractBranch
end # struct NodeLink

mutable struct Branch <: AbstractBranch
    length::Union{Float64,Nothing}
    label::String
    annotations::Dict{String,Any}
    datablocks::Vector{AbstractBranchDataBlock}
    bipart::Bipartition

    Branch() = new(nothing, "", Dict{String,Any}(), AbstractBranchDataBlock[], Bipartition(falses(1)))
end # struct Branch

function Branch(brlength::Union{Nothing, Float64})
    br = Branch()
    br.length = brlength

    return br
end # function Branch

mutable struct Node <: AbstractNode
    label::String
    links::Vector{NodeLink}
    species::Int
    annotations::Dict{String,Any}
    datablocks::Vector{AbstractNodeDataBlock}

    function Node()
        links = NodeLink[]
        sizehint!(links, 3)
        new("", links, 0, Dict{String,Any}(), AbstractNodeDataBlock[])
    end
end # struct Node

function Node(l::String)
    p = Node()
    p.label = l

    return p
end # function Node

mutable struct Tree <: AbstractTree
    origin::AbstractNode
    label::String
    rooted::Bool
    dir::SpeciesDirectory
    annotations::Dict{String,Any}
    datablocks::Vector{AbstractTreeDataBlock}

    Tree(p::AbstractNode) =
        new(p, "", false, SpeciesDirectory(), Dict{String,Any}(), AbstractTreeDataBlock[])
end # struct Tree

# mutable struct FixedTree
#     start::Node
#     label::String
#     rooted::Bool
#     preorder::Matrix{Node}
# end