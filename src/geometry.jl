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


function Base.:*(p::Pose, d::LocalDirection)
    rot = SA[
        p.rotxx p.rotxy p.rotxz 0
        p.rotyx p.rotyy p.rotyz 0
        p.rotzx p.rotzy p.rotzz 0
        0       0       0       1
    ]
    return GlobalDirection(rot * d)
end


function Base.:\(p::Pose, d::GlobalDirection)
    invrot = SA[
        p.rotxx p.rotyx p.rotzx 0
        p.rotxy p.rotyy p.rotzy 0
        p.rotxz p.rotyz p.rotzz 0
        0       0       0       1
    ]
    return LocalDirection(invrot * d)
end
