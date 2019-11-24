merge!(bdblk1::BranchDataBlock{T}, bdblk2::BranchDataBlock{T}) where T =
	BranchDataBlock{T}()

function _init_data_blocks!(tdblk::TreeDataBlock{T}, t::Tree) where T
	push!(t.datablocks, tdblk)
	tdblk = length(t.datablocks)
	for (p, q) in PreorderIterator(t)
		push!(q.datablocks, NodeDataBlock{T}())
		p == q && continue
		push!(getbranch(p, q), BranchDataBlock{T}())
	end
end

"""
	delete_data_block!(tree, datablock)
	delete_data_block!(tree, index)

Delete a `datablock` from `tree`, including all its node data blocks and branch data blocks.

The methods of this function accept either giving the `TreeDataBlock` object or its index in the `datablocks` array of `tree`.
"""
function delete_data_block!(t::Tree, datablock::AbstractTreeDataBlock)
	ind = datablock.ind
s
	for (p, q) in PreorderIterator(t)
		deleteat!(q.datablocks, ind)
		p == q && continue
		deleteat!(getbranch(p, q).datablocks, ind)
	end

	deleteat!(t.datablocks, ind)

	@inbounds for dblk in t.datablocks[ind:end]
		dblk.ind -= 1
	end

	return nothing
end

delete_data_block!(t::Tree, ind::Int) = delete_data_block!(t, t.datablocks[i])