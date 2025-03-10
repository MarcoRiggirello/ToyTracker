# Marco Riggirello

# This is the most trivial interaction possible:
# just a signal in the closest pixel and that's it.
function interaction(s::IdealSensor, i::LocalCoordinates)
    Lu, Lv = s.uwidth, s.vwidth
    Δu, Δv = s.upitch, s.vpitch

    i_u, i_v = i.u, i.v


    if abs(i_u) > Lu / 2 || abs(i_v) > Lv / 2
        @info "Particle did not hit the sensor."
        return missing
    end

    u = (i_u ÷ Δu) * Δu + Δu / 2
    v = (i_v ÷ Δv) * Δv + Δv / 2

    m = SA[u, v]
    Σ = SA[Δu^2/12 0; 0 Δv^2/12]

    return Hit(m, Σ)
end
