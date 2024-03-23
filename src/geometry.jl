# Marco Riggirello

Base.:*(p::Pose, c::LocalVector) = GlobalVector(SMatrix(p) * SVector(c))

function Base.inv(p::Pose)
    dx = p.rotxx * p.trasx + p.rotyx * p.trasy + p.rotzx * p.trasz
    dy = p.rotxy * p.trasx + p.rotyy * p.trasy + p.rotzy * p.trasz
    dz = p.rotxz * p.trasx + p.rotyz * p.trasy + p.rotzz * p.trasz
    return Pose(
        SA[
            p.rotxx p.rotyx p.rotzx -dx
            p.rotxy p.rotyy p.rotzy -dy
            p.rotxz p.rotyz p.rotzz -dz
            0       0       0         1
        ]
    )
end

Base.:\(p::Pose, c::GlobalVector) = LocalVector(inv(p) * c) 
