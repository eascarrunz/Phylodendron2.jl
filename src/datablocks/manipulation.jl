# merge!(bdblk1::BranchDataBlock{T}, bdblk2::BranchDataBlock{T}) where T =
# 	BranchDataBlock{T}()

# function _init_datablocks!(tdblk::TreeDataBlock{T}, t::Tree) where T
# 	push!(t.datablocks, tdblk)
# 	tdblk = length(t.datablocks)
# 	for (p, q) in PreorderIterator(t)
# 		push!(q.datablocks, NodeDataBlock{T}())
# 		p == q && continue
# 		push!(getbranch(p, q), BranchDataBlock{T}())
# 	end
# end


function _delete_datablock!(p::AbstractNode, q::AbstractNode, ind::Int)
	for link in q.links
		link.to == p && continue
		_delete_datablock!(q, link.to, ind)
		deleteat!(link.branch.datablocks, ind)
		for dblk in link.branch.datablocks[ind:end]
			dblk.ind -= 1
		end
	end

	deleteat!(q.datablocks, ind)
	# for dblk in q.datablocks[ind:end]
	# 	dblk.ind -= 1
	# end

	return nothing
end

"""
	delete_datablock!(tree, datablock)
	delete_datablock!(tree, index)

Delete a `datablock` from `tree`, including all its node data blocks and branch data blocks.

The methods of this function accept either giving the `TreeDataBlock` object or its index in the `datablocks` array of `tree`.
"""
function delete_datablock!(tree::Tree, ind::Int)
	@assert 0 < ind ≤ length(tree.datablocks)

	_delete_datablock!(tree.origin, tree.origin, ind)

	deleteat!(tree.datablocks, ind)

	@inbounds for dblk in tree.datablocks[ind:end]
		dblk.ind -= 1
	end

	return nothing
end

delete_datablock!(tree::Tree, datablock::AbstractTreeDataBlock) = 
	delete_datablock!(t, datablock.ind)