module ToyTracker

using StaticArrays

greet() = print("Toy model of a particle tracker to create toy MC for alignment studies.")

include("geometry_types.jl")
include("tracker_types.jl")
include("utils.jl")
include("geometry.jl")

end # module ToyTracker
