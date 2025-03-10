# Marco Riggirello

abstract type AbstractParticleTrack end


##########################
#     Straight track     #
# (test beam simulation) #
##########################
struct StraightTrack{T} <: AbstractParticleTrack
    # Add fields specific to this concrete type
    position::GlobalCoordinates{T}
    direction::GlobalDirection{T}
end

#StraightTrack(p::GlobalCoordinates{T}, d::GlobalDirection{T}) where {T} = StraightTrack{T}(p, d)

# 6 elements constructors
function StraightTrack{T}(x0::T, y0::T, z0::T, mx::T, my::T, mz::T) where {T}
    p = GlobalCoordinates{T}(x0, y0, z0)
    d = GlobalDirection{T}(mx, my, mz)
    return StraightTrack(p, d)
end
StraightTrack(x0::T, y0::T, z0::T, mx::T, my::T, mz::T) where {T} = StraightTrack{T}(x0, y0, z0, mx, my, mz)
StraightTrack(x0, y0, z0, mx, my, mz) = StraightTrack(promote(x0, y0, z0, mx, my, mz)...)

# four elements definitions
StraightTrack{T}(x0::T, y0::T, mx::T, my::T) where {T} = StraightTrack{T}(x0, y0, zero(T), mx, my, oneunit(T))
StraightTrack(x0::T, y0::T, mx::T, my::T) where {T} = StraightTrack{T}(x0, y0, mx, my)
StraightTrack(x0, y0, mx, my) = StraightTrack(promote(x0, y0, mx, my)...)

# functor for retrieveing the position at τ
function (track::StraightTrack{T})(τ) where {T}
    return GlobalCoordinates{T}(
        track.position.x + τ * track.direction.x,
        track.position.y + τ * track.direction.y,
        track.position.z + τ * track.direction.z
    )
end

function direction(track::StraightTrack, _)
    return track.direction
end


########################
#     Helix track      #
# (tracker simulation) #
########################
struct HelixTrack{T,Η,Φ,L} <: AbstractParticleTrack
    q_over_ρ::T  # Charge over curvature
    η::Η         # Pseudorapidity
    ϕ::Φ         # Azimuthal angle in radians
    d0::L        # Transverse impact parameter
    z0::L        # Longitudinal impact parameter
end
