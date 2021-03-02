### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 626e2220-790e-11eb-139f-b7d2ee0d998a
using Pkg; Pkg.PackageSpec(url="https://github.com/eascarrunz/Phylodendron2.jl", rev="master") |> Pkg.add

# ╔═╡ 0e3d70ae-790f-11eb-32fc-2d792498f691
using Phylodendron2

# ╔═╡ 2a3f65b0-7929-11eb-1d5d-afcba55895c0
md"# A tour of Phylodendron2

This notebook will give you an overview of the basic funcitonality of Phylodendron2. It is a work in progress, like the package itself!"

# ╔═╡ 3bd68040-792b-11eb-0321-5301587039d4
md"## Installation
Phylodendron2 is not a registered package, so we need to give the URL to its GitHub repository to install it with Julia's package manager. This might take some time, if your computer needs to download and precompile many dependencies."

# ╔═╡ 512bba70-7910-11eb-2c8e-1f3d592b2ec1
md"Now we can simply load the Phylodendron2 module."

# ╔═╡ 7db22080-7937-11eb-39fb-27064e7d1cdd
md"## Reading and writing Newick trees
Let's start creating some trees. As most phylogenetics programs, Phylodendron2 can read the Newick tree format. Let's create a string with Newick trees and read it. I have written two Newick trees in the `text_trees` variable. These trees show the results of the latest phylogenomic studies from the Emoji Research Institute."

# ╔═╡ f5e8d800-790f-11eb-1fc4-359c66f1bd5b
text_trees = "(((🐇,🐳),(🐍,🐢)),🐠);((🐌,🐙),((🐝,🦋),🦞));"

# ╔═╡ 625ccf00-7ab9-11eb-1342-672a24464cf2
md"Reading trees in text strings is simple with the `read_newick` function. This function returns a vector with the two `Tree` objects."

# ╔═╡ aac93c40-7abb-11eb-020d-9b40d8e86e1e
trees = read_newick(text = text_trees)

# ╔═╡ dd8aad60-7b08-11eb-3b0a-a1d3c7ab19a7
md"If you wanted to read the Newick trees from a file instead, you can simply use `read_newick(\"<path to file>\")`.

We can convert back the `Tree` objects to a Newick representation with the function `newick_string`:"

# ╔═╡ fad35200-7b08-11eb-0f67-d7099559a2cd
newick_string.(trees)

# ╔═╡ e2f21f20-7b0a-11eb-3491-ff0e339e401a
md"To write the trees to file, use the `write_newick` function."

# ╔═╡ b720df70-7abb-11eb-3a15-a5adc356c224
md"## Tree objects
Trees in Phylodendron2 are made up of `Node` objects linked to each other. One the main purposes of a `Tree` object is to point to an \"origin\" node that serves as the point of access to the rest of the node network that represents the phylogeny. You can get the \"origin\" node with the `origin` function.

For instance, let's get the origin node of the first tree:"

# ╔═╡ 421a0060-7abd-11eb-0623-6b82635dccd5
origin1 = origin(trees[1])

# ╔═╡ 8bf021b0-7abd-11eb-227e-7d21bcb23b68
md"Unfortunately, this is not very informative. The origin node of the first tree doesn't have a label, so it looks like any other unlabelled node. But we can learn more from looking at its neighbours:"

# ╔═╡ 4ede9630-7abd-11eb-0533-39a8f32d0049
neighbours(origin1)

# ╔═╡ 7cbc3992-7abd-11eb-0133-238588eb2c43
md"The `neighbours` function tells us that `origin1` has two neighbours, and one of them is the node labelled \"🐠\". Taking a look at the original Newick string, you can easily see that \"🐠\" is directly connected to the implicit root of the tree, which Phylodendron2 is using as the origin.

Note that \"origin\" does not mean the *root* of the tree. At the moment, Phylodendron2 only has unrooted trees.

Let's go beyond the origin and traverse the entire tree. We can visit every node in preorder:"

# ╔═╡ 8b3d0060-7b0f-11eb-28c4-a379f19f4356
preorder_vector(trees[1])

# ╔═╡ 91e7bce8-7b0f-11eb-2674-83f7abed6962
md"...or in postorder:"

# ╔═╡ a1777d4c-7b0f-11eb-31dc-7947ac38fa1f
postorder_vector(trees[1])

# ╔═╡ c4bfcbda-7b0f-11eb-1430-e146b9206d00
md"Another very useful way of traversing trees is moving between pais of ancestors and descendants:"

# ╔═╡ ad3377e4-7b0f-11eb-3955-6fdced98c872
preorder(trees[1])

# ╔═╡ 13ac287c-7b10-11eb-12ba-539e2ca17d4f
md"## Working with nodes

The two trees that we have in the `trees` variables are just different animal clades: vertebrates and protostomes. How would we go about combining them into a single tree?

It's easy. Let's first create copies of the trees to keep things tidy. This is done with the `clone` function."

# ╔═╡ d88c4bd6-7b10-11eb-3db8-1390d6b5721f
vertebrates = clone(trees[1])

# ╔═╡ ee357796-7b10-11eb-3cef-2bfae80780b8
protostomes = clone(trees[2])

# ╔═╡ 14bbd450-7b11-11eb-0af4-45c04769db7d
md"And now let's create a new tree with a single origin node."

# ╔═╡ 1defc842-7b11-11eb-3ae9-e1cb9a787149
animals = Tree(Node())

# ╔═╡ 53a5fb3c-7b11-11eb-15b0-1bb348b710e8
md"We use the `link!` function to link the vertebrates and the protostomes to the origin of the tree of all animals."

# ╔═╡ ec2b1b44-7b11-11eb-3e90-3df1269ba761
link!(origin(animals), origin(vertebrates), 2.0)

# ╔═╡ 016bdd36-7b12-11eb-02e5-bf22a1d4c672
link!(origin(animals), origin(protostomes), 5.0)

# ╔═╡ 0cfa9908-7b12-11eb-2517-5121b52aeb8b
md"That is all. This is what the new tree looks like:"

# ╔═╡ 3d6bc08a-7b12-11eb-086e-9fc193856d1d
newick_string(animals)

# ╔═╡ 1810f262-7ac2-11eb-36c3-ed74dd719d28
md"## Species Directories

When linking trees to data or comparing trees to each other, it is useful to have a system that ensures that each species can be uniquely identified with a number. Phylodendron2 uses species directories for that purpose. Let's create one.

We want the directory to contain the names of all the species that we are going to use. They can be gathered from the animal tree with the `tiplabels` function."

# ╔═╡ f044a98e-7b14-11eb-08c9-818f17caa752
spp_names = tiplabels(animals)

# ╔═╡ 004b1db0-7b15-11eb-1ef8-879b4fd53966
directory = SpeciesDirectory(spp_names)

# ╔═╡ 2cbbe78a-7b15-11eb-3f77-bb90371db7a9
md"To access the contents of the directory we can use the index notation with the species name. What is the number of 🐙?"

# ╔═╡ 251e4eda-7b15-11eb-3370-c78ca3e10e00
directory["🐙"]

# ╔═╡ 752c2bd8-7b15-11eb-23ea-a7381f8cbc3f
md"Or, to see all the species at once, we can just access the entire list."

# ╔═╡ c8d55e76-7b15-11eb-1902-c75e6b44bd96
directory.list

# ╔═╡ f1b70c90-7b15-11eb-3ace-217822420a69
md"## Comparing phylogenies"

# ╔═╡ fb90eaba-7b15-11eb-2abf-958209d6ae30
animals.dir = directory

# ╔═╡ 28b472c8-7b16-11eb-0b00-e787ddfad1fa
setspecies!(animals)

# ╔═╡ 0ceb6132-7b16-11eb-2893-35ff60c856cb
compute_bipartitions!(animals, directory)

# ╔═╡ 176b3682-7b16-11eb-0a50-c1916408f167
bipartitions(animals)

# ╔═╡ 21d3f1ea-7b16-11eb-31b2-adebed1e601f
bad_animals = randtree(directory)

# ╔═╡ 61ecc6ee-7b16-11eb-28c8-c9ba1ebbc1ed
compute_bipartitions!(bad_animals, directory)

# ╔═╡ 69927c36-7b16-11eb-3c19-3771939be8a0
bipartitions(bad_animals)

# ╔═╡ 892b4ae6-7b16-11eb-0def-f5241f306496
md"## Quantitative Traits and Brownian Motion"

# ╔═╡ Cell order:
# ╟─2a3f65b0-7929-11eb-1d5d-afcba55895c0
# ╟─3bd68040-792b-11eb-0321-5301587039d4
# ╠═626e2220-790e-11eb-139f-b7d2ee0d998a
# ╟─512bba70-7910-11eb-2c8e-1f3d592b2ec1
# ╠═0e3d70ae-790f-11eb-32fc-2d792498f691
# ╟─7db22080-7937-11eb-39fb-27064e7d1cdd
# ╠═f5e8d800-790f-11eb-1fc4-359c66f1bd5b
# ╟─625ccf00-7ab9-11eb-1342-672a24464cf2
# ╠═aac93c40-7abb-11eb-020d-9b40d8e86e1e
# ╟─dd8aad60-7b08-11eb-3b0a-a1d3c7ab19a7
# ╠═fad35200-7b08-11eb-0f67-d7099559a2cd
# ╟─e2f21f20-7b0a-11eb-3491-ff0e339e401a
# ╟─b720df70-7abb-11eb-3a15-a5adc356c224
# ╠═421a0060-7abd-11eb-0623-6b82635dccd5
# ╟─8bf021b0-7abd-11eb-227e-7d21bcb23b68
# ╠═4ede9630-7abd-11eb-0533-39a8f32d0049
# ╟─7cbc3992-7abd-11eb-0133-238588eb2c43
# ╠═8b3d0060-7b0f-11eb-28c4-a379f19f4356
# ╟─91e7bce8-7b0f-11eb-2674-83f7abed6962
# ╠═a1777d4c-7b0f-11eb-31dc-7947ac38fa1f
# ╟─c4bfcbda-7b0f-11eb-1430-e146b9206d00
# ╠═ad3377e4-7b0f-11eb-3955-6fdced98c872
# ╟─13ac287c-7b10-11eb-12ba-539e2ca17d4f
# ╠═d88c4bd6-7b10-11eb-3db8-1390d6b5721f
# ╠═ee357796-7b10-11eb-3cef-2bfae80780b8
# ╟─14bbd450-7b11-11eb-0af4-45c04769db7d
# ╠═1defc842-7b11-11eb-3ae9-e1cb9a787149
# ╟─53a5fb3c-7b11-11eb-15b0-1bb348b710e8
# ╠═ec2b1b44-7b11-11eb-3e90-3df1269ba761
# ╠═016bdd36-7b12-11eb-02e5-bf22a1d4c672
# ╟─0cfa9908-7b12-11eb-2517-5121b52aeb8b
# ╠═3d6bc08a-7b12-11eb-086e-9fc193856d1d
# ╟─1810f262-7ac2-11eb-36c3-ed74dd719d28
# ╠═f044a98e-7b14-11eb-08c9-818f17caa752
# ╠═004b1db0-7b15-11eb-1ef8-879b4fd53966
# ╟─2cbbe78a-7b15-11eb-3f77-bb90371db7a9
# ╠═251e4eda-7b15-11eb-3370-c78ca3e10e00
# ╟─752c2bd8-7b15-11eb-23ea-a7381f8cbc3f
# ╠═c8d55e76-7b15-11eb-1902-c75e6b44bd96
# ╟─f1b70c90-7b15-11eb-3ace-217822420a69
# ╠═fb90eaba-7b15-11eb-2abf-958209d6ae30
# ╠═28b472c8-7b16-11eb-0b00-e787ddfad1fa
# ╠═0ceb6132-7b16-11eb-2893-35ff60c856cb
# ╠═176b3682-7b16-11eb-0a50-c1916408f167
# ╠═21d3f1ea-7b16-11eb-31b2-adebed1e601f
# ╠═61ecc6ee-7b16-11eb-28c8-c9ba1ebbc1ed
# ╠═69927c36-7b16-11eb-3c19-3771939be8a0
# ╟─892b4ae6-7b16-11eb-0def-f5241f306496
