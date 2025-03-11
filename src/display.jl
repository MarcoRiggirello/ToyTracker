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
    # for how vertices are constructed their numeration
    # is as follow (u is on the x axis, v on the y axis)
    # positive side is
    # … -   …   -   …   - …
    # |     |       |     |
    # 3 - 2Nv+3 - 4Nv+3 - …
    # |     |       |     |
    # 1 - 2Nv+1 - 4Nv+1 - …
    # negative is like this + 1.
    # Hence to make triangular faces to do mesh we
    # need to move around the grid as obtained through
    # these next, black magic gathered, ranges.
    i_range = 1:2:2(Nv-1)
    j_range = 0:2Nv:2Nv*(Nu-1)-1
    # Faces on the positive side of detector
    positive_indices = [i + j for i in i_range for j in j_range]
    # Lower triangles
    positive_faces_1 = [i + k for i in positive_indices, k in (0, 2Nv, 2)]
    # Upper triangles
    positive_faces_2 = [i + k for i in positive_indices, k in (2Nv, 2Nv + 2, 2)]
    # Total
    positive_faces = [positive_faces_1; positive_faces_2]
    # Faces on the negative side of detector
    # Lower triangles
    negative_indices = [i + j + 1 for i in i_range for j in j_range]
    negative_faces_1 = [i + k for i in negative_indices, k in (0, 2, 2Nv)]
    # Upper triangles
    negative_faces_2 = [i + k for i in negative_indices, k in (2Nv + 2, 2, 2Nv)]
    # Total
    negative_faces = [negative_faces_1; negative_faces_2]
    # Now the edges of the sensor. The black magic
    # is of the same kind, mutatis mutandis.
    # Grand total
    return [positive_faces; negative_faces]
end

function local_sensor_mesh(s::IdealSensor)
    Nu, Nv = 2, 2
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
