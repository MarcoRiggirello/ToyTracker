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
struct ParticleTrack
    direction::GlobalVector
    position0::GlobalVector
end


function (T::ParticleTrack)(t::Real)
    return T.direction * t + T.position0
end
