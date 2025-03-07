# Non-mutating version: Creates and returns a line plot
function trackline(t::AbstractParticleTrack, τ_range::AbstractRange; kwargs...)
    # Sample the track at multiple τ values
    positions = [t(τ) for τ in τ_range]

    # Extract x, y, z coordinates from the positions
    x = [p[1] for p in positions]
    y = [p[2] for p in positions]
    z = [p[3] for p in positions]

    # Create a 3D line plot
    line = lines(x, y, z; kwargs...)
    return line
end

# Mutating version: Adds the line plot to an existing scene
function trackline!(scene, t::AbstractParticleTrack, τ_range::AbstractRange; kwargs...)
    # Sample the track at multiple τ values
    positions = [t(τ) for τ in τ_range]

    # Extract x, y, z coordinates from the positions
    x = [p[1] for p in positions]
    y = [p[2] for p in positions]
    z = [p[3] for p in positions]

    # Add the line plot to the scene
    line = lines!(scene, x, y, z; kwargs...)
    return line
end
