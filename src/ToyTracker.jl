module ToyTracker

using StaticArrays

greet() = print("Toy model of a particle tracker to create toy MC for alignment studies.")

include("geometry_types.jl")
include("tracker_types.jl")
include("utils.jl")
include("geometry.jl")
include("intersection.jl")

export GlobalVector, Pose
export ParticleTrack
export SiliconSensor, PlacedSensor, Tracker
export Cluster, Hit

export interaction

end # module ToyTracker
