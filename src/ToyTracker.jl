module ToyTracker

using LinearAlgebra, StaticArrays
using Makie

greet() = print("Toy model of a particle tracker to create toy MC for alignment studies.")

include("geometry_types.jl")
include("track_types.jl")
include("detector_types.jl")
include("geometry.jl")
include("intersection.jl")
include("interaction.jl")
include("display.jl")

export LocalCoordinates, GlobalCoordinates
export LocalDirection, GlobalDirection
export Pose
export AbstractParticleTrack, StraightTrack
export AbstractSiliconSensor, IdealSensor
export PlacedSensor
export AbstractParticleMeasurement, Hit

export intersection, interaction

end
