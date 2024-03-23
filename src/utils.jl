function sensordims(s::SiliconSensor)
    return s.xwidth, s.ywidth, s.thickness
end


function pixeldims(s::SiliconSensor)
    return s.xpitch, s.ypitch
end


function sensor(s::PlacedSensor)
    return s.sensor
end


function position(s::PlacedSensor)
    return s.position
end

position0(t::ParticleTrack) = t.position0
direction(t::ParticleTrack) = t.direction

function (t::ParticleTrack)(τ::Real)
    p = position0(t)
    d = direction(t)

    x = d.x * τ + p.x
    y = d.y * τ + p.y
    z = d.z * τ + p.z
    return GlobalVector(x, y, z)
end

position0(t::ProjectedTrack) = t.position0
direction(t::ProjectedTrack) = t.direction

function (t::ProjectedTrack)(τ::Real)
    p = position0(t)
    d = direction(t)

    u = d.u * τ + p.u
    v = d.v * τ + p.v
    w = d.w * τ + p.w
    return LocalVector(u, v, w)
end
