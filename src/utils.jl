function sensorsize(s::IdealSensor)
    return s.uwidth, s.vwidth
end


function pixelsize(s::IdealSensor)
    return s.upitch, s.vpitch
end

function two_sides_colors(s::AbstractSiliconSensor, frontsidecolor=:magenta, backsidecolor=:indico)
    vertices, _ = local_sensor_mesh(s)
    N = length(vertices)
    return [i % 2 == 0 ? backsidecolor : frontsidecolor for i in 1:N]
end
