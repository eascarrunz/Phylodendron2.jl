abstract type AbstractTreeDataBlock end
abstract type AbstractNodeDataBlock end
abstract type AbstractBranchDataBlock end

mutable struct TreeDataBlock{T} <: AbstractTreeDataBlock
    ind::Int
    data::T

    TreeDataBlock{T}() where T = new{T}(0)
end

mutable struct NodeDataBlock{T} <: AbstractNodeDataBlock
    treeblock::AbstractTreeDataBlock
    data::T

    NodeDataBlock{T}(treeblock) where T = new{T}(treeblock)
end

mutable struct BranchDataBlock{T} <: AbstractBranchDataBlock
    treeblock::AbstractTreeDataBlock
    data::T

    BranchDataBlock{T}(treeblock) where T = new{T}(treeblock)
end
