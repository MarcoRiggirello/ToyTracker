# Marco Riggirello

function project(t::ParticleTrack, s::PlacedSensor)
    M = position(s)
    d = direction(t)
    p = position0(t)
    return ProjectedTrack(M\d, M\p)
end


function intersection(t::ProjectedTrack)
    d = direction(t)
    p = position0(t)
    if d.w == 0
        @info "The detector plane is parallel to the track."
        return missing
    else
        τ = -(p.w/d.w)
        return t(τ)
    end
end


function interaction(t::ProjectedTrack, s::SiliconSensor)
    sz_x, sz_y, _ = sensordims(s)
    px_x, px_y = pixeldims(s)
    ip_x, ip_y, _ = intersection(t)

    if !(0 < ip_x < sz_x) || !(0 < ip_y < sz_y)
        return missing
    end

    x = (ip_x ÷ px_x) * px_x + px_x/2
    y = (ip_y ÷ px_y) * px_y + px_y/2

    return Hit(Cluster(x, px_x), Cluster(y, px_y))
end


function interaction(t::ParticleTrack, s::PlacedSensor)
    tt = project(t, s)
    ss = sensor(s)
    return interaction(tt, ss)
end


function interaction(t::ParticleTrack, d::Tracker)
    hits = Dict{String, Hit}()
    for s in sensors(d) 
        id = s.first
        ss = s.second
        ht = interaction(t, ss)
        push!(hits, id => ht)
    end
    return hits
end

