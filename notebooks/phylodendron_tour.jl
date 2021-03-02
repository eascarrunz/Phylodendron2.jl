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

However, trees in Phylodendron2 are \"unrooted\", in the sense that "

# ╔═╡ 235e6ad0-7abd-11eb-124b-751d65551e80
vertebrates, invertebrates = origin.(trees)

# ╔═╡ 128bfba2-7ac2-11eb-1bfd-c950391b9da3
newick_string(trees[1])

# ╔═╡ 1810f262-7ac2-11eb-36c3-ed74dd719d28


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
# ╠═7cbc3992-7abd-11eb-0133-238588eb2c43
# ╠═235e6ad0-7abd-11eb-124b-751d65551e80
# ╠═128bfba2-7ac2-11eb-1bfd-c950391b9da3
# ╠═1810f262-7ac2-11eb-36c3-ed74dd719d28
