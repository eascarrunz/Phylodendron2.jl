"""
	Bipartition

Bit vector representing how a branch separates two exclusive sets of species in a tree. Unrooted tree bipartitions uniquely characterise branches invariantly to the position of the root or tree origin.
"""
struct Bipartition
	v::BitVector

	function Bipartition(v::BitVector)
		v = v[1] ? .!v : v

		return new(v)
	end
end
