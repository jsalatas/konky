function conky_nvidia_temp()
    local out = 'N/A'
    if pcall(read_nvidia) then
        out = 'Hello' --conky_parse('${nvidia temp}')
    end
    return out
end

function read_nvidia() 
    if unexpected_condition then error() end
    conky_parse('${nvidia temp}') 
end
