# Marco Riggirello

*(p::Pose, c::LocalVector) = GlobalVector(p * c)

*(p::Pose, c::GlobalVector) = LocalVector(p * c)

function inv(p::Pose)
    r = SA[
        p.rotxx p.rotyx p.rotzx
        p.rotxy p.rotyy p.rotzy
        p.rotxz p.rotyz p.rotzz
    ]
    t = SA[p.trasx, p.trasy, p.trasz]
    q = SA[
        r     -(r*t)
        0 0 0      1
    ]
    return Pose(q)
end

