# Marco Riggirello


"""
Simple struct to model basic properties of a silicon tracker sensor.

Each size should be in mm (TODO ensure that indeed this is the case). 
"""
struct SiliconSensor
    xwidth::Real
    ywidth::Real
    xpitch::Real
    ypitch::Real
    thickness::Real
end


"""
A Silicon Sensor plus the (active) transformation that describe its position in the global reference frame.
"""
struct PlacedSensor
    sensor::SiliconSensor
    position::Pose
end


"""
Collection of SiliconSensors and their position in the global reference frame.
"""
struct Tracker
    sensors::Dict{String,PlacedSensor}
end


"""
A straight track.

Each vector element should be in mm (TODO ensure that indeed this is the case). 
"""
struct ParticleTrack{T}
    direction::GlobalVector{T}
    position0::GlobalVector{T}
end


"""
A straight track in the reference frame of a PlacedSensor.
"""
struct ProjectedTrack{T}
    direction::LocalVector{T}
    position0::LocalVector{T}
end


"""
The data cluster in one dimension. The cluster witdh is a multiple of the pixelwidth (distribution is uniform).
Dimension should be in mm TODO ensure it.
"""
struct Cluster{T}
    center::T
    width::T
end


"""
The data in the two dimensions.
"""
struct Hit{T} <: FieldVector{2, Cluster{T}}
    localx::Cluster{T}
    localy::Cluster{T}
end
