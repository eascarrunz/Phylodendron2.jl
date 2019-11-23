"""
    SpeciesDirectory

Object for maintaining lists of species and their names. It can be queried by species name with the `in` function and the same indexing notation used for `Dict`s.

Each species is assigned an index starting from 1, and optionally a unique name. Species can be added and deleted with the functions `addspecies!` and `delete!`. Note that deleting a species will cause a shift in the indices of all the species that followed it.

See also: `addpsecies!`, `delete!`, `rename!`
"""
struct SpeciesDirectory
    list::Vector{String}
    dict::Dict{String,Int}

    SpeciesDirectory() = new(String[], Dict{String,Int}())
end # struct SpeciesDirectory

"""
    SpeciesDirectory(names)

Cerate a species directory from a list of unique `names` given as a string vector.
"""
function SpeciesDirectory(namelist::Vector{String})
    propernames = filter(x -> x ≠ "", namelist)
    allunique(propernames) || throw(SpeciesNameCollision())
    dir = SpeciesDirectory()
    push!(dir.list, namelist...)
    for (i, name) ∈ enumerate(dir.list)
        name == "" && continue
        dir.dict[name] = i
    end

    return dir
end

Base.length(dir::SpeciesDirectory) = length(dir.list)

Base.getindex(dir::SpeciesDirectory, str::String) = dir.dict[str]

function Base.getindex(dir::SpeciesDirectory, names::Vector{String})
    return map(x -> getindex(dir, x), names)
end

function Base.getindex(dir::SpeciesDirectory, names::String...)
    return collect(map(x -> getindex(dir, x), names))
end

"""
    in(i, dir) -> Bool
    in(name, dir) -> Bool

Return true if there is a species with the index number `i` or with the given `name` in the species directory `dir`.
"""
function Base.in(i::Int, dir::SpeciesDirectory)::Bool
    i < 1 && throw(BoundsError(dir.list, i))
    return length(dir.list) ≥ i ? true : false
end

Base.in(str::String, dir::SpeciesDirectory) = haskey(dir.dict, str)

"""
    addpsecies!(dir [, name])

Add a new species to the species directory `dir`. `name` can be ommited to create an unnamed species.
"""
function addspecies!(dir::SpeciesDirectory, speciesname::String)
    haskey(dir.dict, speciesname) && throw(SpeciesNameCollision([speciesname]))
    push!(dir.list, speciesname)
    i = length(dir)
    if speciesname ≠ ""
        dir.dict[speciesname] = i
    end
    return dir
end # function push!

addspecies!(dir::SpeciesDirectory) = addspecies!(dir, "")

"""
    rename!(dir, oldname, newname)
    rename!(dir, ind, newname)

Change the name of a species in the SpeciesDirectory `dir` from `oldname` to `newname`.

The species index `ind` can also be given instead of `oldname`. This way it is possible to give a name to a species that currently doesn't have one.
"""
function rename!(dir::SpeciesDirectory, i::Int, newname::String)
    haskey(dir.dict, newname) && throw(SpeciesNameCollision(newname))
    oldname = dir.list[i]
    delete!(dir.dict, oldname)
    dir.dict[newname] = i
    dir.list[i] = newname

    return nothing
end # function rename!

rename!(dir::SpeciesDirectory, oldname::String, newname::String) =
    rename!(dir, dir.dict[oldname], newname)

"""
    delete!(dir, ind)
    delete!(dir, name)

Delete the species with index `ind` or the given `name` from the species directory `dir`.

Note that deleting a species will cause a shift in the indices of all the species that followed it.
"""
function Base.delete!(dir::SpeciesDirectory, ind::Int)
    for (k, v) in pairs(dir.dict)
        if v > ind
            dir.dict[k] = v - 1
        end
    end
    dir.list[ind] ≠ "" && delete!(dir.dict, dir.list[ind])
    deleteat!(dir.list, ind)

    return nothing
end # function delete!

Base.delete!(dir::SpeciesDirectory, spname::String) =
    delete!(dir, dir.dict[spname])
