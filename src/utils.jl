function sensordims(s::SiliconSensor)
    return s.xwidth, s.ywidth, s.thickness
end


function pixeldims(s::SiliconSensor)
    return s.xpitch, s.ypitch
end


function sensor(s::PlacedSensor)
    return s.sensor
end


function position(s::PlacedSensor)
    return s.position
end


