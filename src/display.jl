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

function generate_mesh_faces(Nu, Nv)
    if Nu < 3 || Nv < 3
        throw(ArgumentError("Mesh grid can't be less than 3 by 3 points. Sorry."))
    end
    # This is honestly black magic
    # Faces on the positive side of detector (triangular)
    positive_indices_1 = [i + j for i in 1:2:(2Nu-2) for j in 0:2Nv:2(2Nv-1)]
    positive_faces_1 = [i + k for i in positive_indices_1, k in (0, 2Nv, 2)]
    positive_indices_2 = [i + j for i in 3:2:2Nu for j in 0:2Nv:2(2Nv-1)]
    positive_faces_2 = [i + k for i in positive_indices_2, k in (0, 2Nv - 2, 2Nv)]
    positive_faces = [positive_faces_1; positive_faces_2]
    # Faces on the negative side of detector (triangular)
    negative_indices_1 = [i + j for i in 2:2:(2Nu-2) for j in 0:2Nv:2(2Nv-1)]
    negative_faces_1 = [i + k for i in negative_indices_1, k in (0, 2, 2Nv)]
    negative_indices_2 = [i + j for i in 4:2:2Nu for j in 0:2Nv:2(2Nv-1)]
    negative_faces_2 = [i + k for i in negative_indices_2, k in (0, 2Nv, 2Nv - 2)]
    negative_faces = [negative_faces_1; negative_faces_2]
    # total
    return [positive_faces; negative_faces]
end

function local_sensor_mesh(s::IdealSensor)
    Nu, Nv = 3, 3
    Lu, Lv = sensorsize(s)
    urange = LinRange(-Lu / 2, Lu / 2, Nu)
    vrange = LinRange(-Lv / 2, Lv / 2, Nv)
    thickness = 0.1pixelsize(s)[1] # cheat to make different color work
    vertices = [LocalCoordinates(u, v, w) for u in urange for v in vrange for w in (zero(thickness), -thickness)]
    faces = generate_mesh_faces(Nu, Nv)
    return vertices, faces
end

function sensormesh(ps::PlacedSensor)
    s = ps.sensor
    p = ps.position
    vertices, faces = local_sensor_mesh(s)
    mesh = p.(vertices)
    x = getproperty.(mesh, :x)
    y = getproperty.(mesh, :y)
    z = getproperty.(mesh, :z)
    return [x y z], faces
end

MakieCore.convert_arguments(P::Type{<:Mesh}, ps::PlacedSensor) = sensormesh(ps)
