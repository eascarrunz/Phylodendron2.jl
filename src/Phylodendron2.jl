#=

There are redundant exports in this file because it is also used to keep track of where different methods come from. Each source file inclusion should be followed by an export statement with an alphabetic list of all the exported functions with a method that comes from that file. Please keep this format.

=#

module Phylodendron2

using Random: randperm
using DelimitedFiles: readdlm
using PrettyTables

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

include("species_data.jl")
export
    read_species_data,
    SpeciesDataMatrix,
    write_phylip

include("bipartition.jl")
export
    Bipartition

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

include("clone.jl")
export
    clone

include("node_properties.jl")
export
    annotate!,
    annotation,
    deannotate!,
    label,
    label!,
    getspecies,
    setspecies!

include("find.jl")
# exports methods for findfirst and findall

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

include("datablocks/manipulation.jl")
export
    delete_datablock!

include("tree_properties.jl")
export
    annotate!,
    annotation,
    deannotate!,
    isrooted,
    label,
    label!,
    origin,
    origin!,
    root!,
    setspecies!,
    unroot!

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

include("subtree_funcs.jl")
export
    bipartitions,
    find_nonsplitting,
    getspecies,
    n_branch,
    n_node,
    n_species,
    n_tip,
    nodelabels,
    tiplabels,
    tips

include("topomanip.jl")
export
    pluck_nonsplitting!

include("node_paths.jl")
export
    brdist,
    nodepath,
    nodedist

include("bipartition_funcs.jl")
export
    are_compatible,
    are_conflicting,
    compute_bipartitions!,
    isinformative,
    istrivial,
    update_bipartition!

include("lexer.jl")
include("newick.jl")
export
    newick_string,
    parse_newick,
    read_newick,
    write_newick

include("randtree.jl")
export
    randtree

include("BrownianModels/BrownianModels.jl")

end # module Phylodendron2
