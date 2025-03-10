# Marco Riggirello

###################
# Hit Measurement #
###################
abstract type AbstractParticleMeasurement end

struct Hit{T} <: AbstractParticleMeasurement
    position::SVector{2,T}
    covm::Symmetric{T,SMatrix{2,2,T,4}}
end

function Hit{T}(position::SVector{2,T}, covm::SMatrix{2,2,T,4}) where {T}
    return Hit{T}(position, Symmetric(covm))
end

function Hit(position::SVector{2,T}, covm::SMatrix{2,2,T,4}) where {T}
    return Hit{T}(position, covm)
end

function Hit(position::SVector{2,U}, covm::SMatrix{2,2,V,4}) where {U,V}
    T = promote_type(U, V)
    return Hit{T}(SVector{2,T}(position), SMatrix{2,2,T,4}(covm))
end

function Hit(position::AbstractVector, covm::AbstractMatrix)
    spos = SVector{2}(position)
    scov = SMatrix{2,2}(covm)
    return Hit(spos, scov)
end

#################
# Sensor Models #
#################
abstract type AbstractSiliconSensor end

"""
A sensor of infinitesimal thickness, with negligible charge drift, 100% efficiency and no noise.
"""
@kwdef struct IdealSensor{T} <: AbstractSiliconSensor
    uwidth::T
    vwidth::T
    upitch::T
    vpitch::T
end

IdealSensor(Lu, Lv, Δu, Δv) = IdealSensor(promote(Lu, Lv, Δu, Δv)...)

"""
A Silicon Sensor plus the (active) transformation that describe its position in the global reference frame.
"""
@kwdef struct PlacedSensor{S<:AbstractSiliconSensor,T}
    sensor::S
    position::Pose{T}
end


