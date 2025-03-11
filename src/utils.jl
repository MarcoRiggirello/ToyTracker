function sensorsize(s::IdealSensor)
    return s.uwidth, s.vwidth
end


function pixelsize(s::IdealSensor)
    return s.upitch, s.vpitch
end
