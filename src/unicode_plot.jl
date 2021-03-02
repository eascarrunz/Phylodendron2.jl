using Phylodendron2

HLINE = '─'
VLINE = '│'
TOP_ELBOW = '┌'
THREEWAY = '├'
BOTTOM_ELBOW = '└'
NODE_SYMBOL = '○'

txt = "((((🐇:1,Whale🐳:2):1,(Snake:1,🐢:2):1):6,🐠:1):1,🐌:5);"
txt = "(((A:4,B:1,C:2,D:3):1,E:2):1,(F:1,G:2):4);"
tree = read_newick(text=txt)[1]

function branch2edge(
	p::Node, q::Node, anc::Int, i::Int, edgematrix, labels, branchlengths, nanc
	)
	i += 1		# Last node index
	j = i		# Index of this node
	edgematrix = vcat(edgematrix, [anc j])
	push!(labels, label(q))
	push!(branchlengths, brlength(p, q))
	push!(nanc, nanc[anc] + 1)
	
	for link in q.links
		link.to == p && continue
		i, edgematrix = branch2edge(
			q, link.to, j, i, edgematrix, labels, branchlengths, nanc
			)
	end
	
	return i, edgematrix
end

function branch2edge(tree::Tree)
	i = 1
	anc = 1
	edgematrix = Matrix{Int}(undef, 0, 2)
	nodelabels = String[]			# Node labels
	branchlengths = Union{Float64, Nothing}[]		# Branch lengths
	nanc = [0]						# Number of ancestors of the node
	
	push!(nodelabels, label(tree.origin))
	push!(branchlengths, 0.0)

	for link in tree.origin.links
		i, edgematrix = 
			branch2edge(tree.origin, link.to, anc, i, edgematrix, nodelabels, branchlengths, nanc)
	end

	return (
		edgematrix = edgematrix, 
		nodelabels = nodelabels, 
		branchlengths = branchlengths, 
		nanc = nanc
		)
end

function children_edgematrix(edgematrix, i)
	edges = findall(==(i), edgematrix[:, 1])

	return edgematrix[edges, 2]
end

function compute_ypos(edgematrix, n)
	ypos = zeros(Int, n)
	tips = [i ∉ edgematrix[:, 1] for i in 1:n]

	y = 1
	for i in eachindex(ypos)
		if tips[i]
			ypos[i] = y
			y += 2
		end
	end

	for i in n:-1:1
		chld = children_edgematrix(edgematrix, i)
		if ! isempty(chld)
			y = floor(Int, sum(extrema(ypos[chld])) / 2)
			ypos[i] = y
		end
	end

	return ypos
end

function compute_xpos(edgematrix, brlen, n, s)
	nedge = size(edgematrix, 1)

	xposanc = ones(Int, n)		# Position of the ancestor node
	xposdesc = ones(Int, n)		# Position of the descendant node

	for i in 1:nedge		# start on 2nd index to skip the root
		anc = edgematrix[i, 1]
		desc = edgematrix[i, 2]
		xposanc[desc] = xposdesc[anc] 
		brdesc = floor(Int, (isnothing(brlen[desc]) ? 0 : brlen[desc]) * s)
		xposdesc[desc] = xposanc[desc] + brdesc + 1
	end

	return xposanc, xposdesc
end

function paint_canvas!(A::Matrix{Char}, edgematrix, ypos, xposanc, xposdesc, nodelabels)
	for i in eachindex(ypos)
		x0, x1, y = xposanc[i], xposdesc[i], ypos[i]
		x1 == 0 && continue

		# Draw vertical lines of the fork
		chld = children_edgematrix(edgematrix, i)
		if length(chld) > 1
			ytop, ybottom = extrema(ypos[chld])
			A[ytop+1:ybottom-1, x1] .= VLINE
			A[ypos[chld], x1] .= THREEWAY
			A[ytop, x1] = TOP_ELBOW
			A[ybottom, x1] = BOTTOM_ELBOW
		end

		# Draw node
		A[y, x1] = NODE_SYMBOL

		thislab = nodelabels[i]
		if ! isempty(thislab)
			for j in eachindex(thislab)
				A[y, x1 + 1 + j] = thislab[j]
			end
		end

		# Draw branch
		x0 += 1
		x1 -= 1
		if x1 ≥ x0
			A[y, x0:x1] .= HLINE
		end
	end
end

function print_canvas(io::IO, A::Array{Char})
	nline, ncol = size(A)
	for i in 1:nline
		for j in 1:ncol
			print(io, A[i, j])
		end
		print(io, '\n')
	end

	return nothing
end

function textplot(io::IO, tree::Tree)
	edgematrix, nodelabels, brlen, nanc = branch2edge(tree)
	
	n = length(nodelabels)

	ypos = compute_ypos(edgematrix, n)
	
	canvas_width = displaysize(io)[2]
	minimum_widths = nanc .+ length.(nodelabels) .+ 2
	minimum_width = maximum(minimum_widths)
	
	minimum_width > canvas_width && @error "the tree is too big to be displayed here"
	
	# Compute scaling factor
	s = (canvas_width  .- minimum_widths) ./ brlen |> minimum
	xposanc, xposdesc = compute_xpos(edgematrix, brlen, n, s)

	canvas_height = maximum(ypos)
	canvas = fill(' ', canvas_width, canvas_height);

	paint_canvas!(canvas, edgematrix, ypos, xposanc, xposdesc, nodelabels);
	print_canvas(stdout, canvas)

	return nothing
end

textplot(tree::Tree) = textplot(stdout, tree)

textplot(tree)