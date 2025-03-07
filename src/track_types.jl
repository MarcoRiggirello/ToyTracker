# Marco Riggirello

abstract type AbstractParticleTrack end

#function (t::AbstractParticleTrack)(τ::Real)::GlobalCoordinates end
#function direction(t::AbstractParticleTrack, τ::Real)::GlobalDirection end

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
StraightTrack{T}(x0::T, y0::T, mx::T, my::T) where {T} = StraightTrack{T}(x0, y0, oneunit(T), mx, my, oneunit(T))
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
#################
struct HelixTrack{T,Η,Φ,L} <: AbstractParticleTrack
    q_over_p::T  # Charge over momentum (curvature)
    η::Η         # Pseudorapidity
    ϕ::Φ         # Azimuthal angle in radians
    d0::L        # Transverse impact parameter
    z0::L        # Longitudinal impact parameter
end

# Implement the functor method for HelixTrack
#=
function (track::HelixTrack)(τ::Real)
    # Extract parameters
    q_over_p = track.q_over_p
    η = track.η
    ϕ = track.ϕ
    d0 = track.d0
    z0 = track.z0

    # Compute curvature
    curvature = abs(q_over_p)  # [GeV/c]^-1
    sinλ = sinh(η)

    # Compute transverse momentum direction
    px = cos(ϕ)
    py = sin(ϕ)

    # Compute the position at parameter τ
    x = d0 * (-py) + (1 / curvature) * (px * sin(curvature * τ) - py * (1 - cos(curvature * τ)))
    y = d0 * px + (1 / curvature) * (py * sin(curvature * τ) + px * (1 - cos(curvature * τ))
    z = z0 + τ * tanh(η)

    # Return GlobalCoordinates in cm (strip units for compatibility)
    return GlobalCoordinates(ustrip(cm, x), ustrip(cm, y), ustrip(cm, z))
end

# Implement the direction method for HelixTrack (without normalization)
function direction(track::HelixTrack, τ::Real)
    # Extract parameters
    q_over_p = track.q_over_p
    η = track.η
    ϕ = track.ϕ

    # Compute curvature
    curvature = abs(q_over_p)  # [GeV/c]^-1

    # Compute transverse momentum direction
    px = cos(ϕ)
    py = sin(ϕ)

    # Compute the direction vector components
    dx_dτ = px * cos(curvature * τ) + py * sin(curvature * τ)
    dy_dτ = py * cos(curvature * τ) - px * sin(curvature * τ)
    dz_dτ = tanh(η)

    # Return GlobalDirection (without normalization)
    return GlobalDirection(ustrip(dx_dτ), ustrip(dy_dτ), ustrip(dz_dτ))
end#######
=#
