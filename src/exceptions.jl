struct InvalidTopology <: Exception
    msg::String
end

struct SpeciesNameCollision <: Exception
    sppnames::Vector{String}
end

SpeciesNameCollision() = SpeciesNameCollision(String[])

function Base.showerror(io::IO, ex::SpeciesNameCollision)
    if isempty(ex.sppnames)
        print(io, "All the species names in the directory must be unique.")
    else
        msg = "The following names are already present in the species name list: "
        print(io, msg, ex.sppnames)
    end

    return nothing
end
