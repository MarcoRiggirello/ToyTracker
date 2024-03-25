using DataFrames, CSV
using ProgressMeter


include("../src/ToyTracker.jl")
using .ToyTracker

function generate(n, ofile=nothing)
    # A 10 cm × 10 cm sensor with 100 um × 1 mm pixels 
    macropix = SiliconSensor(100., 100., .1, 1., .3)

    # Five parallel detector planes at 10 cm distance
    # Slight misalignment hardcoded (0.1 * randn()).
    pose1 = Pose(0, 0, 100, 0, 0, 0)
    pose2 = Pose(0.1, -0.5, 202, 0.015, -0.01, -0.02)
    pose3 = Pose(0.15, -0.038, 299, 0.042, -0.073, 0.058)
    pose4 = Pose(-0.048, -0.024, 400, 0.045, -0.042, -0.21)
    pose5 = Pose(0, 0, 500, 0, 0, 0)

    # The setup
    hodoscope = Tracker(
        Dict(
            "s1" => PlacedSensor(macropix, pose1),
            "s2" => PlacedSensor(macropix, pose2),
            "s3" => PlacedSensor(macropix, pose3),
            "s4" => PlacedSensor(macropix, pose4),
            "s5" => PlacedSensor(macropix, pose5)
        )
    )


    d = DataFrame()

    @showprogress for i in 1:n
        x0 = 100*rand()
        y0 = 100*rand()
        mx = .1*randn()
        my = .1*randn()
        t = ParticleTrack(mx, my, x0, y0)

        hits = interaction(t, hodoscope)
        for h in hits
            sid = h.first
            hit = h.second
            if ismissing(hit)
                continue
            end
            x  = hit.localx.center
            Δx = hit.localx.width
            y  = hit.localy.center
            Δy = hit.localy.width
            data = (
                track_id = "t$i",
                track_mx = mx,
                track_my = my,
                track_x0 = x0,
                track_y0 = y0,
                sensor_id = sid,
                local_x = x,
                px_xwidth = Δx,
                local_y = y,
                px_ywidth = Δy
            )
            push!(d, data)
        end
    end

    if !isnothing(ofile)
        CSV.write(ofile, d)
    end
    return d
end
