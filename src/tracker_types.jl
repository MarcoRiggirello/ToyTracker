# Marco Riggirello


"""
Simple struct to model basic properties of a silicon tracker sensor.

Each size should be in mm (TODO ensure that indeed this is the case). 
"""
struct SiliconSensor{T}
    xwidth::T
    ywidth::T
    xpitch::T
    ypitch::T
    thickness::T
end


"""
A Silicon Sensor plus the (active) transformation that describe its position in the global reference frame.
"""
struct PlacedSensor{T}
    sensor::SiliconSensor{T}
    position::Pose{T}
end


"""
Collection of SiliconSensors and their position in the global reference frame.
"""
struct Tracker{T}
    sensors::Dict{String,PlacedSensor{T}}
end


"""
A straight track.

Each vector element should be in mm (TODO ensure that indeed this is the case). 
"""
struct ParticleTrack{T}
    direction::GlobalDirection{T}
    position0::GlobalVector{T}
end


ParticleTrack{T}(mx, my, x0, y0) where {T} = ParticleTrack{T}(GlobalDirection{T}(mx, my, 1.), GlobalVector{T}(x0, y0, 0.))

ParticleTrack(mx::T, my::T, x0::T, y0::T) where {T} = ParticleTrack{T}(mx, my, x0, y0)

ParticleTrack(mx, my, x0, y0) = ParticleTrack(promote(mx, my, x0, y0)...)

"""
A straight track in the reference frame of a PlacedSensor.
"""
struct ProjectedTrack{T}
    direction::LocalDirection{T}
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
