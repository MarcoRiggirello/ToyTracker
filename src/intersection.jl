# Marco Riggirello

function intersection(t::StraightTrack, p::Pose)
    dir = t.direction
    pos = t.position
    l_dir = p(dir)
    l_pos = p(pos)
    if iszero(l_dir.w)
        @warn "The detector plane is parallel to the track."
    end
    τ = -l_pos.w / l_dir.w
    return t(τ), direction(t, τ)
end
