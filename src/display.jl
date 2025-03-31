function tracklines(t::AbstractParticleTrack, τ_range::AbstractRange)
    # Sample the track at multiple τ values
    positions = [t(τ) for τ in τ_range]

    points = [Point3(p.x, p.y, p.z) for p in positions]
    return (points,)
end

MakieCore.convert_arguments(P::Type{<:Lines}, t::AbstractParticleTrack, τ_range::AbstractRange) = tracklines(t, τ_range)

function generate_mesh_faces()
    # for how vertices are constructed their numeration
    # is as follow (u is on the x axis, v on the y axis)
    # positive side is
    # 5---7
    # |\ /|
    # | 1 |
    # |/ \|
    # 3---9
    # negative is like this + 1.
    # Hence to make triangular faces to do mesh we
    # need to move around the grid as obtained through
    # these next, black magic gathered, triplets of
    # vertices. For know the motivation of this conundrum see
    # https://docs.makie.org/v0.22/reference/plots/mesh
    # Positive side of the sensor
    positive_faces = [
        1 3 7
        1 5 3
        1 9 5
        1 7 9
    ]
    # Negative side
    negative_faces = [
        2 8 4
        2 4 6
        2 6 10
        2 10 8
    ]
    # Sensor edges
    west_faces = [
        3 5 6
        3 6 4
    ]
    # East
    east_faces = [
        9 7 8
        9 8 10
    ]
    # South
    south_faces = [
        7 3 4
        7 4 8
    ]
    # North
    north_faces = [
        5 9 6
        6 9 8
    ]
    # Grand total
    return [positive_faces; negative_faces; west_faces; east_faces; south_faces; north_faces]
end

function local_sensor_vertices(s::IdealSensor)
    Su, Sv = sensorsize(s) ./ 2
    thickness = 1.e-3Sv # cheat to make different color work
    urange = (-Su, Su)
    vrange = (-Sv, Sv)
    wrange = (zero(thickness), -thickness)
    vertices = [LocalCoordinates(u, v, w) for u in urange for v in vrange for w in wrange]
    centers = [LocalCoordinates(zero(Su), zero(Sv), w) for w in wrange]
    prepend!(vertices, centers)
    return vertices
end

function sensormesh(ps::PlacedSensor)
    s = ps.sensor
    p = ps.position
    vertices = local_sensor_vertices(s)
    faces = generate_mesh_faces()
    mesh = p.(vertices)
    x = getproperty.(mesh, :x)
    y = getproperty.(mesh, :y)
    z = getproperty.(mesh, :z)
    return [x y z], faces
end

MakieCore.convert_arguments(P::Type{<:Mesh}, ps::PlacedSensor) = sensormesh(ps)
