module ToyTracker

using StaticArrays
using Makie

greet() = print("Toy model of a particle tracker to create toy MC for alignment studies.")

include("geometry_types.jl")
include("track_types.jl")
include("display.jl")
#include("utils.jl")
#include("geometry.jl")
#include("intersection.jl")

export Pose
export StraightTrack
#export SiliconSensor, PlacedSensor, Tracker
#export Cluster, Hit
#
#export interaction

end # module ToyTracker
