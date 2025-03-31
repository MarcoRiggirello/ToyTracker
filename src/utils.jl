function sensorsize(s::IdealSensor)
    return s.uwidth, s.vwidth
end


function pixelsize(s::IdealSensor)
    return s.upitch, s.vpitch
end

function two_sides_colors(s::AbstractSiliconSensor, frontsidecolor=:salmon, backsidecolor=:orange)
    vertices = local_sensor_vertices(s)
    N = length(vertices)
    return [i % 2 == 0 ? backsidecolor : frontsidecolor for i in 1:N]
end
