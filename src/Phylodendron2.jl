#=
This code is released under public domain.

It is not required that you give credit to the author, but if you use this software for scientific purposes, it is good practice to make the source code available with a link to a stable repository.
=#

module Phylodendron2

include("exceptions.jl")

include("species_directory.jl")
export
    addspecies!,
    delete!,
    getindex,
    in,
    length,
    rename!,
    SpeciesDirectory

include("datablocks/types.jl")
export
    AbstractBranchDataBlock,
    AbstractNodeDataBlock,
    AbstractTreeDataBlock,
    BranchDataBlock,
    NodeDataBlock,
    TreeDataBlock

include("tree/types.jl")
export
    AbstractBranch,
    AbstractNode,
    AbstractTree,
    Branch,
    Node,
    NodeVector,
    Tree,
    TreeVector

include("node_properties.jl")
export
    annotate!,
    annotation,
    deannotate!,
    label,
    label!,
    species,
    species!

include("peek_topology.jl")
export
    areneighbours,
    getbranch,
    istip,
    neighbours,
    n_neighbour

include("branch_properties.jl")
export
    brannotate!,
    brannotation,
    brdeannotate!,
    brlabel,
    brlabel!,
    brlength,
    brlength!

include("tree_properties.jl")
export
    annotate!,
    annotation,
    deannotate!,
    isrooted,
    label,
    label!,
    origin

include("show.jl")

include("link.jl")
export
    graft!,
    link!,
    pluck!,
    unlink!

include("traversals.jl")
export
    postorder,
    postorder_vector,
    preorder,
    preorder_vector

include("count_nodes.jl")
export
    n_branch,
    n_node,
    n_tip

include("node_paths.jl")
export
    brdist,
    nodepath,
    nodedist

include("lexer.jl")
include("newick.jl")
export
    newick_string,
    parse_newick,
    read_newick,
    write_newick

end # module Phylodendron2
