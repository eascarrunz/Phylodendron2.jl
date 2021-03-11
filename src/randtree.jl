"""
    randtree(n::Int, rooted::Bool = false, labels=string.(1:n))

Create a binary tree by the random addition of `n` tips.
"""
function _randtree_rooted(
	n::Int, 
	labels::Vector{String}, 
	spp::Vector{Int}
	)

	nodes = Vector{Node}(undef, 2n - 1)
	origin = Node()
	nodes[1:3] .= origin, Node(labels[1]), Node(labels[2])
	link!(origin, nodes[2])
	link!(origin, nodes[3])
	nodes[2].species = spp[1]
	nodes[3].species = spp[2]

	for i ∈ 3:n
		p = Node(labels[i])
		p.species = spp[i]
		q = rand(nodes[1:(2i - 3)])
		r = rand(neighbours(q))

		s = Node()
		link!(p, s)

		graft!(s, q, r)

		nodes[(2i - 2):(2i - 1)] .= r, s
	end

	return origin
end

function _randtree_unrooted(n::Int, labels::Vector{String}, spp::Vector{Int})
	# TODO: create all the nodes in `nodes` first so that the rest of the function just creates links and sets labels.
	origin = Node()
	nodes = Vector{Node}(undef, 2n - 2)
	nodes[1:4] .= origin, Node(labels[1]), Node(labels[2]), Node(labels[3])
	nodes[2].species = spp[1]
	nodes[3].species = spp[2]
	nodes[4].species = spp[3]

	link!(origin, nodes[2])
	link!(origin, nodes[3])
	link!(origin, nodes[4])

	for i ∈ 4:n
		p = Node(labels[i])
		p.species = spp[i]
		q = rand(nodes[1:(2i - 4)])
		r = rand(neighbours(q))

		s = Node()
		link!(s, p)

		graft!(s, q, r)

		nodes[(2i - 3):(2i - 2)] .= p, s
	end

	return origin
end

"""
	randtree(n, rooted = false; labels, spp)

Create a binary tree (un`rooted` by default) by the random addition of `n` tips.

The tip `labels` can be provided as a vector of strings, or else the tips will be labelled in sequence from 1 to `n`. The tip `species` can be given as a vector of positive integers, or else they will all be 0.
"""
function randtree(
	n::Int, 
	rooted::Bool=false; 
	labels::Vector{String}=string.(1:n),
	species::Vector{Int}=zeros(Int, n)
	)
	@assert n == length(labels) == length(species)
	if n < 2
		@error "at least two tips are required for a rooted binary tree, or three for an unrooted binary tree."
	elseif n == 2
		rooted || @error "cannot create an unrooted binary tree with fewer than 3 tips."

		origin = Node()
		tip1 = Node(labels[1])
		tip1.species = species[1]
		tip2 = Node(labels[2])
		tip2.species = species[2]

		# Although the topologies are identical, we are going to randomise the order of the tips.
		if rand(Bool)
			link!(origin, tip1)
			link!(origin, tip2)
		else
			link!(origin, tip2)
			link!(origin, tip1)
		end
		
	elseif n == 3
		if rooted
			origin = _randtree_rooted(n, labels, species)
		else
			origin = Node()
			tips = map(Node, labels)
			for i in randperm(3)
				link!(origin, tips[i])
				tips[i].species = species[i]
			end
		end
	else
		origin = rooted ? _randtree_rooted(n, labels, species) : 
			_randtree_unrooted(n, labels, species)
	end	
	tree = Tree(origin)
	rooted && root!(tree)

	return tree
end

"""
	randtree(labels, rooted = false)

Create a binary tree (un`rooted` by default) by the random addition of tips with the given `labels`.
"""
randtree(labels::Vector{String}, rooted::Bool = false) =
	randtree(length(labels), rooted; labels = labels)

"""
	randtree(dir, rooted = false)

Create a binary tree (un`rooted` by default) by the random addition of tips with the species from a species `dir`ectory.
"""
function randtree(dir::SpeciesDirectory, rooted::Bool = false)
	tree = 
		randtree(length(dir), rooted; labels = dir.list, species = collect(1:length(dir)))
	tree.dir = dir

	return tree
end