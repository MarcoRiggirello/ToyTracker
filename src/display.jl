function tracklines(t::AbstractParticleTrack, τ_range::AbstractRange)
    # Sample the track at multiple τ values
    positions = [t(τ) for τ in τ_range]

    # Extract x, y, z coordinates from the positions
    x = [p.x for p in positions]
    y = [p.y for p in positions]
    z = [p.z for p in positions]

    return x, y, z
end

MakieCore.convert_arguments(P::Type{<:Lines}, t::AbstractParticleTrack, τ_range::AbstractRange) = tracklines(t, τ_range)

function local_sensor_surface(s::IdealSensor)
    Lu, Lv = sensorsize(s)
    urange = -Lu/2:Lu:Lu/2
    vrange = -Lv/2:Lv:Lv/2
    return [LocalCoordinates(u, v, zero(u)) for u in urange, v in vrange]
end

function sensorsurface(ps::PlacedSensor)
    s = ps.sensor
    p = ps.position
    points = local_sensor_surface(s)
    mesh = p.(points)
    x = getproperty.(mesh, :x)
    y = getproperty.(mesh, :y)
    z = getproperty.(mesh, :z)
    return x, y, z
end

MakieCore.convert_arguments(P::Type{<:Surface}, ps::PlacedSensor) = sensorsurface(ps)
