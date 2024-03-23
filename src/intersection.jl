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
