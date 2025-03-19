# Marco Riggirello

function flatten(h::Hit)
    u, v = h.position
    Σ = h.covm
    Δu = sqrt(Σ[1,1])
    Δv = sqrt(Σ[2,2])
    corr = Σ[1,2]/(Δu*Δv)
    return (u=u, v=v, Δu=Δu, Δv=Δv, corr=corr)
end


