# Marco Riggirello

#########
# SE(3) #
#########
# Implementation of the properties of a group
# Note: one(Pose) comes gratis from the FieldArray implementation!
function Base.inv(p::Pose{T}) where {T}
    dx = p.rotxx * p.trasx + p.rotyx * p.trasy + p.rotzx * p.trasz
    dy = p.rotxy * p.trasx + p.rotyy * p.trasy + p.rotzy * p.trasz
    dz = p.rotxz * p.trasx + p.rotyz * p.trasy + p.rotzz * p.trasz
    return Pose{T}(
        SA[
            p.rotxx p.rotyx p.rotzx -dx
            p.rotxy p.rotyy p.rotzy -dy
            p.rotxz p.rotyz p.rotzz -dz
            zero(T) zero(T) zero(T) oneunit(T)
        ]
    )
end

Base.:∘(p1::Pose, p2::Pose) = p1 * p2

#############################
# CHANGE OF REFERENCE FRAME #
#############################
# Application of poses to global/local coordinates/directions
# Since the Pose represents the active tranformation of a
# detector plane, its direct application moves from local frame
# to global frame. We decided to enforce this property in the
# typing of base functions.
function Base.:*(p::Pose, c::LocalCoordinates)
    sp = SMatrix(p)
    sc = SVector(c)
    return GlobalCoordinates(sp * sc)
end

function Base.:\(p::Pose, c::GlobalCoordinates)
    isp = SMatrix(inv(p))
    sc = SVector(c)
    return LocalCoordinates(isp * sc)
end

function Base.:*(p::Pose, d::LocalDirection)
    sp = SMatrix(p)
    sd = SVector(d)
    return GlobalDirection(sp * sd)
end

function Base.:\(p::Pose, d::GlobalDirection)
    isp = SMatrix(inv(p))
    sd = SVector(d)
    return LocalDirection(isp * sd)
end


# Functor interface. Will it work? Only time will tell
(p::Pose)(c::LocalCoordinates) = p * c
(p::Pose)(c::GlobalCoordinates) = p \ c

(p::Pose)(d::LocalDirection) = p * d
(p::Pose)(d::GlobalDirection) = p \ d
